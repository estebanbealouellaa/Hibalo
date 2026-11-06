// Quiz rules without a screen: typed answers, shuffling, building sentences, scoring, the timer and saving attempts.

import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/logic/quiz_logic.dart';
import 'package:hibalo_app/learning/logic/quiz_timer.dart';
import 'package:hibalo_app/learning/logic/unlocking.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/models/questions.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;

  group('typed answers (Q04, Q08)', () {
    test('ignore capitals, spaces at the ends and . , ! ?', () {
      const accepted = ['Maayong hapon'];
      expect(matchesAccepted('Maayong hapon', accepted), isTrue);
      expect(matchesAccepted('  maayong HAPON  ', accepted), isTrue);
      expect(matchesAccepted('Maayong hapon!', accepted), isTrue);
      expect(matchesAccepted('Maayong, hapon.', accepted), isTrue);
      expect(matchesAccepted('Maayong hapon?!', accepted), isTrue);
    });

    test('anything else is wrong, and an empty answer never matches', () {
      const accepted = ['Maayong hapon'];
      expect(matchesAccepted('Maayong hapo', accepted), isFalse);
      expect(matchesAccepted('Maayonghapon', accepted), isFalse);
      expect(matchesAccepted('Maayong-hapon', accepted), isFalse); // hyphens count
      expect(matchesAccepted('   ', accepted), isFalse);
      expect(matchesAccepted('', ['']), isFalse);
    });

    test('every accepted spelling counts', () {
      const accepted = ['Taga-diin ka', 'Taga diin ka'];
      expect(matchesAccepted('taga diin ka?', accepted), isTrue);
      expect(matchesAccepted('Taga-diin ka', accepted), isTrue);
    });
  });

  group('shuffling', () {
    test('a seed gives the same order every time', () {
      final a = shuffledOrder(6, Random(7));
      final b = shuffledOrder(6, Random(7));
      expect(a, b);
      expect(a.toSet(), {0, 1, 2, 3, 4, 5}); // every item exactly once
    });

    test('the right answer is tracked to where it lands', () {
      final order = shuffledOrder(4, Random(3));
      final q = lesson('b02').quiz!.questions.first as MultipleChoiceData;
      final shownAt = positionOf(q.answer, order);
      expect(order[shownAt], q.answer);
      expect(q.options[order[shownAt]], q.correctOption);
    });

    test('shuffling off keeps the JSON order', () {
      expect(shuffledOrder(4, Random(1), shuffle: false), [0, 1, 2, 3]);
    });

    test('over many seeds, the right answer does not stay first', () {
      final firsts = {for (var s = 0; s < 40; s++) shuffledOrder(4, Random(s)).first};
      expect(firsts.length, greaterThan(1));
    });
  });

  test('build the sentence: the tiles must spell the answer in order', () {
    final q = lesson('b02').quiz!.questions.whereType<BuildSentenceData>().first;
    List<int> picks(List<String> words) => [for (final w in words) q.tiles.indexOf(w)];
    expect(isRightSentence(q, picks(q.answer)), isTrue);
    expect(isRightSentence(q, picks(q.answer.reversed.toList())), isFalse);
    expect(isRightSentence(q, picks(q.answer.sublist(1))), isFalse);
  });

  test('score: unscored questions (speaking, open answer) are left out', () {
    final questions = lesson('b02').quiz!.questions;
    final scored = questions.where((q) => q.scored).toList();
    expect(questions.whereType<SpeakingData>(), isNotEmpty);
    final outcomes = {
      for (final q in questions)
        q.id: q.scored ? QuestionOutcome.right : QuestionOutcome.practice,
    };
    outcomes[scored[0].id] = QuestionOutcome.wrong;
    outcomes[scored[1].id] = QuestionOutcome.timeout; // counts as wrong
    final score = QuizScore.of(questions, outcomes);
    expect(score.total, scored.length);
    expect(score.correct, scored.length - 2);
    expect(score.passes(0.8), score.correct / score.total >= 0.8);
  });

  test('pass mark: 80% passes, just under fails', () {
    expect(const QuizScore(correct: 8, total: 10).passes(0.8), isTrue);
    expect(const QuizScore(correct: 7, total: 10).passes(0.8), isFalse);
    expect(const QuizScore(correct: 0, total: 0).passes(0.8), isFalse);
  });

  group('timer', () {
    testWidgets('counts down, pauses, resumes and times out once', (tester) async {
      var timeouts = 0;
      final timer = QuizTimer(seconds: 5, onTimeout: () => timeouts++)..start();
      addTearDown(timer.dispose);
      expect(timer.label, '00:05');

      await tester.pump(const Duration(seconds: 2));
      expect(timer.secondsLeft, 3);

      timer.pause();
      await tester.pump(const Duration(seconds: 10));
      expect(timer.secondsLeft, 3, reason: 'paused while a sheet or S06 is open');

      timer.pause(); // a sheet over the pop-up
      timer.resume();
      await tester.pump(const Duration(seconds: 2));
      expect(timer.secondsLeft, 3, reason: 'still one pause left');

      timer.resume();
      await tester.pump(const Duration(seconds: 3));
      expect(timer.secondsLeft, 0);
      expect(timeouts, 1);
      await tester.pump(const Duration(seconds: 5));
      expect(timeouts, 1);
    });

    testWidgets('stop() ends it without a timeout', (tester) async {
      var timeouts = 0;
      final timer = QuizTimer(seconds: 3, onTimeout: () => timeouts++)..start();
      addTearDown(timer.dispose);
      await tester.pump(const Duration(seconds: 1));
      timer.stop();
      await tester.pump(const Duration(seconds: 5));
      expect(timer.secondsLeft, 2);
      expect(timeouts, 0);
    });
  });

  group('saving an attempt', () {
    LearningProgress progressWith(Map<String, LessonProgress> lessons) =>
        LearningProgress.ready(catalog, ProgressSnapshot(lessons: lessons));

    test('pays 10 XP per right scored question, only the first time', () async {
      final b02 = lesson('b02');
      final progress = progressWith({'b02': const LessonProgress(partsDone: 12, completed: true)});
      final ids = b02.quiz!.scoredQuestions.map((q) => q.id).toList();

      final first = await progress.saveQuizResult(b02,
          correct: 3, total: ids.length, rightIds: ids.take(3));
      expect(first.xpEarned, 30);
      expect(progress.xp, 30);

      // A retry: the same three pay nothing, one new right one pays 10.
      final second = await progress.saveQuizResult(b02,
          correct: 4, total: ids.length, rightIds: ids.take(4));
      expect(second.xpEarned, 10);
      expect(progress.xp, 40);
    });

    test('passing unlocks the next lesson and keeps the best score', () async {
      final b02 = lesson('b02');
      final progress = progressWith({
        'b01': const LessonProgress(partsDone: 8, completed: true),
        'b02': const LessonProgress(partsDone: 12, completed: true),
      });
      final total = b02.quiz!.scoredQuestions.length;
      expect(progress.rules.rowState(lesson('b03')), LessonRowState.locked);

      final fail = await progress.saveQuizResult(b02, correct: total - 3, total: total, rightIds: const []);
      expect(fail.passed, isFalse);
      expect(progress.rules.rowState(lesson('b03')), LessonRowState.locked);

      final pass = await progress.saveQuizResult(b02, correct: total, total: total, rightIds: const []);
      expect(pass.passed, isTrue);
      expect(progress.progressFor('b02').bestScore, total);
      expect(progress.rules.rowState(lesson('b03')), LessonRowState.current);

      // A worse retry keeps the best score and the pass.
      await progress.saveQuizResult(b02, correct: 1, total: total, rightIds: const []);
      expect(progress.progressFor('b02').bestScore, total);
      expect(progress.progressFor('b02').passed, isTrue);
      expect(progress.streak, 1);
    });
  });
}
