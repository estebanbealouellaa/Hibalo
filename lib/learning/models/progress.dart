import '../sync/progress_cloud.dart' show QuizAttemptRecord;

/// What the learner has done in one lesson. Saved on the phone, and synced to
/// Firestore `users/{uid}/lessonProgress/{lessonId}` with the same field
/// names.
class LessonProgress {
  const LessonProgress({
    this.partsDone = 0,
    this.completed = false,
    this.bestScore,
    this.passed = false,
    this.completedAt,
  });

  static const empty = LessonProgress();

  /// Finished parts, counted from the start. The next part to open is
  /// `partsDone` (0-based).
  final int partsDone;

  /// Every part finished at least once.
  final bool completed;

  /// Best quiz result: correct scored questions. Null if never finished.
  final int? bestScore;

  /// The quiz was passed at least once.
  final bool passed;

  /// When the lesson was first finished.
  final DateTime? completedAt;

  LessonProgress copyWith({
    int? partsDone,
    bool? completed,
    int? bestScore,
    bool? passed,
    DateTime? completedAt,
  }) {
    return LessonProgress(
      partsDone: partsDone ?? this.partsDone,
      completed: completed ?? this.completed,
      bestScore: bestScore ?? this.bestScore,
      passed: passed ?? this.passed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'partsDone': partsDone,
        'completed': completed,
        'bestScore': bestScore,
        'passed': passed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    final at = json['completedAt'];
    return LessonProgress(
      partsDone: (json['partsDone'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
      bestScore: (json['bestScore'] as num?)?.toInt(),
      passed: json['passed'] == true,
      completedAt: at is String ? DateTime.tryParse(at) : null,
    );
  }
}

/// Everything saved on the phone for the learning module.
class ProgressSnapshot {
  ProgressSnapshot({
    Map<String, LessonProgress>? lessons,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
    Set<String>? paid,
    this.ownerUid,
    Set<String>? syncedPaid,
    Set<String>? unsyncedLessons,
    List<QuizAttemptRecord>? pendingAttempts,
  })  : lessons = lessons ?? {},
        paid = paid ?? {},
        syncedPaid = syncedPaid ?? {},
        unsyncedLessons = unsyncedLessons ?? {},
        pendingAttempts = pendingAttempts ?? [];

  /// Lesson id → progress. Lessons never opened are missing.
  final Map<String, LessonProgress> lessons;

  /// Total XP.
  int xp;

  /// Days in a row with a finished part or quiz, as last saved.
  int streak;

  /// The last active day on the phone's calendar, "yyyy-MM-dd".
  String? lastActiveDate;

  /// Ids of things that already paid XP (questions, quick checks, lessons),
  /// so repeating them pays nothing.
  final Set<String> paid;

  // ── Sync bookkeeping ────────────────────────────────────────────────

  /// The account this progress belongs to, or null for a guest. Guest
  /// progress merges into the first account that signs in; another account
  /// starts from its own cloud progress.
  String? ownerUid;

  /// Paid ids the cloud already has (its XP includes them).
  final Set<String> syncedPaid;

  /// Lessons changed since the last sync.
  final Set<String> unsyncedLessons;

  /// Quiz attempts not sent yet.
  final List<QuizAttemptRecord> pendingAttempts;

  /// Lessons with every part finished (users/{uid}.lessonsCompleted).
  int get lessonsCompleted => lessons.values.where((p) => p.completed).length;

  Map<String, dynamic> toJson() => {
        'lessons': {for (final e in lessons.entries) e.key: e.value.toJson()},
        'xp': xp,
        'streak': streak,
        'lastActiveDate': lastActiveDate,
        'paid': paid.toList()..sort(),
        'ownerUid': ownerUid,
        'syncedPaid': syncedPaid.toList()..sort(),
        'unsyncedLessons': unsyncedLessons.toList()..sort(),
        'pendingAttempts': [for (final a in pendingAttempts) a.toJson()],
      };

  factory ProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final lessons = <String, LessonProgress>{};
    final raw = json['lessons'];
    if (raw is Map<String, dynamic>) {
      for (final e in raw.entries) {
        if (e.value is Map<String, dynamic>) {
          lessons[e.key] = LessonProgress.fromJson(e.value as Map<String, dynamic>);
        }
      }
    }
    return ProgressSnapshot(
      lessons: lessons,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['lastActiveDate'] as String?,
      paid: {...?(json['paid'] as List?)?.whereType<String>()},
      ownerUid: json['ownerUid'] as String?,
      syncedPaid: {...?(json['syncedPaid'] as List?)?.whereType<String>()},
      unsyncedLessons: {...?(json['unsyncedLessons'] as List?)?.whereType<String>()},
      pendingAttempts: [
        for (final a in (json['pendingAttempts'] as List?) ?? const [])
          ?QuizAttemptRecord.fromJson(a),
      ],
    );
  }
}
