import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import 'progress_cloud.dart';

/// Learning progress in Firestore:
/// - `users/{uid}`: xp, streak, lastActiveDate, lessonsCompleted, paid
/// - `users/{uid}/lessonProgress/{lessonId}`: partsDone, completed,
///   bestScore, passed, completedAt
/// - `users/{uid}/quizAttempts/{attemptId}`: lessonId, score, total,
///   xpEarned, date
///
/// Writes go in one batch per finished part, lesson or quiz. XP uses
/// `FieldValue.increment` (no transactions: they fail offline). Firestore's
/// offline persistence (on by default on Android and iOS) keeps the batch on
/// the phone until it is online. Voice recordings are never uploaded.
class FirestoreProgressCloud implements ProgressCloud {
  FirestoreProgressCloud([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) => _db.collection('users').doc(uid);

  @override
  Future<CloudProgress> fetch(String uid) async {
    final user = await _user(uid).get();
    final lessons = await _user(uid).collection('lessonProgress').get();
    final data = user.data() ?? const <String, dynamic>{};
    return CloudProgress(
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      streak: (data['streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: data['lastActiveDate'] as String?,
      paid: {...?(data['paid'] as List?)?.whereType<String>()},
      lessons: {for (final doc in lessons.docs) doc.id: lessonFromFirestore(doc.data())},
    );
  }

  @override
  void write(String uid, CloudUpdate update) {
    final batch = _db.batch();
    final user = _user(uid);
    batch.set(user, userFields(update), SetOptions(merge: true));
    for (final e in update.lessons.entries) {
      batch.set(user.collection('lessonProgress').doc(e.key), lessonToFirestore(e.value), SetOptions(merge: true));
    }
    for (final a in update.attempts) {
      batch.set(user.collection('quizAttempts').doc(), attemptToFirestore(a));
    }
    // Not awaited: offline, the future only completes once the server has
    // the writes. They are already saved on the phone at this point.
    batch.commit().catchError((Object e) {
      debugPrint('[Learning] progress sync failed: $e');
    });
  }

  /// The `users/{uid}` fields of [update]. Never touches `role`.
  @visibleForTesting
  static Map<String, Object?> userFields(CloudUpdate update) => {
    if (update.xpIncrement != 0) 'xp': FieldValue.increment(update.xpIncrement),
    if (update.paidAdded.isNotEmpty) 'paid': FieldValue.arrayUnion(update.paidAdded),
    'streak': update.streak,
    'lastActiveDate': update.lastActiveDate,
    'lessonsCompleted': update.lessonsCompleted,
  };

  @visibleForTesting
  static Map<String, Object?> lessonToFirestore(LessonProgress p) => {
    'partsDone': p.partsDone,
    'completed': p.completed,
    'bestScore': p.bestScore,
    'passed': p.passed,
    'completedAt': p.completedAt == null ? null : Timestamp.fromDate(p.completedAt!),
  };

  @visibleForTesting
  static LessonProgress lessonFromFirestore(Map<String, dynamic> data) {
    final at = data['completedAt'];
    return LessonProgress(
      partsDone: (data['partsDone'] as num?)?.toInt() ?? 0,
      completed: data['completed'] == true,
      bestScore: (data['bestScore'] as num?)?.toInt(),
      passed: data['passed'] == true,
      completedAt: at is Timestamp ? at.toDate() : null,
    );
  }

  @visibleForTesting
  static Map<String, Object?> attemptToFirestore(QuizAttemptRecord a) => {
    'lessonId': a.lessonId,
    'score': a.score,
    'total': a.total,
    'xpEarned': a.xpEarned,
    'date': Timestamp.fromDate(a.date),
  };
}
