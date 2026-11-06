// Progress, streak and Firestore sync, with a fake cloud that applies merge writes (only the sent fields change).

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

/// Records writes and applies them like Firestore merge writes would
/// (increment, union, sent fields only).
class FakeCloud implements ProgressCloud {
  FakeCloud([Map<String, CloudProgress>? users]) : users = users ?? {};

  final Map<String, CloudProgress> users;
  final List<(String, CloudUpdate)> writes = [];
  final Map<String, List<QuizAttemptRecord>> attempts = {};
  bool offline = false;
  int reads = 0;

  CloudProgress of(String uid) => users[uid] ??= CloudProgress();

  @override
  Future<CloudProgress> fetch(String uid) async {
    reads++;
    if (offline) throw StateError('unavailable');
    // A copy, like a real read.
    return CloudProgress.fromJson(of(uid).toJson())!;
  }

  @override
  void write(String uid, CloudUpdate u) {
    writes.add((uid, u));
    final c = of(uid);
    c.xp += u.xpIncrement;
    c.paid.addAll(u.paidAdded);
    if (u.lastActiveDate != null) {
      c
        ..streak = u.streak!
        ..lastActiveDate = u.lastActiveDate;
    }
    if (u.lessonsCompleted != null) c.lessonsCompleted = u.lessonsCompleted!;
    for (final e in u.lessons.entries) {
      c.lessons[e.key] = e.value.applyTo(c.lessons[e.key]);
    }
    (attempts[uid] ??= []).addAll(u.attempts);
  }

