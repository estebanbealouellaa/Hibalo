// Swap changes only the direction; History keeps one entry per text, not one per swap.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/models/translator_state.dart';
import 'package:hibalo_app/providers/translator_provider.dart';
import 'package:hibalo_app/screens/translator_screen.dart';
import 'package:hibalo_app/services/translation_store.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The real provider with a fake translation step: "HIL(text)" or "FIL(text)".
class _Translator extends TranslatorProvider {
  int runs = 0;

  @override
  Future<(String, bool)> runTranslation(
    String text,
    String sourceLanguage,
    void Function(String textSoFar) onPartial,
  ) async {
    runs++;
    return ('${sourceLanguage == Languages.tagalog ? 'HIL' : 'FIL'}($text)', false);
  }
}

const _speechChannel = MethodChannel('plugin.csdcorp.com/speech_to_text');

void main() {
  final store = TranslationStore.instance;

  Future<_Translator> pump(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    store.resetForTest();
    await tester.runAsync(() => store.setUser('u1'));
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(_speechChannel, (call) async => call.method == 'initialize' ? false : null);
    addTearDown(() => messenger.setMockMethodCallHandler(_speechChannel, null));
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final provider = _Translator();
    await tester.pumpWidget(
      ChangeNotifierProvider<TranslatorProvider>.value(
        value: provider,
        child: MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          theme: buildAppTheme(),
          home: const TranslatorScreen(),
        ),
      ),
    );
    await tester.pump();
    return provider;
  }

  String input(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField)).controller!.text;

  Future<void> swap(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Swap languages'));
    await tester.pumpAndSettle();
  }

  testWidgets('empty input: swap changes only the direction', (tester) async {
    final p = await pump(tester);
    expect(p.state.sourceLanguage, Languages.tagalog);
    await swap(tester);
    expect(p.state.sourceLanguage, Languages.hiligaynon);
    expect(input(tester), '');
    expect(p.runs, 0, reason: 'nothing to translate');
  });

  testWidgets('typed text stays in the box and is translated the new way', (tester) async {
    final p = await pump(tester);
    await swap(tester); // Hiligaynon → Filipino
    await tester.enterText(find.byType(TextField), 'Magandang umaga po');
    await tester.pump();
    await swap(tester); // Filipino → Hiligaynon
    expect(p.state.sourceLanguage, Languages.tagalog);
    expect(input(tester), 'Magandang umaga po', reason: 'never replaced by the translation');
    expect(find.text('HIL(Magandang umaga po)'), findsOneWidget);

    await swap(tester);
    expect(input(tester), 'Magandang umaga po');
    expect(find.text('FIL(Magandang umaga po)'), findsOneWidget);
  });

  testWidgets('text from the voice pop-up stays too, and is translated again', (tester) async {
    final p = await pump(tester);
    await p.updateOriginalText('Salamat gid'); // what a voice result does
    await tester.pumpAndSettle();
    expect(find.text('HIL(Salamat gid)'), findsOneWidget);
    await swap(tester);
    expect(input(tester), 'Salamat gid');
    expect(find.text('FIL(Salamat gid)'), findsOneWidget);
  });

  testWidgets('History keeps the final translation, not one entry per swap', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'Magandang umaga po');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Translate'));
    await tester.pumpAndSettle();
    expect(store.history.map((e) => e.translation), ['HIL(Magandang umaga po)']);

    await swap(tester);
    await swap(tester);
    await swap(tester);
    expect(store.history, hasLength(1));
    expect(store.history.single.translation, 'FIL(Magandang umaga po)');
    expect(store.history.single.fromHiligaynon, isTrue);

    // A new text is a new entry.
    await tester.enterText(find.byType(TextField), 'Salamat');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Translate'));
    await tester.pumpAndSettle();
    expect(store.history.map((e) => e.source), ['Salamat', 'Magandang umaga po']);
  });
}
