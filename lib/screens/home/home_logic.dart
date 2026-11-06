import '../../learning/logic/unlocking.dart';
import '../../learning/models/catalog.dart';

/// What the Home "Continue" card shows (LEARNING_BEHAVIOR §6).
enum ContinueKind {
  /// No lesson started yet: "Start Lesson 1" → Lesson 1's S02 (Figma
  /// "Home · First time").
  firstTime,

  /// A lesson has finished parts but isn't complete: "Continue lesson" →
  /// the first unfinished part.
  inProgress,

  /// The next unlocked lesson isn't started: "Start Lesson N" → its S02.
  notStarted,

  /// Every part is done but the quiz isn't passed: "Take the quiz" → S03.
  quizPending,

  allDone,
}

class ContinuePick {
  const ContinuePick(this.kind, this.lesson, {this.level, this.partsDone = 0});

  final ContinueKind kind;

  /// The lesson the card is about (the last lesson for [ContinueKind.allDone]).
  final Lesson lesson;
  final Level? level;

  final int partsDone;

  int get partsCount => lesson.partsCount;

  /// "Part X of Y": the next unfinished part, 1-based.
  int get nextPart => (partsDone + 1).clamp(1, partsCount);
}

/// Picks the card's lesson in course order: first time, in progress, next not started, quiz pending, else all done.
ContinuePick pickContinue(LessonCatalog catalog, LearningRules rules) {
  final lessons = catalog.allLessons;
  Level? levelOf(Lesson l) => catalog.levelOf(l.id);

  final started = lessons.any((l) {
    final p = rules.progressFor(l.id);
    return p.partsDone > 0 || p.completed;
  });
  if (!started) {
    final first = lessons.firstWhere(rules.isLessonUnlocked, orElse: () => lessons.first);
    return ContinuePick(ContinueKind.firstTime, first, level: levelOf(first));
  }

  for (final l in lessons) {
    final p = rules.progressFor(l.id);
    if (!p.completed && p.partsDone > 0 && rules.isLessonUnlocked(l)) {
      return ContinuePick(ContinueKind.inProgress, l, level: levelOf(l), partsDone: rules.partsDone(l));
    }
  }
  for (final l in lessons) {
    if (rules.rowState(l) == LessonRowState.current) {
      return ContinuePick(ContinueKind.notStarted, l, level: levelOf(l));
    }
  }
  for (final l in lessons) {
    if (rules.rowState(l) == LessonRowState.quizPending) {
      return ContinuePick(ContinueKind.quizPending, l, level: levelOf(l), partsDone: l.partsCount);
    }
  }
  final last = lessons.last;
  return ContinuePick(ContinueKind.allDone, last, level: levelOf(last), partsDone: last.partsCount);
}

/// One word from the lessons for each day: the same all day, a different
/// one the next day (the phone's date; every lesson's items in course order).
LessonItem? phraseOfTheDay(LessonCatalog catalog, DateTime now) {
  final items = [for (final l in catalog.allLessons) ...l.items];
  if (items.isEmpty) return null;
  // Days since 1 Jan 1970 on the phone's calendar (noon avoids DST edges).
  final day = DateTime.utc(now.year, now.month, now.day, 12).millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;
  return items[day % items.length];
}

String greetingFor(DateTime now) {
  if (now.hour < 12) return 'Maayong aga,';
  if (now.hour < 18) return 'Maayong hapon,';
  return 'Maayong gab-i,';
}
