// S03 Lesson complete, S04 Quiz result and S05 Quiz review (step 5).

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/learning_routes.dart';
import 'package:hibalo_app/learning/logic/quiz_logic.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/screens/learn_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_complete_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_detail_screen.dart';
import 'package:hibalo_app/learning/screens/lesson_player_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_player_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_result_screen.dart';
import 'package:hibalo_app/learning/screens/quiz_review_screen.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;
  List<QuizQuestion> quizOf(String id) => lesson(id).quiz!.questions;
  Lesson lastBeginner() => catalog.levels.first.lessons.last;

  Future<void> frames(WidgetTester tester, [int n = 6]) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Shows [screen] over a stand-in S01 ("LEARN"), on a small phone.
  Future<LearningProgress> show(
    WidgetTester tester,
    Widget screen, {
    Map<String, LessonProgress> lessons = const {},
    Set<String> paid = const {},
    int xp = 0,
    Size size = const Size(360, 760),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final progress = LearningProgress.ready(catalog, ProgressSnapshot(lessons: {...lessons}, paid: {...paid}, xp: xp));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: progress,
        child: MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          home: const Scaffold(body: Text('HOME')),
        ),
      ),
    );
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(
      MaterialPageRoute<void>(
        settings: const RouteSettings(name: LearningRoutes.learnRoute),
        builder: (_) => const Scaffold(body: Text('LEARN')),
      ),
    );
    nav.push(MaterialPageRoute<void>(builder: (_) => screen));
    await frames(tester);
    return progress;
  }

  // ── S03 ────────────────────────────────────────────────────────────────

  group('S03 Lesson complete', () {
    testWidgets('words lesson: +20 XP, N New words, quiz and Back to lessons', (tester) async {
      await show(tester, const LessonCompleteScreen(lessonId: 'b02', xpJustPaid: true));
      expect(find.text('Lesson complete!'), findsOneWidget);
      expect(find.text('You finished Lesson 2: ${lesson('b02').title}.'), findsOneWidget);
      expect(find.text('+20'), findsOneWidget);
      expect(find.text('XP'), findsOneWidget);
      expect(find.text('${lesson('b02').items.length}'), findsOneWidget);
      expect(find.text('New words'), findsOneWidget);
      expect(find.text('Take the lesson quiz'), findsOneWidget);
      expect(find.textContaining('unlocked'), findsNothing);
      expect(tester.takeException(), isNull, reason: 'no overflow on a small phone');

      await tester.tap(find.text('Back to lessons'));
      await tester.pumpAndSettle();
      expect(find.text('LEARN'), findsOneWidget);
    });

    testWidgets('reopened: "20 XP · Already earned"', (tester) async {
      await show(tester, const LessonCompleteScreen(lessonId: 'b02', xpJustPaid: false));
      expect(find.text('20'), findsOneWidget);
      expect(find.text('XP · Already earned'), findsOneWidget);
      expect(find.text('+20'), findsNothing);
    });

    testWidgets('lesson XP is paid once: finishing again shows Already earned', (tester) async {
      final progress = await show(
        tester,
        const LessonPlayerScreen(lessonId: 'b02', startPart: 11, review: true),
        lessons: {'b02': LessonProgress(partsDone: 12, completed: true, completedAt: DateTime(2026))},
        paid: {LearningProgress.lessonPaidId('b02')},
        xp: 20,
      );
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(find.text('Lesson complete!'), findsOneWidget);
      expect(find.text('XP · Already earned'), findsOneWidget);
      expect(progress.xp, 20);
    });

    testWidgets('a Quiz pending row on S01 opens S03', (tester) async {
      await show(
        tester,
        const LearnScreen(),
        lessons: {
          'b01': const LessonProgress(partsDone: 8, completed: true),
          'b02': const LessonProgress(partsDone: 12, completed: true),
        },
        paid: {LearningProgress.lessonPaidId('b02')},
        size: const Size(375, 2400),
      );
      await tester.tap(find.text(lesson('b02').title));
      await tester.pumpAndSettle();
      expect(find.byType(LessonCompleteScreen), findsOneWidget);
      expect(find.text('XP · Already earned'), findsOneWidget);
    });

    testWidgets('Letters version: 19 Letters, Lesson 2 unlocked, Continue to Lesson 2', (tester) async {
      await show(
        tester,
        const LessonCompleteScreen(lessonId: 'b01', xpJustPaid: true),
        lessons: {'b01': const LessonProgress(partsDone: 8, completed: true)},
      );
      expect(find.text('You finished Lesson 1: ${lesson('b01').title}.'), findsOneWidget);
      expect(find.text('+20'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
      expect(find.text('Letters'), findsOneWidget);
      expect(find.text('Lesson 2 unlocked'), findsOneWidget);
      expect(find.text('Take the lesson quiz'), findsNothing);

      await tester.tap(find.text('Continue to Lesson 2'));
      await tester.pumpAndSettle();
      final detail = tester.widget<LessonDetailScreen>(find.byType(LessonDetailScreen));
      expect(detail.lessonId, 'b02');
      // Back from S02 goes to S01.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('LEARN'), findsOneWidget);
    });
  });

  // ── S04 ────────────────────────────────────────────────────────────────

  QuizAttemptResult result(int correct, int total, {int xp = 0, bool? lessonPassed}) {
    final passed = correct / total >= 0.8 - 1e-9;
    return QuizAttemptResult(
      correct: correct,
      total: total,
      xpEarned: xp,
      passed: passed,
      lessonPassed: lessonPassed ?? passed,
    );
  }

  List<AnsweredQuestion> allRight(String id) => [
    for (final q in quizOf(id))
      AnsweredQuestion(
        question: q,
        outcome: q.scored ? QuestionOutcome.right : QuestionOutcome.practice,
        answer: correctAnswerText(q),
        pairsRight: q is MatchPairsData ? q.pairs.length : null,
      ),
  ];

  group('S04 Quiz result', () {
    testWidgets('Perpekto! (100%): Lesson 3 unlocked, Continue, Review answers', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(8, 8, xp: 80), answers: allRight('b02')));
      expect(find.text('Perpekto!'), findsOneWidget);
      expect(find.text('You got 8 out of 8 correct!'), findsOneWidget);
      expect(find.text('+80 XP'), findsOneWidget);
      expect(find.text('XP earned'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('Lesson 3 unlocked'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Review answers'), findsOneWidget);
      expect(find.text('Try again'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('LEARN'), findsOneWidget);
    });

    testWidgets('Maayo gid! (≥ 80%)', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(7, 8, xp: 70), answers: allRight('b02')));
      expect(find.text('Maayo gid!'), findsOneWidget);
      expect(find.text('You got 7 out of 8 correct!'), findsOneWidget);
      expect(find.text('88%'), findsOneWidget);
      expect(find.text('Lesson 3 unlocked'), findsOneWidget);
    });

    testWidgets('Keep practicing (< 80%): lock chip and Try again', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(4, 8, xp: 40), answers: allRight('b02')));
      expect(find.text('Keep practicing'), findsOneWidget);
      expect(find.text('You got 4 out of 8 correct.'), findsOneWidget);
      expect(find.text('+40 XP'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('Pass this quiz to unlock Lesson 3'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('XP earned shows only newly paid XP (+0 XP on a retake)', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(8, 8), answers: allRight('b02')));
      expect(find.text('+0 XP'), findsOneWidget);
    });

    testWidgets('after the last Beginner lesson: "Beginner complete!"', (tester) async {
      final last = lastBeginner();
      await show(tester, QuizResultScreen(lessonId: last.id, result: result(8, 8), answers: allRight(last.id)));
      expect(find.text('Beginner complete!'), findsOneWidget);
      expect(find.textContaining('Lesson ${last.order + 1}'), findsNothing);
    });

    testWidgets('last Beginner lesson not passed: "Pass this quiz to complete Beginner"', (tester) async {
      final last = lastBeginner();
      await show(tester, QuizResultScreen(lessonId: last.id, result: result(2, 8), answers: allRight(last.id)));
      expect(find.text('Pass this quiz to complete Beginner'), findsOneWidget);
    });

    testWidgets('a weaker retake of a passed quiz keeps "Lesson 3 unlocked"', (tester) async {
      await show(
        tester,
        QuizResultScreen(lessonId: 'b02', result: result(4, 8, lessonPassed: true), answers: allRight('b02')),
      );
      expect(find.text('Keep practicing'), findsOneWidget);
      expect(find.text('Lesson 3 unlocked'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  // ── S05 ────────────────────────────────────────────────────────────────

  group('S05 Quiz review', () {
    List<AnsweredQuestion> mixed() {
      final qs = quizOf('b02');
      return [
        for (final (i, q) in qs.indexed)
          switch (q) {
            SpeakingData() || OpenAnswerData() => AnsweredQuestion(question: q, outcome: QuestionOutcome.practice),
            MatchPairsData() => AnsweredQuestion(question: q, outcome: QuestionOutcome.wrong, pairsRight: 2),
            _ when i == 0 => AnsweredQuestion(question: q, outcome: QuestionOutcome.wrong, answer: 'Pasayloa'),
            _ when i == 1 => AnsweredQuestion(question: q, outcome: QuestionOutcome.timeout),
            _ => AnsweredQuestion(question: q, outcome: QuestionOutcome.right, answer: correctAnswerText(q)),
          },
      ];
    }

    testWidgets('rows in quiz order: right, wrong, time up, pairs and practice', (tester) async {
      final qs = quizOf('b02');
      await show(
        tester,
        QuizReviewScreen(result: result(4, 8), answers: mixed()),
        size: const Size(375, 2400),
      );
      expect(find.text('Review answers'), findsOneWidget);
      expect(find.text('You got 4 out of 8 correct.'), findsOneWidget);

      // Every question, numbered as in the quiz.
      final first = qs[0] as MultipleChoiceData;
      expect(find.text('1. ${first.prompt}'), findsOneWidget);
      expect(find.text('2. Listening: ${(qs[1] as ListeningData).prompt}'), findsOneWidget);
      for (var n = 1; n <= qs.length; n++) {
        expect(find.textContaining(RegExp('^$n\\. ')), findsOneWidget, reason: 'row $n');
      }

      // Wrong: red ✕, the answer given and the right one.
      expect(find.text('Your answer: Pasayloa'), findsOneWidget);
      expect(find.text('Correct answer: ${first.correctOption}'), findsOneWidget);
      // Timed out.
      expect(find.text("Your answer: (time's up)"), findsOneWidget);
      // Q07.
      final pairs = qs.whereType<MatchPairsData>().first.pairs.length;
      expect(find.text('Your answer: 2 of $pairs pairs'), findsOneWidget);
      expect(find.text('Correct answer: $pairs of $pairs pairs'), findsOneWidget);
      // Practice rows.
      final practice = qs.where((q) => !q.scored).length;
      expect(find.text('Practice'), findsNWidgets(practice));
      expect(find.text('Saved for practice only. No score.'), findsNWidgets(practice));
      // Right rows are green and show the answer.
      final type = qs.whereType<TypeAnswerData>().first;
      expect(find.text('Your answer: ${type.accepted.first}'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNWidgets(3));
    });

    testWidgets('failed version: Try again + Back to lessons; Back returns to S04', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(4, 8), answers: mixed()));
      await tester.tap(find.text('Review answers'));
      await tester.pumpAndSettle();
      expect(find.byType(QuizReviewScreen), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Back to lessons'), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Keep practicing'), findsOneWidget);

      await tester.tap(find.text('Review answers'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Back to lessons'));
      await tester.pumpAndSettle();
      expect(find.text('LEARN'), findsOneWidget);
    });

    testWidgets('passed version: Continue + Back to lessons, no Try again', (tester) async {
      await show(tester, QuizResultScreen(lessonId: 'b02', result: result(8, 8), answers: allRight('b02')));
      await tester.tap(find.text('Review answers'));
      await tester.pumpAndSettle();
      expect(find.text('Try again'), findsNothing);
      expect(find.text('Back to lessons'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('LEARN'), findsOneWidget);
    });
  });

  // ── Try again ──────────────────────────────────────────────────────────

  testWidgets('Try again restarts at question 1 with a fresh score and a new shuffle', (tester) async {
    var seed = 0;
    final saved = QuizPlayerScreen.newRandom;
    QuizPlayerScreen.newRandom = () => Random(++seed);
    addTearDown(() => QuizPlayerScreen.newRandom = saved);

    final progress = await show(
      tester,
      QuizResultScreen(lessonId: 'b02', result: result(4, 8), answers: allRight('b02')),
      lessons: {'b02': const LessonProgress(partsDone: 12, completed: true, bestScore: 4)},
    );

    List<String> optionsOnScreen() {
      final q = quizOf('b02').first as MultipleChoiceData;
      // The options, top to bottom.
      return [...q.options]
        ..sort((a, b) => tester.getTopLeft(find.text(a).first).dy.compareTo(tester.getTopLeft(find.text(b).first).dy));
    }

    // From S05: Try again pops back to S04, which restarts the quiz.
    await tester.tap(find.text('Review answers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await frames(tester);
    expect(find.byType(QuizPlayerScreen), findsOneWidget);
    expect(find.byType(QuizResultScreen), findsNothing);
    expect(find.text('1 / 9'), findsOneWidget);
    expect(find.text('00:30'), findsOneWidget);
    final firstOrder = optionsOnScreen();

    // Leave, then start again: another new shuffle (seed 2).
    await tester.tap(find.byTooltip('Leave the quiz'));
    await frames(tester);
    await tester.tap(find.text('Leave'));
    await frames(tester);
    final nav = tester.state<NavigatorState>(find.byType(Navigator));
    nav.push(MaterialPageRoute<void>(builder: (_) => const QuizPlayerScreen(lessonId: 'b02')));
    await frames(tester);
    expect(seed, 2, reason: 'each attempt makes its own shuffle');
    expect(optionsOnScreen(), isNot(equals(firstOrder)));
    expect(progress.progressFor('b02').bestScore, 4, reason: 'the old best score is kept');
  });
}
