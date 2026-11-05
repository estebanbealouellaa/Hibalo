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
/// Writes go in one batch per finished part, lesson or quiz, all merge
/// writes with only the fields that raise the cloud (never null, never a
/// lower value). XP uses `FieldValue.increment` (no transactions: they fail
/// offline). Firestore's offline persistence (on by default on Android and
/// iOS) keeps the batch on the phone until it is online. Voice recordings
/// are never uploaded.
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
      lessonsCompleted: (data['lessonsCompleted'] as num?)?.toInt() ?? 0,
      paid: {...?(data['paid'] as List?)?.whereType<String>()},
      lessons: {for (final doc in lessons.docs) doc.id: lessonFromFirestore(doc.data())},
    );
  }

  @override
  void write(String uid, CloudUpdate update) {
    final batch = _db.batch();
    final user = _user(uid);
    final fields = userFields(update);
    if (fields.isNotEmpty) batch.set(user, fields, SetOptions(merge: true));
    for (final e in update.lessons.entries) {
      batch.set(user.collection('lessonProgress').doc(e.key), lessonToFirestore(e.value), SetOptions(merge: true));
    }
    for (final a in update.attempts) {
      batch.set(user.collection('quizAttempts').doc(), attemptToFirestore(a));
    }
    // Debug builds: log what each batch sends (fields only, no recordings).
    assert(() {
      debugPrint('[Learning] sync batch: user=$fields '
          'lessons=${{for (final e in update.lessons.entries) e.key: lessonToFirestore(e.value).keys.map((k) => '$k=${lessonToFirestore(e.value)[k]}').join(',')}} '
          'attempts=${update.attempts.map((a) => '${a.lessonId}:${a.score}/${a.total}').toList()}');
      return true;
    }());
    // Not awaited: offline, the future only completes once the server has
    // the writes. They are already saved on the phone at this point.
    batch.commit().catchError((Object e) {
      debugPrint('[Learning] progress sync failed: $e');
    });
  }

  /// The progress fields on users/{uid}. The profile (username, email,
  /// photoUrl, createdAt…) and role are never touched.
  static const progressFields = ['xp', 'streak', 'lastActiveDate', 'lessonsCompleted', 'paid'];

  @override
  Future<void> deleteProgress(String uid) async {
    final user = _user(uid);
    await deleteLearningDocs(
      _db,
      uid,
      also: (batch) => batch.set(
        user,
        {for (final f in progressFields) f: FieldValue.delete()},
        SetOptions(merge: true),
      ),
    );
  }

  /// Deletes every lessonProgress and quizAttempts document of [uid], in
  /// batches of up to 400; [also] adds more to the last batch. Used by the
  /// debug reset and by the admin "Delete user".
  static Future<void> deleteLearningDocs(
    FirebaseFirestore db,
    String uid, {
    void Function(WriteBatch batch)? also,
  }) async {
    final user = db.collection('users').doc(uid);
    final docs = [
      ...(await user.collection('lessonProgress').get()).docs,
      ...(await user.collection('quizAttempts').get()).docs,
    ];
    var batch = db.batch();
    var count = 0;
    for (final doc in docs) {
      batch.delete(doc.reference);
      if (++count == 400) {
        await batch.commit();
        batch = db.batch();
        count = 0;
      }
    }
    also?.call(batch);
    await batch.commit();
  }

  /// The `users/{uid}` fields of [update]: only those it raises, never
  /// null, never `role`.
  @visibleForTesting
  static Map<String, Object> userFields(CloudUpdate update) => {
    if (update.xpIncrement != 0) 'xp': FieldValue.increment(update.xpIncrement),
    if (update.paidAdded.isNotEmpty) 'paid': FieldValue.arrayUnion(update.paidAdded),
    if (update.lastActiveDate != null) ...{'streak': update.streak!, 'lastActiveDate': update.lastActiveDate!},
    if (update.lessonsCompleted != null) 'lessonsCompleted': update.lessonsCompleted!,
  };

  /// The lessonProgress fields [r] raises: nothing null, nothing lower.
  @visibleForTesting
  static Map<String, Object> lessonToFirestore(LessonRaise r) => {
    if (r.partsDone != null) 'partsDone': r.partsDone!,
    if (r.completed) 'completed': true,
    if (r.bestScore != null) 'bestScore': r.bestScore!,
    if (r.passed) 'passed': true,
    if (r.completedAt != null) 'completedAt': Timestamp.fromDate(r.completedAt!),
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
