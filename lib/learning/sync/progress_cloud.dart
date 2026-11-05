import '../models/progress.dart';

/// The cloud copy of a learner's progress (Firestore `users/{uid}` and its
/// `lessonProgress` subcollection), as read when they sign in.
class CloudProgress {
  CloudProgress({
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
    Set<String>? paid,
    Map<String, LessonProgress>? lessons,
  }) : paid = paid ?? {},
       lessons = lessons ?? {};

  final int xp;
  final int streak;
  final String? lastActiveDate;
  final Set<String> paid;
  final Map<String, LessonProgress> lessons;
}

/// One finished quiz attempt (`users/{uid}/quizAttempts/{attemptId}`).
class QuizAttemptRecord {
  const QuizAttemptRecord({
    required this.lessonId,
    required this.score,
    required this.total,
    required this.xpEarned,
    required this.date,
  });

  final String lessonId;

  /// Right answers among the scored questions.
  final int score;

  /// Scored questions in the quiz.
  final int total;
  final int xpEarned;

  /// When the attempt ended (phone clock).
  final DateTime date;

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'score': score,
    'total': total,
    'xpEarned': xpEarned,
    'date': date.toIso8601String(),
  };

  static QuizAttemptRecord? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final date = DateTime.tryParse('${json['date']}');
    final lessonId = json['lessonId'];
    if (date == null || lessonId is! String) return null;
    return QuizAttemptRecord(
      lessonId: lessonId,
      score: (json['score'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xpEarned'] as num?)?.toInt() ?? 0,
      date: date,
    );
  }
}

/// Everything one sync sends. Written as one batch: XP is added with
/// `FieldValue.increment` and paid ids with `FieldValue.arrayUnion`, never
/// with a transaction (transactions fail offline).
class CloudUpdate {
  const CloudUpdate({
    this.xpIncrement = 0,
    this.paidAdded = const [],
    required this.streak,
    required this.lastActiveDate,
    required this.lessonsCompleted,
    this.lessons = const {},
    this.attempts = const [],
  });

  final int xpIncrement;
  final List<String> paidAdded;
  final int streak;
  final String? lastActiveDate;
  final int lessonsCompleted;

  /// lessonProgress documents to write (whole document, merged).
  final Map<String, LessonProgress> lessons;

  /// quizAttempts documents to add.
  final List<QuizAttemptRecord> attempts;
}

/// Where synced progress goes. The real one is Firestore; tests use a fake.
abstract class ProgressCloud {
  /// Reads the learner's progress. Throws when it can't be read (offline
  /// with nothing cached); the merge is then tried again later.
  Future<CloudProgress> fetch(String uid);

  /// Queues [update] for [uid]. Returns at once: Firestore keeps the writes
  /// on the phone (offline persistence) and sends them when online.
  void write(String uid, CloudUpdate update);
}

/// The phone and cloud progress merged when a learner signs in (approved:
/// "Merge, keep the best").
class MergeResult {
  MergeResult({required this.snapshot, required this.update});

  /// The merged progress to keep on the phone.
  final ProgressSnapshot snapshot;

  /// What the cloud is missing.
  final CloudUpdate update;
}

/// Merges the phone's progress into the cloud's:
/// - per lesson: highest partsDone, completed if either, highest bestScore,
///   passed if either, earliest completedAt;
/// - paid ids: the union; XP = cloud XP + XP for ids only the phone had paid
///   (sent as an increment);
/// - streak: the one with the later lastActiveDate.
/// [xpOf] gives the XP a paid id is worth.
MergeResult mergeProgress({
  required ProgressSnapshot local,
  required CloudProgress cloud,
  required int Function(String paidId) xpOf,
}) {
  final phoneOnly = local.paid.difference(cloud.paid).toList()..sort();
  final extraXp = phoneOnly.fold<int>(0, (sum, id) => sum + xpOf(id));

  final lessons = <String, LessonProgress>{};
  final changed = <String, LessonProgress>{};
  for (final id in {...cloud.lessons.keys, ...local.lessons.keys}) {
    final c = cloud.lessons[id];
    final l = local.lessons[id];
    final merged = c == null
        ? l!
        : l == null
        ? c
        : mergeLesson(l, c);
    lessons[id] = merged;
    if (c == null || !sameLesson(c, merged)) changed[id] = merged;
  }

  final localDay = local.lastActiveDate;
  final cloudDay = cloud.lastActiveDate;
  final useLocalStreak =
      cloudDay == null ||
      (localDay != null && (localDay.compareTo(cloudDay) > 0 || (localDay == cloudDay && local.streak > cloud.streak)));

  final snapshot = ProgressSnapshot(
    lessons: lessons,
    xp: cloud.xp + extraXp,
    streak: useLocalStreak ? local.streak : cloud.streak,
    lastActiveDate: useLocalStreak ? localDay : cloudDay,
    paid: {...cloud.paid, ...local.paid},
  );
  return MergeResult(
    snapshot: snapshot,
    update: CloudUpdate(
      xpIncrement: extraXp,
      paidAdded: phoneOnly,
      streak: snapshot.streak,
      lastActiveDate: snapshot.lastActiveDate,
      lessonsCompleted: snapshot.lessonsCompleted,
      lessons: changed,
    ),
  );
}

/// One lesson, keeping the best of both.
LessonProgress mergeLesson(LessonProgress a, LessonProgress b) {
  int? best(int? x, int? y) => x == null ? y : (y == null || x > y ? x : y);
  DateTime? earliest(DateTime? x, DateTime? y) => x == null ? y : (y == null || x.isBefore(y) ? x : y);
  return LessonProgress(
    partsDone: a.partsDone > b.partsDone ? a.partsDone : b.partsDone,
    completed: a.completed || b.completed,
    bestScore: best(a.bestScore, b.bestScore),
    passed: a.passed || b.passed,
    completedAt: earliest(a.completedAt, b.completedAt),
  );
}

bool sameLesson(LessonProgress a, LessonProgress b) =>
    a.partsDone == b.partsDone &&
    a.completed == b.completed &&
    a.bestScore == b.bestScore &&
    a.passed == b.passed &&
    a.completedAt == b.completedAt;
