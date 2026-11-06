import '../models/progress.dart';

/// The cloud copy of a learner's progress, as read on sign-in and then as known after each write.
class CloudProgress {
  CloudProgress({
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
    this.lessonsCompleted = 0,
    Set<String>? paid,
    Map<String, LessonProgress>? lessons,
  }) : paid = paid ?? {},
       lessons = lessons ?? {};

  int xp;
  int streak;
  String? lastActiveDate;
  int lessonsCompleted;
  final Set<String> paid;
  final Map<String, LessonProgress> lessons;

  Map<String, dynamic> toJson() => {
    'xp': xp,
    'streak': streak,
    'lastActiveDate': lastActiveDate,
    'lessonsCompleted': lessonsCompleted,
    'paid': paid.toList()..sort(),
    'lessons': {for (final e in lessons.entries) e.key: e.value.toJson()},
  };

  static CloudProgress? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final raw = json['lessons'];
    return CloudProgress(
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      lessonsCompleted: (json['lessonsCompleted'] as num?)?.toInt() ?? 0,
      paid: {...?(json['paid'] as List?)?.whereType<String>()},
      lessons: {
        if (raw is Map<String, dynamic>)
          for (final e in raw.entries)
            if (e.value is Map<String, dynamic>) e.key: LessonProgress.fromJson(e.value as Map<String, dynamic>),
      },
    );
  }
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

  final int score;

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

/// lessonProgress fields one write raises; null fields aren't sent, so a merge write never lowers the cloud.
class LessonRaise {
  const LessonRaise({this.partsDone, this.completed = false, this.bestScore, this.passed = false, this.completedAt});

  final int? partsDone;
  final bool completed;
  final int? bestScore;
  final bool passed;
  final DateTime? completedAt;

  bool get isEmpty => partsDone == null && !completed && bestScore == null && !passed && completedAt == null;

  /// What [local] adds to [known] (the cloud's value as known on the phone).
  factory LessonRaise.between(LessonProgress? known, LessonProgress local) {
    final k = known ?? LessonProgress.empty;
    final best = local.bestScore;
    return LessonRaise(
      partsDone: local.partsDone > k.partsDone ? local.partsDone : null,
      completed: local.completed && !k.completed,
      bestScore: best != null && (k.bestScore == null || best > k.bestScore!) ? best : null,
      passed: local.passed && !k.passed,
      completedAt: k.completedAt == null ? local.completedAt : null,
    );
  }

  /// [known] after this write (what a merge write leaves in the cloud).
  LessonProgress applyTo(LessonProgress? known) {
    final k = known ?? LessonProgress.empty;
    return LessonProgress(
      partsDone: partsDone ?? k.partsDone,
      completed: completed || k.completed,
      bestScore: bestScore ?? k.bestScore,
      passed: passed || k.passed,
      completedAt: completedAt ?? k.completedAt,
    );
  }
}

/// One sync's merge writes: XP via FieldValue.increment, paid ids via arrayUnion, no transactions (they fail offline).
class CloudUpdate {
  const CloudUpdate({
    this.xpIncrement = 0,
    this.paidAdded = const [],
    this.streak,
    this.lastActiveDate,
    this.lessonsCompleted,
    this.lessons = const {},
    this.attempts = const [],
  });

  final int xpIncrement;
  final List<String> paidAdded;

  /// Sent together, only for a later day (or a longer streak the same day).
  final int? streak;
  final String? lastActiveDate;

  /// Sent only when higher.
  final int? lessonsCompleted;

  final Map<String, LessonRaise> lessons;

  final List<QuizAttemptRecord> attempts;

  bool get isEmpty =>
      xpIncrement == 0 &&
      paidAdded.isEmpty &&
      lastActiveDate == null &&
      lessonsCompleted == null &&
      lessons.isEmpty &&
      attempts.isEmpty;
}

/// Where synced progress goes. The real one is Firestore; tests use a fake.
abstract class ProgressCloud {
  /// Reads the learner's progress. Throws when it can't be read (offline
  /// with nothing cached); nothing is sent until it can be.
  Future<CloudProgress> fetch(String uid);

  /// Queues [update] for [uid]. Returns at once: Firestore keeps the writes
  /// on the phone (offline persistence) and sends them when online.
  void write(String uid, CloudUpdate update);

  /// Debug reset only: deletes the progress fields, paid, lessonProgress and quizAttempts; never the profile or role.
  Future<void> deleteProgress(String uid);
}

/// What [local] sends to a cloud known as [known] (only raises); [known] is updated to match.
CloudUpdate raiseCloud({
  required ProgressSnapshot local,
  required CloudProgress known,
  required int Function(String paidId) xpOf,
}) {
  final newPaid = local.paid.difference(known.paid).toList()..sort();
  final xp = newPaid.fold<int>(0, (sum, id) => sum + xpOf(id));

  final lessons = <String, LessonRaise>{};
  for (final e in local.lessons.entries) {
    final raise = LessonRaise.between(known.lessons[e.key], e.value);
    if (raise.isEmpty) continue;
    lessons[e.key] = raise;
    known.lessons[e.key] = raise.applyTo(known.lessons[e.key]);
  }

  final day = local.lastActiveDate;
  final knownDay = known.lastActiveDate;
  final laterDay =
      day != null &&
      (knownDay == null || day.compareTo(knownDay) > 0 || (day == knownDay && local.streak > known.streak));
  final completed = local.lessonsCompleted;
  final moreCompleted = completed > known.lessonsCompleted;

  final update = CloudUpdate(
    xpIncrement: xp,
    paidAdded: newPaid,
    streak: laterDay ? local.streak : null,
    lastActiveDate: laterDay ? day : null,
    lessonsCompleted: moreCompleted ? completed : null,
    lessons: lessons,
    attempts: List.of(local.pendingAttempts),
  );
  known
    ..xp += xp
    ..paid.addAll(newPaid);
  if (laterDay) {
    known
      ..streak = local.streak
      ..lastActiveDate = day;
  }
  if (moreCompleted) known.lessonsCompleted = completed;
  return update;
}

/// Sign-in merge, keeping the best: highest per-lesson values, union of paid ids, XP = cloud XP + XP of ids only the phone paid.
ProgressSnapshot mergeProgress({
  required ProgressSnapshot local,
  required CloudProgress cloud,
  required int Function(String paidId) xpOf,
}) {
  final phoneOnly = local.paid.difference(cloud.paid);
  final extraXp = phoneOnly.fold<int>(0, (sum, id) => sum + xpOf(id));

  final lessons = <String, LessonProgress>{
    for (final id in {...cloud.lessons.keys, ...local.lessons.keys})
      id: switch ((local.lessons[id], cloud.lessons[id])) {
        (final l?, final c?) => mergeLesson(l, c),
        (final l?, null) => l,
        (null, final c?) => c,
        (null, null) => LessonProgress.empty,
      },
  };

  final localDay = local.lastActiveDate;
  final cloudDay = cloud.lastActiveDate;
  final useLocalStreak =
      cloudDay == null ||
      (localDay != null && (localDay.compareTo(cloudDay) > 0 || (localDay == cloudDay && local.streak > cloud.streak)));

  return ProgressSnapshot(
    lessons: lessons,
    xp: cloud.xp + extraXp,
    streak: useLocalStreak ? local.streak : cloud.streak,
    lastActiveDate: useLocalStreak ? localDay : cloudDay,
    paid: {...cloud.paid, ...local.paid},
    ownerUid: local.ownerUid,
    pendingAttempts: List.of(local.pendingAttempts),
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
