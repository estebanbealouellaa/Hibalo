// Advanced quizzes: Q12 spot the mistake (right / wrong), Q13 passage sets (label, folding, listen without
// audio), and every Advanced quiz passing all right ("Advanced complete!" after Lesson 10).
//   flutter test test/learning/advanced_quiz_test.dart

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/widgets/parts/part_common.dart' show AudioButton;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quiz_player_test.dart' show FakeRecorder;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;
  List<QuizQuestion> quizOf(String id) => lesson(id).quiz!.questions;

  Future<void> frames(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<LearningProgress> open(WidgetTester tester, String lessonId) async {
    tester.view.physicalSize = const Size(360, 760);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(
      catalog,
      ProgressSnapshot(lessons: {
        lessonId: LessonProgress(partsDone: lesson(lessonId).partsCount, completed: true),
      }),
    );
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: progress,
      child: MaterialApp(
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
      builder: (_) => QuizPlayerScreen(lessonId: lessonId, random: Random(1), recorder: FakeRecorder()),
    ));
    await frames(tester);
    return progress;
  }

  Finder primary() => find.byType(FilledButton).last;

  Future<void> press(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pump();
    await tester.tap(f);
    await frames(tester);
  }

  bool hasTimer(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .any((t) => RegExp(r'^\d\d:\d\d$').hasMatch(t.data ?? ''));

  /// The [index]th tile of a Q12 sentence (a word may appear twice).
  Finder tileOf(SpotMistakeData q, int index) {
    final word = q.tiles[index];
    final before = q.tiles.take(index).where((w) => w == word).length;
    return find.text(word).at(before);
  }

  /// Answers the question on screen right, presses the primary button and closes the sheet.
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
      case TypeAnswerData t:
        await tester.enterText(find.byType(TextField), t.accepted.first);
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
    await press(tester, primary());
    if (q is! SpeakingData) await press(tester, find.text('Continue').last);
  }

  Future<QuizQuestion> goTo(WidgetTester tester, String lessonId, int index) async {
    await open(tester, lessonId);
    final qs = quizOf(lessonId);
    for (final q in qs.take(index)) {
      await answerRight(tester, q);
    }
    return qs[index];
  }

  group('Q12 spot the mistake', () {
    testWidgets('right: the tile shows the fix; no timer', (tester) async {
      final q = await goTo(tester, 'a01', 5) as SpotMistakeData;
      expect(find.text('Spot the mistake'), findsOneWidget);
      expect(find.text('Tap the wrong word.'), findsOneWidget);
      expect(find.text('One word in this sentence is wrong.'), findsOneWidget);
      expect(find.text('Meaning in Filipino'), findsOneWidget);
      expect(find.text('Sinulatan ko si Lola.'), findsOneWidget);
      for (final w in q.tiles) {
        expect(find.text(w), findsOneWidget, reason: w);
      }
      expect(hasTimer(tester), isFalse);
      expect(tester.widget<FilledButton>(primary()).onPressed, isNull, reason: 'Check waits for a tap');

      await press(tester, tileOf(q, q.wrongIndex));
      await press(tester, primary());
      expect(find.text('Correct!'), findsOneWidget);
      expect(find.text('ko'), findsOneWidget, reason: 'the tapped tile now shows the fix');
      expect(find.text('ako'), findsNothing);
    });

    testWidgets('wrong: Not quite with the fix; the mistake tile gets the fix chip', (tester) async {
      final q = await goTo(tester, 'a01', 5) as SpotMistakeData;
      await press(tester, tileOf(q, 2)); // "si"
      await press(tester, primary());
      expect(find.text('Not quite'), findsOneWidget);
      // Fix chip under the mistake + the answer on the sheet.
      expect(find.text('ko'), findsNWidgets(2));
      expect(find.text('ako'), findsOneWidget, reason: 'the mistake stays, struck through');
    });

    testWidgets('a two-word fix (a06 "Gulpi lang") on the sheet', (tester) async {
      final qs = quizOf('a06');
      final index = qs.indexWhere((q) => q is SpotMistakeData && q.fix == 'Gulpi lang');
      final q = await goTo(tester, 'a06', index) as SpotMistakeData;
      await press(tester, tileOf(q, (q.wrongIndex + 1) % q.tiles.length));
      await press(tester, primary());
      expect(find.text('Gulpi lang'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('Q13 passage set', () {
    testWidgets('read: Question 1 of 3 with the story, then Show story folded on 2 and 3', (tester) async {
      final q1 = await goTo(tester, 'a06', 10) as PassageSetData;
      expect(q1.setIndex, 1);
      expect(find.text('Question 1 of 3'), findsOneWidget);
      expect(find.text('Reading'), findsOneWidget);
      expect(find.text('Read the story'), findsOneWidget);
      expect(find.text(q1.passage.first.hil, findRichText: true), findsOneWidget);
      expect(find.text('11 / 15'), findsOneWidget, reason: 'the quiz position stays');
      expect(hasTimer(tester), isFalse);
      await answerRight(tester, q1);

      expect(find.text('Question 2 of 3'), findsOneWidget);
      expect(find.text('Show story'), findsOneWidget);
      expect(find.text(q1.passage.first.hil, findRichText: true), findsNothing);
      await press(tester, find.text('Show story'));
      expect(find.text('Hide story'), findsOneWidget);
      expect(find.text(q1.passage.first.hil, findRichText: true), findsOneWidget);
      expect(find.text('12 / 15'), findsOneWidget);
    });

    testWidgets('listen without clips: the conversation as text with Audio coming soon (a08)', (tester) async {
      final q = await goTo(tester, 'a08', 10) as PassageSetData;
      expect(q.mode, ReadAnswerMode.listen);
      expect(find.text('Listening'), findsOneWidget);
      expect(find.text('Question 1 of 3'), findsOneWidget);
      expect(find.text('Read the conversation'), findsOneWidget);
      expect(find.text('Audio coming soon'), findsOneWidget);
      expect(find.byType(AudioButton), findsNothing);
      expect(find.text('${q.passage.first.speaker}: ${q.passage.first.hil}', findRichText: true), findsOneWidget);
      await answerRight(tester, q);
      expect(find.text('Show story'), findsOneWidget);
      expect(find.text('Audio coming soon'), findsOneWidget);
    });
  });

  testWidgets('every Advanced quiz passes when every answer is right', (tester) async {
    for (final l in catalog.levels[2].lessons) {
      final progress = await open(tester, l.id);
      for (final q in quizOf(l.id)) {
        await answerRight(tester, q);
        expect(tester.takeException(), isNull, reason: '${l.id} ${q.id}');
      }
      await frames(tester);
      expect(find.text('Perpekto!'), findsOneWidget, reason: l.id);
      expect(progress.progressFor(l.id).passed, isTrue, reason: l.id);
      final next = catalog.nextLesson(l.id);
      expect(find.text(next == null ? 'Advanced complete!' : 'Lesson ${next.order} unlocked'), findsOneWidget,
          reason: l.id);
    }
  });
}
