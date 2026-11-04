// Unlocking, lesson states and the streak rule (LEARNING_BEHAVIOR §1.9, §1.11).
//   flutter test test/learning/unlocking_test.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/logic/streak.dart';
import 'package:hibalo_app/learning/logic/unlocking.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  late List<Lesson> lessons;

  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
    lessons = catalog.levels.first.lessons;
  });

  LearningRules rules(Map<String, LessonProgress> progress) =>
      LearningRules(catalog, progress);

  const done = LessonProgress(completed: true);
  const passed = LessonProgress(completed: true, passed: true, bestScore: 8);

  group('lessons', () {
    test('fresh start: only Lesson 1 is open', () {
      final r = rules({});
      expect(r.rowState(lessons[0]), LessonRowState.current);
      for (final lesson in lessons.skip(1)) {
        expect(r.rowState(lesson), LessonRowState.locked, reason: lesson.id);
      }
    });

    test('finishing Lesson 1 (no quiz) unlocks Lesson 2', () {
      final r = rules({'b01': done});
      expect(r.rowState(lessons[0]), LessonRowState.completed);
      expect(r.rowState(lessons[1]), LessonRowState.current);
      expect(r.rowState(lessons[2]), LessonRowState.locked);
    });

    test('a finished lesson with its quiz not passed is Quiz pending', () {
      final r = rules({'b01': done, 'b02': done});
      expect(r.rowState(lessons[1]), LessonRowState.quizPending);
      expect(r.rowState(lessons[2]), LessonRowState.locked);
    });

    test('passing the quiz unlocks the next lesson', () {
      final r = rules({'b01': done, 'b02': passed});
      expect(r.rowState(lessons[1]), LessonRowState.completed);
      expect(r.rowState(lessons[2]), LessonRowState.current);
    });

    test('lock messages point at the right lesson', () {
      final r = rules({});
      expect(r.requiredLesson(lessons[1])!.order, 1);
      expect(lessons[1].unlock.needs, UnlockNeed.complete);
      expect(r.requiredLesson(lessons[2])!.order, 2);
      expect(lessons[2].unlock.needs, UnlockNeed.passQuiz);
    });
  });

  group('Lesson Detail states', () {
    test('not started, in progress, completed', () {
      expect(rules({}).detailState(lessons[1]), LessonDetailState.notStarted);

      final inProgress = rules({'b02': const LessonProgress(partsDone: 4)});
      expect(inProgress.detailState(lessons[1]), LessonDetailState.inProgress);
      expect(inProgress.partsDone(lessons[1]), 4);
      expect(inProgress.firstUnfinishedPart(lessons[1]), 4);

      final completed = rules({'b02': passed});
      expect(completed.detailState(lessons[1]), LessonDetailState.completed);
      expect(completed.partsDone(lessons[1]), lessons[1].partsCount);
    });

    test('a saved count larger than the lesson is clamped', () {
      final r = rules({'b02': const LessonProgress(partsDone: 99)});
      expect(r.partsDone(lessons[1]), lessons[1].partsCount);
      expect(r.firstUnfinishedPart(lessons[1]), 0);
    });
  });

  group('levels', () {
    Level level(String id) => catalog.levels.firstWhere((l) => l.id == id);

    test('only Beginner is open at first', () {
      final r = rules({});
      expect(r.isLevelUnlocked(level('beginner')), isTrue);
      expect(r.isLevelUnlocked(level('intermediate')), isFalse);
      expect(r.isLevelUnlocked(level('advanced')), isFalse);
      expect(r.blockingLevel(level('intermediate'))!.id, 'beginner');
    });

    test('Intermediate opens when every Beginner quiz is passed', () {
      final almost = {
        for (final l in lessons) l.id: l.hasQuiz ? passed : done,
      }..['b13'] = done; // last quiz not passed yet
      expect(rules(almost).isLevelUnlocked(level('intermediate')), isFalse);

      final all = {for (final l in lessons) l.id: l.hasQuiz ? passed : done};
      final r = rules(all);
      expect(r.isLevelUnlocked(level('intermediate')), isTrue);
      // Intermediate has no lessons yet, so it can't be finished.
      expect(r.isLevelUnlocked(level('advanced')), isFalse);
    });
  });

  group('streak', () {
    final today = DateTime(2026, 11, 5, 9);

    test('kept when the last active day was today or yesterday', () {
      expect(currentStreak(savedStreak: 3, lastActiveDate: '2026-11-05', today: today), 3);
      expect(currentStreak(savedStreak: 3, lastActiveDate: '2026-11-04', today: today), 3);
    });

    test('reset after a whole missed day', () {
      expect(currentStreak(savedStreak: 3, lastActiveDate: '2026-11-03', today: today), 0);
      expect(currentStreak(savedStreak: 3, lastActiveDate: null, today: today), 0);
    });

    test('works across a month and a year', () {
      expect(currentStreak(savedStreak: 5, lastActiveDate: '2026-10-31',
          today: DateTime(2026, 11, 1)), 5);
      expect(currentStreak(savedStreak: 5, lastActiveDate: '2025-12-31',
          today: DateTime(2026, 1, 1)), 5);
      expect(dayKey(DateTime(2026, 3, 7)), '2026-03-07');
    });
  });

  test('progress survives a save and load as JSON', () {
    final snapshot = ProgressSnapshot(
      lessons: {
        'b01': LessonProgress(completed: true, completedAt: DateTime(2026, 11, 5)),
        'b02': const LessonProgress(partsDone: 4, bestScore: 6),
      },
      xp: 45,
      streak: 2,
      lastActiveDate: '2026-11-05',
      paid: {'b02_q1'},
    );
    final copy = ProgressSnapshot.fromJson(snapshot.toJson());
    expect(copy.lessons['b01']!.completed, isTrue);
    expect(copy.lessons['b01']!.completedAt, DateTime(2026, 11, 5));
    expect(copy.lessons['b02']!.partsDone, 4);
    expect(copy.lessons['b02']!.bestScore, 6);
    expect(copy.xp, 45);
    expect(copy.streak, 2);
    expect(copy.lastActiveDate, '2026-11-05');
    expect(copy.paid, {'b02_q1'});
    expect(copy.lessonsCompleted, 1);
  });
}
