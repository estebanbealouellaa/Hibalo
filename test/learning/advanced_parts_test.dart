// Advanced parts in the lesson player: P13 idiom cards, P14 formal vs casual (incl. wrong on purpose
// and paging), the role-play quote and choice note, and the reading intro line.
//   flutter test test/learning/advanced_parts_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/parts/part_common.dart' show AudioButton;
import 'package:hibalo_app/learning/widgets/parts/role_play_part.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  int partIndex(String lessonId, String partId) =>
      catalog.lessonById(lessonId)!.parts.indexWhere((p) => p.id == partId);

  /// Opens the player at [partId] on a small phone (360 × 760).
  Future<void> open(WidgetTester tester, String lessonId, String partId, {Locale? locale}) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: LearningProgress.ready(catalog, ProgressSnapshot()),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,
        home: const Scaffold(body: Text('HOME')),
      ),
    ));
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: LearningRoutes.learnRoute),
      builder: (_) => const Scaffold(body: Text('LEARN')),
    ));
    nav.push(MaterialPageRoute<void>(
      builder: (_) => LessonPlayerScreen(lessonId: lessonId, startPart: partIndex(lessonId, partId)),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  group('P13 idiom cards', () {
    testWidgets('a careful card: counter, fields, warning tone and line, example; Next pages', (tester) async {
      await open(tester, 'a03', 'a03_p03');
      expect(find.text('1 / 5'), findsOneWidget);
      expect(find.text('Ambot.'), findsOneWidget);
      for (final label in ['Word for word', 'What it really means', 'Tone', 'Who you can say it to', 'Example']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(find.text('Can sound rude'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      expect(find.textContaining('to an older person can sound rude'), findsOneWidget);
      expect(find.text('— Diin si Ben?'), findsOneWidget);
      expect(find.text('— Nasaan si Ben?'), findsOneWidget);
      expect(find.byType(AudioButton), findsNothing, reason: 'no clip recorded yet');
      // No part title on idiom cards (Lance).
      final part = catalog.lessonById('a03')!.parts[partIndex('a03', 'a03_p03')];
      expect(find.text((part as dynamic).title as String), findsNothing);

      await next(tester);
      expect(find.text('2 / 5'), findsOneWidget);
      expect(find.text('Abaw!'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing, reason: 'not a careful card');
      expect(find.text('Lesson 3 · Part 3 of 16'), findsOneWidget, reason: 'still the same part');
    });

    testWidgets('every idiom card draws on a small phone, in all three languages', (tester) async {
      for (final locale in const [Locale('en'), Locale('fil'), Locale('hil')]) {
        for (final (lessonId, partId) in [('a03', 'a03_p03'), ('a03', 'a03_p05'), ('a05', 'a05_p05')]) {
          await open(tester, lessonId, partId, locale: locale);
          final count = (catalog.lessonById(lessonId)!.parts[partIndex(lessonId, partId)] as dynamic).cards.length as int;
          for (var i = 1; i < count; i++) {
            await tester.tap(find.byType(FilledButton).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '$partId card ${i + 1} $locale');
          }
        }
      }
    });
  });

  group('P14 formal vs casual', () {
    testWidgets('wrong on purpose: ✗ card with the note, part title under the situation, n / N', (tester) async {
      await open(tester, 'a02', 'a02_p03');
      expect(find.text('Saying "I love you"'), findsOneWidget, reason: 'header = situation title');
      expect(find.text('Word for Word vs Natural'), findsOneWidget, reason: 'the part title under it');
      expect(find.text('1 / 6'), findsOneWidget);
      expect(find.text('Word for word (sounds like Filipino)'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsWidgets);
      expect(find.text('Mahal ko ikaw.'), findsOneWidget);
      expect(find.textContaining('Ilonggos say Palangga ta ka', findRichText: true), findsOneWidget,
          reason: 'note with its *markup* rendered, no asterisks');
      expect(find.text('Natural Hiligaynon'), findsOneWidget);
      expect(find.text('Palangga ta ka.'), findsOneWidget);
      expect(find.text('Mahal kita.'), findsOneWidget);
      expect(find.text('What changed'), findsOneWidget);
      expect(find.text('mahal → palangga'), findsOneWidget);
      expect(find.byType(AudioButton), findsNothing, reason: 'no audio on P14');

      await next(tester);
      expect(find.text('2 / 6'), findsOneWidget);
      expect(find.text('Asking if someone has eaten'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(find.text('1 / 6'), findsOneWidget);
    });

    testWidgets('a normal pair: two labelled cards', (tester) async {
      await open(tester, 'a04', 'a04_p04');
      expect(find.text("Asking someone's name"), findsOneWidget);
      expect(find.text('Casual or Polite?'), findsOneWidget);
      expect(find.text('Casual: friends, family'), findsOneWidget);
      expect(find.text('Polite: elders, teachers, officials'), findsOneWidget);
      expect(find.text('Ano imo ngalan?'), findsOneWidget);
      expect(find.text('Ano pangalan mo?'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget, reason: 'only the X of the top bar');
    });

    testWidgets('every situation of every P14 draws on a small phone', (tester) async {
      for (final lesson in catalog.levels[2].lessons) {
        for (final part in lesson.parts.where((p) => p.template == 'P14')) {
          await open(tester, lesson.id, part.id);
          for (var i = 1; i < part.stepCount; i++) {
            await tester.tap(find.byType(FilledButton).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '${part.id} situation ${i + 1}');
          }
        }
      }
    });
  });

  group('role-play extras and reading intro', () {
    testWidgets('a quoted line under the bubble and a note above a reply (a09)', (tester) async {
      await open(tester, 'a09', 'a09_p12');
      expect(find.text('Your friend said: "Ang sarap po ng luto ninyo, Lola!"'), findsOneWidget);
      // Right reply → the next turn, whose right reply has the note.
      await tester.ensureVisible(find.text('Namit gid kuno ang luto ninyo, La!'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Namit gid kuno ang luto ninyo, La!'));
      await tester.pump(RolePlayPart.rightPause);
      await tester.pumpAndSettle();
      expect(find.text('Filipino, to your friend'), findsOneWidget);
      await tester.ensureVisible(find.text('Kain ka pa raw, sabi ni Lola.').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kain ka pa raw, sabi ni Lola.').last);
      await tester.pump(RolePlayPart.rightPause);
      await tester.pumpAndSettle();
      expect(find.text('Your friend said: "Busog na po ako. Salamat po!"'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the reading intro line (a09)', (tester) async {
      await open(tester, 'a09', 'a09_p10');
      expect(find.text('Your cousin wrote a message in Filipino. Here is the Hiligaynon translation.', findRichText: true),
          findsOneWidget);
    });
  });
}
