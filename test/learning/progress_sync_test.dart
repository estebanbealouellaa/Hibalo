// Saving progress, the streak and the Firestore sync (step 5). Firestore is
// replaced by a fake ProgressCloud that records every batch.

import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/services/progress_store.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/learning/sync/firestore_progress_cloud.dart';
import 'package:hibalo_app/learning/sync/progress_cloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records writes and applies them like Firestore would (increment, union).
class FakeCloud implements ProgressCloud {
  FakeCloud([Map<String, CloudProgress>? users]) : users = users ?? {};

  final Map<String, CloudProgress> users;
  final List<(String, CloudUpdate)> writes = [];
  final List<QuizAttemptRecord> attempts = [];
  bool offline = false;

  @override
  Future<CloudProgress> fetch(String uid) async {
    if (offline) throw StateError('unavailable');
    return users[uid] ?? CloudProgress();
  }

  @override
  void write(String uid, CloudUpdate u) {
    writes.add((uid, u));
    final c = users[uid] ?? CloudProgress();
    attempts.addAll(u.attempts);
    users[uid] = CloudProgress(
      xp: c.xp + u.xpIncrement,
      streak: u.streak,
      lastActiveDate: u.lastActiveDate,
      paid: {...c.paid, ...u.paidAdded},
      lessons: {...c.lessons, ...u.lessons},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Lesson lesson(String id) => catalog.lessonById(id)!;

  // ── Best score and streak ──────────────────────────────────────────────

  test('the best score is kept, and passed stays passed', () async {
    final p = LearningProgress.ready(catalog, ProgressSnapshot());
    final b02 = lesson('b02');
    await p.saveQuizResult(b02, correct: 7, total: 8, rightIds: const []);
    expect(p.progressFor('b02').bestScore, 7);
    expect(p.progressFor('b02').passed, isTrue);
    final weaker = await p.saveQuizResult(b02, correct: 3, total: 8, rightIds: const []);
    expect(weaker.passed, isFalse);
    expect(weaker.lessonPassed, isTrue);
    expect(p.progressFor('b02').bestScore, 7);
    expect(p.progressFor('b02').passed, isTrue);
  });

  group('streak (phone date)', () {
    late DateTime now;
    late LearningProgress p;
    setUp(() {
      now = DateTime(2026, 11, 5, 9);
      p = LearningProgress.ready(catalog, ProgressSnapshot(), clock: () => now);
    });

    test('same day counts once', () async {
      await p.savePartDone(lesson('b02'), 0);
      await p.savePartDone(lesson('b02'), 1);
      now = DateTime(2026, 11, 5, 23, 59);
      await p.saveQuizResult(lesson('b02'), correct: 1, total: 8, rightIds: const []);
      expect(p.streak, 1);
    });

    test('the next day adds one', () async {
      await p.savePartDone(lesson('b02'), 0);
      now = DateTime(2026, 11, 6, 7);
      expect(p.streak, 1, reason: 'yesterday still counts before today’s activity');
      await p.savePartDone(lesson('b02'), 1);
      expect(p.streak, 2);
    });

    test('a missed day resets to 0, then starts again at 1', () async {
      await p.savePartDone(lesson('b02'), 0);
      now = DateTime(2026, 11, 7, 7);
      expect(p.streak, 0);
      await p.savePartDone(lesson('b02'), 1);
      expect(p.streak, 1);
    });
  });

  // ── Sync while signed in ──────────────────────────────────────────────

  LearningProgress signedIn(FakeCloud cloud, {String uid = 'u1', ProgressSnapshot? snapshot}) => LearningProgress.ready(
    catalog,
    snapshot ?? ProgressSnapshot(ownerUid: uid),
    cloud: cloud,
    uid: uid,
    clock: () => DateTime(2026, 11, 5, 9),
  );

  test('signed out: phone only, nothing is written', () async {
    final cloud = FakeCloud();
    final p = LearningProgress.ready(catalog, ProgressSnapshot(), cloud: cloud);
    await p.savePartDone(lesson('b02'), 0);
    await p.saveQuizResult(lesson('b02'), correct: 8, total: 8, rightIds: const ['q1']);
    expect(cloud.writes, isEmpty);
    expect(p.xp, 10);
  });

  test('one batch per finished part: lesson doc, streak, quick-check XP as an increment', () async {
    final cloud = FakeCloud();
    final p = signedIn(cloud);
    final b02 = lesson('b02');
    await p.savePartDone(b02, 0); // first sync merges the (empty) cloud
    cloud.writes.clear();

    // A quick check pays during the part: nothing is written yet.
    await p.payXpOnce(LearningProgress.quickCheckPaidId('p6'), 5);
    expect(cloud.writes, isEmpty, reason: 'never per tap');

    await p.savePartDone(b02, 1);
    expect(cloud.writes, hasLength(1));
    final (uid, u) = cloud.writes.single;
    expect(uid, 'u1');
    expect(u.xpIncrement, 5);
    expect(u.paidAdded, ['quickCheck:p6']);
    expect(u.lessons.keys, ['b02']);
    expect(u.lessons['b02']!.partsDone, 2);
    expect(u.streak, 1);
    expect(u.lastActiveDate, '2026-11-05');
    expect(cloud.users['u1']!.xp, 5);
  });

  test('a finished lesson and a finished quiz each write once, with the attempt', () async {
    final cloud = FakeCloud();
    final p = signedIn(cloud);
    final b02 = lesson('b02');
    for (var i = 0; i < b02.partsCount; i++) {
      await p.savePartDone(b02, i);
    }
    await p.payLessonComplete(b02);
    expect(cloud.users['u1']!.xp, 20);
    expect(cloud.writes.last.$2.lessonsCompleted, 1);
    final before = cloud.writes.length;

    await p.saveQuizResult(b02, correct: 7, total: 8, rightIds: const ['q1', 'q2']);
    expect(cloud.writes.length, before + 1);
    final u = cloud.writes.last.$2;
    expect(u.xpIncrement, 20);
    expect(u.lessons['b02']!.bestScore, 7);
    expect(u.lessons['b02']!.passed, isTrue);
    expect(cloud.attempts.single.lessonId, 'b02');
    expect(cloud.attempts.single.score, 7);
    expect(cloud.attempts.single.total, 8);
    expect(cloud.attempts.single.xpEarned, 20);
    expect(cloud.users['u1']!.xp, 40);

    // A retake pays nothing new: no XP increment, but a new attempt.
    await p.saveQuizResult(b02, correct: 8, total: 8, rightIds: const ['q1', 'q2']);
    expect(cloud.writes.last.$2.xpIncrement, 0);
    expect(cloud.attempts, hasLength(2));
    expect(cloud.users['u1']!.xp, 40);
  });

  test('offline at sign-in: writes wait, then go once the cloud can be read', () async {
    final cloud = FakeCloud()..offline = true;
    final p = signedIn(cloud);
    await p.savePartDone(lesson('b02'), 0);
    expect(cloud.writes, isEmpty);
    cloud.offline = false;
    await p.savePartDone(lesson('b02'), 1);
    expect(cloud.users['u1']!.lessons['b02']!.partsDone, 2);
  });

  // ── Merge on sign-in ──────────────────────────────────────────────────

  test('guest progress merges into the first account, keeping the best', () async {
    final cloud = FakeCloud({
      'u1': CloudProgress(
        xp: 30,
        streak: 4,
        lastActiveDate: '2026-11-04',
        paid: {'lesson:b02', 'question:b02:q1'},
        lessons: {
          'b02': LessonProgress(partsDone: 12, completed: true, bestScore: 5, completedAt: DateTime(2026, 10, 1)),
        },
      ),
    });
    final accounts = StreamController<String?>();
    final store = ProgressStore();
    await store.save(
      ProgressSnapshot(
        xp: 25,
        streak: 1,
        lastActiveDate: '2026-11-05',
        paid: {'lesson:b01', 'question:b02:q1', 'quickCheck:p6'},
        lessons: {
          'b01': const LessonProgress(partsDone: 8, completed: true),
          'b02': LessonProgress(partsDone: 3, bestScore: 7, passed: true, completedAt: DateTime(2026, 11, 1)),
        },
      ),
    );
    final p = LearningProgress(
      store: store,
      loadLessons: LessonRepository.instance,
      cloud: cloud,
      accounts: accounts.stream,
    );
    await p.load();
    expect(cloud.writes, isEmpty, reason: 'not signed in yet');

    accounts.add('u1');
    await pumpEventQueue();

    // XP = cloud 30 + phone-only lesson:b01 (20) + quickCheck:p6 (5).
    expect(p.xp, 55);
    final merge = cloud.writes.single.$2;
    expect(merge.xpIncrement, 25);
    expect(merge.paidAdded, ['lesson:b01', 'quickCheck:p6']);
    expect(cloud.users['u1']!.xp, 55);
    expect(cloud.users['u1']!.paid, {'lesson:b01', 'lesson:b02', 'question:b02:q1', 'quickCheck:p6'});

    final b02 = p.progressFor('b02');
    expect(b02.partsDone, 12);
    expect(b02.completed, isTrue);
    expect(b02.bestScore, 7);
    expect(b02.passed, isTrue);
    expect(b02.completedAt, DateTime(2026, 10, 1), reason: 'earliest');
    expect(p.progressFor('b01').completed, isTrue);
    // Streak: the phone's lastActiveDate is later.
    expect(merge.streak, 1);
    expect(merge.lastActiveDate, '2026-11-05');

    // Saved on the phone as this account's progress; signing in again
    // later sends nothing twice.
    final saved = await store.load();
    expect(saved.ownerUid, 'u1');
    expect(saved.syncedPaid, saved.paid);
    await accounts.close();
    p.dispose();
  });

  test('the streak with the later lastActiveDate wins', () {
    final m = mergeProgress(
      local: ProgressSnapshot(streak: 9, lastActiveDate: '2026-11-01'),
      cloud: CloudProgress(streak: 2, lastActiveDate: '2026-11-04'),
      xpOf: (_) => 0,
    );
    expect(m.snapshot.streak, 2);
    expect(m.snapshot.lastActiveDate, '2026-11-04');
  });

  test('a different account on the same phone starts from its own cloud progress', () async {
    final cloud = FakeCloud({
      'u2': CloudProgress(xp: 10, paid: {'question:b02:q1'}),
    });
    final p = LearningProgress.ready(
      catalog,
      ProgressSnapshot(
        ownerUid: 'u1',
        xp: 99,
        paid: {'lesson:b02'},
        lessons: {'b02': const LessonProgress(partsDone: 12, completed: true)},
      ),
      cloud: cloud,
      uid: 'u2',
    );
    await p.savePartDone(lesson('b03'), 0);
    expect(p.xp, 10);
    expect(p.isPaid('lesson:b02'), isFalse);
    expect(p.progressFor('b02').completed, isFalse);
    expect(p.progressFor('b03').partsDone, 1);
    expect(cloud.users['u2']!.xp, 10, reason: "u1's progress is not given to u2");
    expect(cloud.users['u2']!.lessons['b03']!.partsDone, 1);
  });

  // ── Firestore shape ───────────────────────────────────────────────────

  test('users/{uid}: XP with FieldValue.increment, paid with arrayUnion, never role', () {
    final fields = FirestoreProgressCloud.userFields(
      const CloudUpdate(
        xpIncrement: 30,
        paidAdded: ['question:b02:q1'],
        streak: 3,
        lastActiveDate: '2026-11-05',
        lessonsCompleted: 2,
      ),
    );
    expect(fields['xp'], isA<FieldValue>());
    expect(fields['xp'], FieldValue.increment(30));
    expect(fields['paid'], FieldValue.arrayUnion(['question:b02:q1']));
    expect(fields['streak'], 3);
    expect(fields['lastActiveDate'], '2026-11-05');
    expect(fields['lessonsCompleted'], 2);
    expect(fields.containsKey('role'), isFalse);

    final none = FirestoreProgressCloud.userFields(
      const CloudUpdate(streak: 0, lastActiveDate: null, lessonsCompleted: 0),
    );
    expect(none.containsKey('xp'), isFalse, reason: 'no increment when nothing was paid');
  });

  test('lessonProgress and quizAttempts documents have the agreed fields', () {
    final at = DateTime(2026, 11, 5, 9);
    final lessonDoc = FirestoreProgressCloud.lessonToFirestore(
      LessonProgress(partsDone: 12, completed: true, bestScore: 7, passed: true, completedAt: at),
    );
    expect(lessonDoc.keys, unorderedEquals(['partsDone', 'completed', 'bestScore', 'passed', 'completedAt']));
    expect(lessonDoc['completedAt'], Timestamp.fromDate(at));
    final back = FirestoreProgressCloud.lessonFromFirestore(Map<String, dynamic>.from(lessonDoc));
    expect(back.completedAt, at);
    expect(back.bestScore, 7);

    final attempt = FirestoreProgressCloud.attemptToFirestore(
      QuizAttemptRecord(lessonId: 'b02', score: 7, total: 8, xpEarned: 20, date: at),
    );
    expect(attempt.keys, unorderedEquals(['lessonId', 'score', 'total', 'xpEarned', 'date']));
  });

  test('the sync code uses no transactions and uploads no recordings', () {
    for (final path in [
      'lib/learning/sync/firestore_progress_cloud.dart',
      'lib/learning/sync/progress_cloud.dart',
      'lib/learning/state/learning_progress.dart',
    ]) {
      final code = File(path).readAsStringSync();
      expect(code.contains('runTransaction'), isFalse, reason: path);
      expect(code.contains('VoiceRecorder'), isFalse, reason: path);
    }
    final firestore = File('lib/learning/sync/firestore_progress_cloud.dart').readAsStringSync();
    expect(firestore.contains('FieldValue.increment'), isTrue);
    expect(firestore.contains('.batch()'), isTrue);
  });
}
