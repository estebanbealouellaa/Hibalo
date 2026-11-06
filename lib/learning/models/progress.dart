import '../sync/progress_cloud.dart' show CloudProgress, QuizAttemptRecord;

/// Progress in one lesson; same field names as users/{uid}/lessonProgress/{lessonId}.
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

  final bool completed;

  /// Best quiz result: correct scored questions. Null if never finished.
  final int? bestScore;

  final bool passed;

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

class ProgressSnapshot {
  ProgressSnapshot({
    Map<String, LessonProgress>? lessons,
    this.xp = 0,
    this.streak = 0,
    this.lastActiveDate,
    Set<String>? paid,
    this.ownerUid,
    this.cloud,
    List<QuizAttemptRecord>? pendingAttempts,
  })  : lessons = lessons ?? {},
        paid = paid ?? {},
        pendingAttempts = pendingAttempts ?? [];

  /// Lesson id → progress. Lessons never opened are missing.
  final Map<String, LessonProgress> lessons;

  int xp;

  /// Days in a row with a finished part or quiz, as last saved.
  int streak;

  /// The last active day on the phone's calendar, "yyyy-MM-dd".
  String? lastActiveDate;

  /// Ids of things that already paid XP (questions, quick checks, lessons),
  /// so repeating them pays nothing.
  final Set<String> paid;

  /// The account this progress belongs to (null = guest; guest progress merges into the first account that signs in).
  String? ownerUid;

  /// What [ownerUid]'s cloud copy holds; null until read, and writes only send what is above it, so the cloud is never lowered.
  CloudProgress? cloud;

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
        'cloud': cloud?.toJson(),
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
      cloud: CloudProgress.fromJson(json['cloud']),
      pendingAttempts: [
        for (final a in (json['pendingAttempts'] as List?) ?? const [])
          ?QuizAttemptRecord.fromJson(a),
      ],
    );
  }
}
