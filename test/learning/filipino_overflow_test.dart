// Filipino lesson text (Stage 2): every lesson part and every quiz (+ its review) in Filipino on a
// 360 × 740 phone, with the Filipino app words. Any layout overflow fails the test.
//   flutter test test/learning/filipino_overflow_test.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/l10n/app_localizations.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/parts.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_player_test.dart' show FakeRecorder, noClipComparer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const size = Size(360, 740);
  const locale = Locale('fil');
  final t = lookupAppLocalizations(locale);

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle, filipino: true)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the app loads the Filipino lesson text', () {
    expect(catalog.levels.map((l) => l.title), ['Baguhan', 'Katamtaman', 'Abante']);
    expect(catalog.settings.resultTiers.last.title, 'Magsanay pa');
    expect(catalog.settings.avatars.nameFor('You'), 'Ikaw');
    expect(catalog.lessonById('b02')!.title, isNot('Greetings & Courtesy'));
  });

  Future<void> frames(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> show(WidgetTester tester, Widget screen, Map<String, LessonProgress> lessons) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: LearningProgress.ready(catalog, ProgressSnapshot(lessons: lessons)),
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
    nav.push(MaterialPageRoute<void>(builder: (_) => screen));
    await frames(tester);
  }

  for (final (index, name) in [(0, 'Beginner'), (1, 'Intermediate'), (2, 'Advanced')]) {
    testWidgets('$name: every lesson part fits in Filipino at 360 × 740', (tester) async {
      for (final l in catalog.levels[index].lessons) {
        for (var i = 0; i < l.partsCount; i++) {
          await show(tester, LessonPlayerScreen(lessonId: l.id, startPart: i), const {});
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '${l.id} part ${i + 1}');
          // Step through multi-step parts too (cards).
          for (var s = 1; s < l.parts[i].stepCount; s++) {
            if (l.parts[i] is LettersPartData) break;
            await tester.tap(find.byType(FilledButton).last);
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: '${l.id} part ${i + 1} step $s');
          }
        }
      }
    });
  }

  Future<void> press(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await frames(tester);
  }

  Finder tileOf(SpotMistakeData q, int index) {
    final word = q.tiles[index];
    final before = q.tiles.take(index).where((w) => w == word).length;
    return find.text(word).at(before);
  }

  Future<void> answerRight(WidgetTester tester, QuizQuestion q) async {
    switch (q) {
      case ChoiceQuestion c:
        await press(tester, find.text(c.correctOption).last);
      case SpotMistakeData s:
        await press(tester, tileOf(s, s.wrongIndex));
      case BuildSentenceData b:
        for (final w in b.answer) {
          await press(tester, find.text(w).last);
        }
      case MatchPairsData m:
        for (final p in m.pairs) {
          await press(tester, find.text(p.hil).first);
          await press(tester, find.text(p.fil).last);
        }
      case TypeAnswerData a:
        await tester.enterText(find.byType(TextField), a.accepted.first);
        await frames(tester, 2);
      case DictationData d:
        await tester.enterText(find.byType(TextField), d.accepted.first);
        await frames(tester, 2);
      case SpeakingData():
        await press(tester, find.byIcon(Icons.mic_rounded).last);
        await press(tester, find.byIcon(Icons.stop_rounded));
      case OpenAnswerData():
        await tester.enterText(find.byType(TextField), 'Maayong aga.');
        await frames(tester, 2);
    }
    expect(tester.takeException(), isNull, reason: '${q.id} answered');
    await press(tester, find.byType(FilledButton).last);
    expect(tester.takeException(), isNull, reason: '${q.id} feedback');
    if (q is! SpeakingData) await press(tester, find.text(t.continueButton).last);
  }

  for (final (index, name) in [(0, 'Beginner'), (1, 'Intermediate'), (2, 'Advanced')]) {
    testWidgets('$name: every quiz and its review fit in Filipino at 360 × 740', (tester) async {
      for (final l in catalog.levels[index].lessons.where((l) => l.hasQuiz)) {
        await show(
          tester,
          QuizPlayerScreen(lessonId: l.id, random: Random(1), recorder: FakeRecorder(), comparer: noClipComparer()),
          {l.id: LessonProgress(partsDone: l.partsCount, completed: true)},
        );
        for (final q in l.quiz!.questions) {
          await answerRight(tester, q);
        }
        await frames(tester);
        expect(tester.takeException(), isNull, reason: '${l.id} result');
        expect(find.text('Perpekto!'), findsOneWidget, reason: '${l.id}: all right');

        await press(tester, find.text(t.reviewAnswers));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '${l.id} review');
        final list = find.byType(Scrollable).first;
        for (var i = 0; i < 40; i++) {
          final before = tester.state<ScrollableState>(list).position.pixels;
          await tester.drag(list, const Offset(0, -500));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: '${l.id} review scrolled');
          if (tester.state<ScrollableState>(list).position.pixels == before) break;
        }
      }
    });
  }
}
