// Translate History / Saved (phone only), Save and Share on the result,
// and the Settings clear rows.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/l10n/app_localizations.dart';
import 'package:hibalo_app/screens/settings_screen.dart';
import 'package:hibalo_app/screens/translate/history_screen.dart';
import 'package:hibalo_app/services/translation_store.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';

TranslationEntry _e(String source, String translation, {bool hil = false, EntryInput input = EntryInput.typed}) =>
    TranslationEntry(source: source, translation: translation, fromHiligaynon: hil, input: input, time: DateTime.now());

final _store = TranslationStore.instance;

Future<void> _fresh([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  _store.resetForTest();
  await _store.setUser('u1');
}

/// Opens [screen] from a button, so it can pop with a result.
Future<List<Object?>> _open(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(360, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final results = <Object?>[];
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLanguage.delegates,
      supportedLocales: AppLanguage.supportedLocales,
      theme: buildAppTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async =>
                  results.add(await Navigator.push(context, MaterialPageRoute(builder: (_) => screen))),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return results;
}

void main() {
  group('Store (phone only)', () {
    setUp(_fresh);

    test('adds newest first and skips an exact repeat in a row', () async {
      await _store.addToHistory(_e('Magandang umaga', 'Maayong aga'));
      await _store.addToHistory(_e('Magandang umaga', 'Maayong aga'));
      await _store.addToHistory(_e('Salamat', 'Salamat'));
      await _store.addToHistory(_e('Magandang umaga', 'Maayong aga'));
      expect(_store.history.map((e) => e.source), ['Magandang umaga', 'Salamat', 'Magandang umaga']);
    });

    test('keeps the last 100', () async {
      for (var i = 0; i < 105; i++) {
        await _store.addToHistory(_e('word $i', 'pulong $i'));
      }
      expect(_store.history.length, TranslationStore.historyLimit);
      expect(_store.history.first.source, 'word 104');
      expect(_store.history.last.source, 'word 5');
    });

    test('voice and photo are kept too; empty text is not', () async {
      await _store.addToHistory(_e('Kumusta ka?', 'Kamusta ka?', input: EntryInput.voice));
      await _store.addToHistory(_e('Maraming salamat', 'Madamo nga salamat', input: EntryInput.photo));
      await _store.addToHistory(_e(' ', 'x'));
      expect(_store.history.map((e) => e.input), [EntryInput.photo, EntryInput.voice]);
    });

    test('save / unsave, no limit, and it survives a restart', () async {
      final e = _e('Walang anuman', 'Wala sing anuman');
      await _store.toggleSaved(e);
      expect(_store.isSaved(e), isTrue);
      for (var i = 0; i < 150; i++) {
        await _store.toggleSaved(_e('w$i', 'p$i'));
      }
      expect(_store.saved.length, 151);
      await _store.addToHistory(e);

      // A new start reads both back from the phone.
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(TranslationStore.savedKeyFor('u1'))!;
      final history = prefs.getString(TranslationStore.historyKeyFor('u1'))!;
      await _fresh({TranslationStore.savedKeyFor('u1'): saved, TranslationStore.historyKeyFor('u1'): history});
      expect(_store.saved.length, 151);
      expect(_store.history.single.translation, 'Wala sing anuman');

      await _store.toggleSaved(e);
      expect(_store.isSaved(e), isFalse);
    });

    test('clear history keeps saved words, and the other way round', () async {
      final e = _e('Paalam', 'Babay');
      await _store.addToHistory(e);
      await _store.toggleSaved(e);
      await _store.clearHistory();
      expect(_store.history, isEmpty);
      expect(_store.saved, hasLength(1));
      await _store.addToHistory(e);
      await _store.clearSaved();
      expect(_store.saved, isEmpty);
      expect(_store.history, hasLength(1));
    });

    test('each account has its own History and Saved; signed out shows none', () async {
      await _store.addToHistory(_e('Magandang umaga', 'Maayong aga'));
      await _store.toggleSaved(_e('Magandang umaga', 'Maayong aga'));

      await _store.setUser('u2');
      expect(_store.history, isEmpty, reason: 'another account never sees them');
      expect(_store.saved, isEmpty);
      await _store.addToHistory(_e('Salamat', 'Salamat'));

      await _store.setUser(null);
      expect(_store.history, isEmpty, reason: 'logged out hides them');
      await _store.addToHistory(_e('Paalam', 'Babay'));
      expect(_store.history, isEmpty, reason: 'nothing is kept while signed out');

      await _store.setUser('u1');
      expect(_store.history.single.source, 'Magandang umaga', reason: 'signing back in shows them again');
      expect(_store.saved, hasLength(1));
      await _store.setUser('u2');
      expect(_store.history.single.source, 'Salamat');
    });

    test('Today / Yesterday / date', () {
      final now = DateTime(2026, 11, 6, 9);
      expect(dayLabel(lookupAppLocalizations(const Locale('en')), DateTime(2026, 11, 6, 1), now), 'Today');
      expect(dayLabel(lookupAppLocalizations(const Locale('en')), DateTime(2026, 11, 5, 23), now), 'Yesterday');
      expect(dayLabel(lookupAppLocalizations(const Locale('en')), DateTime(2026, 11, 2), now), 'November 2');
    });

    test('share text has both languages', () {
      expect(shareText(_e('Magandang umaga', 'Maayong aga')), 'Filipino: Magandang umaga\nHiligaynon: Maayong aga');
    });
  });

  group('History and Saved screens', () {
    setUp(_fresh);

    testWidgets('empty History and empty Saved', (tester) async {
      final results = await _open(tester, const TranslateHistoryScreen());
      expect(find.text('No translations yet'), findsOneWidget);
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(find.text('No saved words yet'), findsOneWidget);
      await tester.tap(find.text('Start translating'));
      await tester.pumpAndSettle();
      expect(results, [null], reason: 'Start translating goes back to Translate');
    });

    testWidgets('History lists translations; tapping one opens it in Translate', (tester) async {
      await tester.runAsync(() => _store.addToHistory(_e('Maayong gab-i', 'Magandang gabi', hil: true)));
      await tester.runAsync(() => _store.addToHistory(_e('Magandang umaga', 'Maayong aga')));
      final results = await _open(tester, const TranslateHistoryScreen());
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Filipino → Hiligaynon'), findsOneWidget);
      expect(find.text('Hiligaynon → Filipino'), findsOneWidget);
      expect(find.text('Clear all'), findsOneWidget);

      // Save from History.
      await tester.tap(find.byTooltip('Save').first);
      await tester.pumpAndSettle();
      expect(_store.saved.single.translation, 'Maayong aga');

      await tester.tap(find.text('Magandang gabi'));
      await tester.pumpAndSettle();
      expect((results.single as TranslationEntry).source, 'Maayong gab-i');
    });

    testWidgets('Saved: count, Listen, remove one by one', (tester) async {
      await tester.runAsync(() => _store.toggleSaved(_e('Walang anuman', 'Wala sing anuman')));
      await tester.runAsync(() => _store.toggleSaved(_e('Magandang umaga', 'Maayong aga')));
      await _open(tester, const TranslateHistoryScreen(showSaved: true));
      expect(find.text('2 saved words and phrases'), findsOneWidget);
      expect(find.byTooltip('Listen'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Remove from saved').first);
      await tester.pumpAndSettle();
      expect(find.text('1 saved word or phrase'), findsOneWidget);
      expect(_store.saved.single.translation, 'Wala sing anuman');
    });

    testWidgets('Clear all asks first, then clears History', (tester) async {
      await tester.runAsync(() => _store.addToHistory(_e('Paalam', 'Babay')));
      await _open(tester, const TranslateHistoryScreen());
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      expect(find.text('Clear translation history?'), findsOneWidget);
      await tester.tap(find.text('Keep history'));
      await tester.pumpAndSettle();
      expect(_store.history, hasLength(1));
      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear history'));
      await tester.pumpAndSettle();
      expect(_store.history, isEmpty);
      expect(find.text('No translations yet'), findsOneWidget);
    });
  });

  group('Settings', () {
    setUp(_fresh);

    testWidgets('Clear translation history: dialog, then snackbar', (tester) async {
      await tester.runAsync(() => _store.addToHistory(_e('Paalam', 'Babay')));
      await tester.runAsync(() => _store.toggleSaved(_e('Paalam', 'Babay')));
      await _open(tester, const SettingsScreen());
      await tester.tap(find.text('Clear translation history'));
      await tester.pumpAndSettle();
      expect(
        find.text('This removes all your past translations from this phone. Your saved words stay.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Clear history'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Translation history cleared'), findsOneWidget);
      expect(_store.history, isEmpty);
      expect(_store.saved, hasLength(1));
    });

    testWidgets('Clear saved words: Keep, then Clear', (tester) async {
      await tester.runAsync(() => _store.toggleSaved(_e('Paalam', 'Babay')));
      await _open(tester, const SettingsScreen());
      await tester.tap(find.text('Clear saved words'));
      await tester.pumpAndSettle();
      expect(find.text('Clear saved words?'), findsOneWidget);
      await tester.tap(find.text('Keep saved words'));
      await tester.pumpAndSettle();
      expect(_store.saved, hasLength(1));
      await tester.tap(find.text('Clear saved words'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear saved words').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Saved words cleared'), findsOneWidget);
      expect(_store.saved, isEmpty);
    });
  });

  group('Result card', () {
    testWidgets('Listen, Copy, Share and Save; saved shows a filled bookmark', (tester) async {
      var shares = 0, saves = 0;
      Future<void> pump({required bool saved, bool translating = false}) => tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          theme: buildAppTheme(),
          home: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                TranslationResultCard(
                  language: 'Hiligaynon',
                  text: 'Maayong aga',
                  translating: translating,
                  onListen: () {},
                  onCopy: () {},
                  onShare: () => shares++,
                  onSave: () => saves++,
                  saved: saved,
                ),
              ],
            ),
          ),
        ),
      );
      await pump(saved: false);
      await tester.tap(find.byTooltip('Share'));
      await tester.tap(find.byTooltip('Save'));
      expect((shares, saves), (1, 1));
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
      await pump(saved: true);
      expect(find.byTooltip('Saved'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
      await pump(saved: false, translating: true);
      await tester.tap(find.byTooltip('Share'));
      expect(shares, 1, reason: 'Share waits for the finished translation');
    });
  });
}