  @override
  Future<void> deleteProgress(String uid) async {
    if (offline) throw StateError('unavailable');
    users[uid] = CloudProgress();
    attempts.remove(uid);
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
  final day = DateTime(2026, 11, 5, 9);

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

  LearningProgress signedIn(FakeCloud cloud, {String uid = 'u1', ProgressSnapshot? snapshot}) =>
      LearningProgress.ready(catalog, snapshot ?? ProgressSnapshot(ownerUid: uid),
          cloud: cloud, uid: uid, clock: () => day);

  test('signed out: phone only, nothing is read or written', () async {
    final cloud = FakeCloud();
    final p = LearningProgress.ready(catalog, ProgressSnapshot(), cloud: cloud);
    await p.savePartDone(lesson('b02'), 0);
    await p.saveQuizResult(lesson('b02'), correct: 8, total: 8, rightIds: const ['q1']);
    expect(cloud.writes, isEmpty);
    expect(cloud.reads, 0);
    expect(p.xp, 10);
  });

  test('one batch per finished part: raised fields only, quick-check XP as an increment', () async {
    final cloud = FakeCloud();
    final p = signedIn(cloud);
    final b02 = lesson('b02');
    await p.savePartDone(b02, 0); // the first sync reads and merges the cloud
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
    final raise = u.lessons['b02']!;
    expect(raise.partsDone, 2);
    expect(raise.bestScore, isNull, reason: 'nothing to raise');
    expect(raise.completed, isFalse);
    expect(u.lastActiveDate, isNull, reason: 'the day was already sent');
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
    expect(cloud.users['u1']!.lessonsCompleted, 1);
    expect(cloud.users['u1']!.lessons['b02']!.completed, isTrue);
    final before = cloud.writes.length;

    await p.saveQuizResult(b02, correct: 7, total: 8, rightIds: const ['q1', 'q2']);
    expect(cloud.writes.length, before + 1);
    final u = cloud.writes.last.$2;
    expect(u.xpIncrement, 20);
    expect(u.lessons['b02']!.bestScore, 7);
    expect(u.lessons['b02']!.passed, isTrue);
    final sent = cloud.attempts['u1']!.single;
    expect((sent.lessonId, sent.score, sent.total, sent.xpEarned), ('b02', 7, 8, 20));
    expect(cloud.users['u1']!.xp, 40);

    // A retake pays nothing new: no XP increment, but a new attempt.
    await p.saveQuizResult(b02, correct: 8, total: 8, rightIds: const ['q1', 'q2']);
    expect(cloud.writes.last.$2.xpIncrement, 0);
    expect(cloud.attempts['u1'], hasLength(2));
    expect(cloud.users['u1']!.xp, 40);
    expect(cloud.users['u1']!.lessons['b02']!.bestScore, 8);
  });

  test('a lower score after a pass does not change the cloud', () async {
    final cloud = FakeCloud();
    final p = signedIn(cloud);
    final b02 = lesson('b02');
    await p.saveQuizResult(b02, correct: 8, total: 8, rightIds: const []);
    final passed = cloud.users['u1']!.lessons['b02']!;
    expect((passed.bestScore, passed.passed), (8, true));

    await p.saveQuizResult(b02, correct: 3, total: 8, rightIds: const []);
    final u = cloud.writes.last.$2;
    expect(u.lessons, isEmpty, reason: 'no lesson field is sent');
    expect(u.attempts.single.score, 3, reason: 'the attempt itself is still recorded');
    final after = cloud.users['u1']!.lessons['b02']!;
    expect((after.bestScore, after.passed), (8, true));

    // Even a phone copy that went backwards sends nothing lower.
    final fields = FirestoreProgressCloud.lessonToFirestore(LessonRaise.between(
        const LessonProgress(partsDone: 12, completed: true, bestScore: 8, passed: true),
        const LessonProgress(partsDone: 1, bestScore: 2)));
    expect(fields, isEmpty);
  });

  test('a fresh install that finishes a part before the cloud read keeps 8/8 and pays XP once', () async {
    final cloud = FakeCloud({
      'u1': CloudProgress(
        xp: 100,
        streak: 2,
        lastActiveDate: '2026-11-04',
        lessonsCompleted: 2,
        paid: {'lesson:b01', 'lesson:b02', 'quickCheck:p6'},
        lessons: {
          'b01': const LessonProgress(partsDone: 8, completed: true),
          'b02': const LessonProgress(partsDone: 12, completed: true, bestScore: 8, passed: true),
        },
      ),
    })..offline = true;
    // Fresh install: nothing on the phone, the account already signed in.
    final accounts = StreamController<String?>();
    final p = LearningProgress(
      store: ProgressStore(),
      loadLessons: LessonRepository.instance,
      cloud: cloud,
      accounts: accounts.stream,
      clock: () => day,
    );
    await p.load();
    accounts.add('u1');
    await pumpEventQueue();

    // Offline: finish Lesson 1 again, including the quick check and +20.
    final b01 = lesson('b01');
    await p.payXpOnce(LearningProgress.quickCheckPaidId('p6'), 5);
    for (var i = 0; i < b01.partsCount; i++) {
      await p.savePartDone(b01, i);
    }
    await p.payLessonComplete(b01);
    expect(cloud.writes, isEmpty, reason: 'nothing is sent before the cloud is read');
    expect(p.xp, 25);

    // Online: the next save reads, merges and sends only what is new.
    cloud.offline = false;
    await p.savePartDone(lesson('b03'), 0);
    final c = cloud.users['u1']!;
    expect(c.xp, 100, reason: 'quickCheck:p6 and lesson:b01 were already paid');
    expect(p.xp, 100);
    expect((c.lessons['b02']!.bestScore, c.lessons['b02']!.passed), (8, true));
    expect(p.progressFor('b02').bestScore, 8);
    expect(c.lessons['b03']!.partsDone, 1);
    expect(c.lessonsCompleted, 2, reason: 'b01 and b02; b03 is not finished');
    for (final (_, u) in cloud.writes) {
      expect(u.lessons.containsKey('b02'), isFalse, reason: 'b02 is never written');
    }
    await accounts.close();
    p.dispose();
  });

  test('guest progress merges into the first account, keeping the best', () async {
    final cloud = FakeCloud({
      'u1': CloudProgress(
        xp: 30,
        streak: 4,
        lastActiveDate: '2026-11-04',
        lessonsCompleted: 1,
        paid: {'lesson:b02', 'question:b02:q1'},
        lessons: {
          'b02': LessonProgress(partsDone: 12, completed: true, bestScore: 5, completedAt: DateTime(2026, 10, 1)),
        },
      ),
    });
    final accounts = StreamController<String?>();
    final store = ProgressStore();
    await store.save(ProgressSnapshot(
      xp: 25,
      streak: 1,
      lastActiveDate: '2026-11-05',
      paid: {'lesson:b01', 'question:b02:q1', 'quickCheck:p6'},
      lessons: {
        'b01': const LessonProgress(partsDone: 8, completed: true),
        'b02': LessonProgress(partsDone: 3, bestScore: 7, passed: true, completedAt: DateTime(2026, 11, 1)),
      },
    ));
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
    final c = cloud.users['u1']!;
    expect(c.xp, 55);
    expect(c.paid, {'lesson:b01', 'lesson:b02', 'question:b02:q1', 'quickCheck:p6'});

    final b02 = p.progressFor('b02');
    expect((b02.partsDone, b02.completed, b02.bestScore, b02.passed), (12, true, 7, true));
    expect(b02.completedAt, DateTime(2026, 10, 1), reason: 'earliest');
    // Only the raised fields of b02 were sent; completedAt was already set.
    final raise = merge.lessons['b02']!;
    expect((raise.partsDone, raise.bestScore, raise.passed, raise.completedAt), (null, 7, true, null));
    expect(c.lessons['b02']!.completedAt, DateTime(2026, 10, 1));
    expect(c.lessons['b01']!.completed, isTrue);
    // Streak: the phone's lastActiveDate is later.
    expect((c.streak, c.lastActiveDate), (1, '2026-11-05'));
    expect(c.lessonsCompleted, 2);

    // Saved on the phone as this account's progress, with the known cloud
    // copy, so nothing is sent twice.
    final saved = await store.load();
    expect(saved.ownerUid, 'u1');
    expect(saved.cloud!.paid, saved.paid);
    await accounts.close();
    p.dispose();
  });

  test('the streak with the later lastActiveDate wins', () {
    final m = mergeProgress(
      local: ProgressSnapshot(streak: 9, lastActiveDate: '2026-11-01'),
      cloud: CloudProgress(streak: 2, lastActiveDate: '2026-11-04'),
      xpOf: (_) => 0,
    );
    expect(m.streak, 2);
    expect(m.lastActiveDate, '2026-11-04');
  });

  test('a different account on the same phone starts from its own cloud progress', () async {
    final cloud = FakeCloud({
      'u2': CloudProgress(xp: 10, paid: {'question:b02:q1'}),
    });
    final p = LearningProgress.ready(
      catalog,
      ProgressSnapshot(ownerUid: 'u1', xp: 99, paid: {'lesson:b02'}, lessons: {
        'b02': const LessonProgress(partsDone: 12, completed: true),
      }),
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
    expect(cloud.users['u1'], isNull, reason: 'u1 is not written to');
  });

  test('debug reset clears the phone and this account\'s cloud progress, then syncs from zero', () async {
    final cloud = FakeCloud();
    final p = signedIn(cloud);
    final b02 = lesson('b02');
    for (var i = 0; i < b02.partsCount; i++) {
      await p.savePartDone(b02, i);
    }
    await p.payLessonComplete(b02);
    await p.saveQuizResult(b02, correct: 8, total: 8, rightIds: const ['q1']);
    expect(cloud.users['u1']!.xp, 30);

    expect(await p.debugResetAll(), isTrue);
    expect(p.xp, 0);
    expect(p.progressFor('b02').completed, isFalse);
    expect(cloud.users['u1']!.lessons, isEmpty);
    expect(cloud.users['u1']!.xp, 0);
    expect(cloud.attempts['u1'], isNull);

    // A new run counts from zero, including XP paid before the reset.
    await p.savePartDone(b02, 0);
    await p.payXpOnce(LearningProgress.quickCheckPaidId('p6'), 5);
    await p.savePartDone(b02, 1);
    expect(cloud.users['u1']!.lessons['b02']!.partsDone, 2);
    expect(cloud.users['u1']!.xp, 5);
  });

  test('debug reset offline: the phone resets, the cloud is merged back later', () async {
    final cloud = FakeCloud({
      'u1': CloudProgress(xp: 20, paid: {'lesson:b02'}, lessons: {
        'b02': const LessonProgress(partsDone: 12, completed: true, bestScore: 8, passed: true),
      }),
    });
    final p = signedIn(cloud);
    await p.savePartDone(lesson('b03'), 0);
    cloud.offline = true;
    expect(await p.debugResetAll(), isFalse);
    expect(p.xp, 0);
    cloud.offline = false;
    await p.savePartDone(lesson('b03'), 0);
    expect(p.progressFor('b02').bestScore, 8, reason: 'never lowered, merged back');
    expect(cloud.users['u1']!.xp, 20);
  });

  test('users/{uid}: XP with FieldValue.increment, paid with arrayUnion, no nulls, never role', () {
    final fields = FirestoreProgressCloud.userFields(const CloudUpdate(
      xpIncrement: 30,
      paidAdded: ['question:b02:q1'],
      streak: 3,
      lastActiveDate: '2026-11-05',
      lessonsCompleted: 2,
    ));
    expect(fields['xp'], isA<FieldValue>());
    expect(fields['xp'], FieldValue.increment(30));
    expect(fields['paid'], FieldValue.arrayUnion(['question:b02:q1']));
    expect(fields['streak'], 3);
    expect(fields['lastActiveDate'], '2026-11-05');
    expect(fields['lessonsCompleted'], 2);
    expect(fields.containsKey('role'), isFalse);

    expect(FirestoreProgressCloud.userFields(const CloudUpdate()), isEmpty,
        reason: 'nothing raised: nothing sent, not even null');
    expect(FirestoreProgressCloud.progressFields, isNot(contains('role')));
  });

  test('lessonProgress writes only raised fields, and quizAttempts has the agreed fields', () {
    final at = DateTime(2026, 11, 5, 9);
    final all = FirestoreProgressCloud.lessonToFirestore(LessonRaise.between(
        null, LessonProgress(partsDone: 12, completed: true, bestScore: 7, passed: true, completedAt: at)));
    expect(all.keys, unorderedEquals(['partsDone', 'completed', 'bestScore', 'passed', 'completedAt']));
    expect(all['completedAt'], Timestamp.fromDate(at));
    expect(all.values, isNot(contains(null)));

    final known = LessonProgress(partsDone: 12, completed: true, bestScore: 7, passed: true, completedAt: at);
    final higher = FirestoreProgressCloud.lessonToFirestore(LessonRaise.between(
        known, LessonProgress(partsDone: 12, completed: true, bestScore: 8, passed: true, completedAt: DateTime(2027))));
    expect(higher, {'bestScore': 8}, reason: 'completedAt is only set once');

    final back = FirestoreProgressCloud.lessonFromFirestore(Map<String, dynamic>.from(all));
    expect((back.completedAt, back.bestScore), (at, 7));

    final attempt = FirestoreProgressCloud.attemptToFirestore(
        QuizAttemptRecord(lessonId: 'b02', score: 7, total: 8, xpEarned: 20, date: at));
    expect(attempt.keys, unorderedEquals(['lessonId', 'score', 'total', 'xpEarned', 'date']));
  });

  test('the sync code uses merge writes, no transactions, and uploads no recordings', () {
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
    // Every set() in write() is a merge write.
    final write = firestore.substring(firestore.indexOf('void write('), firestore.indexOf('static const progressFields'));
    final sets = RegExp(r'batch\.set\(').allMatches(write).length;
    final merges = RegExp(r'SetOptions\(merge: true\)').allMatches(write).length;
    expect(sets - merges, 1, reason: 'only the new quizAttempts document is a plain set');
  });
}
