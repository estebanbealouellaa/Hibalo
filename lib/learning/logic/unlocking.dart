import '../models/catalog.dart';
import '../models/progress.dart';

enum LessonRowState {
  /// Finished (and its quiz passed, if it has one).
  completed,

  current,

  /// Finished, but the quiz isn't passed yet.
  quizPending,

  locked,
}

enum LessonDetailState { notStarted, inProgress, completed }

/// Unlocking and lesson states (LEARNING_BEHAVIOR §1.9), worked out from the
/// lessons and the saved progress. No saving happens here.
class LearningRules {
  LearningRules(this.catalog, this.progress);

  final LessonCatalog catalog;

  /// Lesson id → progress (missing = never opened).
  final Map<String, LessonProgress> progress;

  LessonProgress progressFor(String lessonId) =>
      progress[lessonId] ?? LessonProgress.empty;

  /// Finished, with the quiz passed when there is one.
  bool isLessonDone(Lesson lesson) {
    final p = progressFor(lesson.id);
    return p.completed && (!lesson.hasQuiz || p.passed);
  }

  /// A level is finished when every lesson in it is done. A level with no
  /// lessons yet is never finished, so the level after it stays locked.
  bool isLevelFinished(Level level) =>
      level.lessons.isNotEmpty && level.lessons.every(isLessonDone);

  bool isLevelUnlocked(Level level) {
    final after = level.unlockAfterLevel;
    if (after == null) return true;
    final before = catalog.levels.where((l) => l.id == after).firstOrNull;
    return before != null && isLevelFinished(before);
  }

  /// The level that has to be finished first, or null if there is none.
  Level? blockingLevel(Level level) {
    final after = level.unlockAfterLevel;
    if (after == null) return null;
    return catalog.levels.where((l) => l.id == after).firstOrNull;
  }

  bool isLessonUnlocked(Lesson lesson) {
    final level = catalog.levelOf(lesson.id);
    if (level != null && !isLevelUnlocked(level)) return false;
    final after = lesson.unlock.after;
    if (after == null) return true;
    final before = progressFor(after);
    return switch (lesson.unlock.needs) {
      UnlockNeed.complete => before.completed,
      UnlockNeed.passQuiz => before.passed,
      null => true,
    };
  }

  LessonRowState rowState(Lesson lesson) {
    final p = progressFor(lesson.id);
    if (p.completed) {
      return lesson.hasQuiz && !p.passed
          ? LessonRowState.quizPending
          : LessonRowState.completed;
    }
    return isLessonUnlocked(lesson) ? LessonRowState.current : LessonRowState.locked;
  }

  LessonDetailState detailState(Lesson lesson) {
    final p = progressFor(lesson.id);
    if (p.completed) return LessonDetailState.completed;
    if (p.partsDone > 0) return LessonDetailState.inProgress;
    return LessonDetailState.notStarted;
  }

  int partsDone(Lesson lesson) {
    final p = progressFor(lesson.id);
    if (p.completed) return lesson.partsCount;
    return p.partsDone.clamp(0, lesson.partsCount);
  }

  /// Where "Continue lesson" opens: the first unfinished part (0-based).
  int firstUnfinishedPart(Lesson lesson) {
    final done = partsDone(lesson);
    return done >= lesson.partsCount ? 0 : done;
  }

  /// The lesson whose `unlock.after` this lesson waits for.
  Lesson? requiredLesson(Lesson lesson) {
    final after = lesson.unlock.after;
    return after == null ? null : catalog.lessonById(after);
  }
}
