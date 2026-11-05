import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/lesson_repository.dart';
import '../logic/streak.dart';
import '../logic/unlocking.dart';
import '../models/catalog.dart';
import '../models/progress.dart';
import '../services/progress_store.dart';
import '../sync/progress_cloud.dart';

/// The learner's progress for the whole app: lessons, XP, streak and
/// unlocking. Provided at the top of the app, so Home, Me, Translate and the
/// learning screens all show the same numbers.
///
/// Loads in two halves: the saved progress (fast, for the stat chips) and the
/// lessons (for the Learn screens). Everything is saved on the phone first;
/// when a [ProgressCloud] and a signed-in account are given, each finished
/// part, lesson or quiz is then synced (§1.10). Signed out = phone only.
class LearningProgress extends ChangeNotifier {
  LearningProgress({
    ProgressStore? store,
    Future<LessonRepository> Function()? loadLessons,
    DateTime Function()? clock,
    ProgressCloud? cloud,
    Stream<String?>? accounts,
  })  : _store = store ?? ProgressStore(),
        _loadLessons = loadLessons ?? LessonRepository.instance,
        _clock = clock ?? DateTime.now,
        _cloud = cloud {
    _accounts = accounts?.listen(_onAccount);
  }

  /// A ready-made instance for tests and previews: no loading needed.
  @visibleForTesting
  LearningProgress.ready(
    LessonCatalog catalog,
    ProgressSnapshot snapshot, {
    ProgressStore? store,
    DateTime Function()? clock,
    ProgressCloud? cloud,
    String? uid,
  })  : _store = store ?? ProgressStore(),
        _loadLessons = LessonRepository.instance,
        _clock = clock ?? DateTime.now,
        _cloud = cloud,
        _uid = uid,
        _catalog = catalog,
        _snapshot = snapshot,
        _progressLoaded = true {
    _switchAccount();
  }

  final ProgressStore _store;
  final Future<LessonRepository> Function() _loadLessons;
  final DateTime Function() _clock;
  final ProgressCloud? _cloud;
  StreamSubscription<String?>? _accounts;

  /// The signed-in account, or null.
  String? _uid;

  /// The account whose cloud progress has been merged in this session.
  String? _mergedFor;
  Future<void>? _merging;

  ProgressSnapshot _snapshot = ProgressSnapshot();
  LessonCatalog? _catalog;
  Object? _lessonsError;
  bool _progressLoaded = false;
  bool _loading = false;

  /// Loads the saved progress, then the lessons. Safe to call again after an
  /// error (the Learn screen's Try again button does).
  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    _lessonsError = null;
    notifyListeners();
    try {
      if (!_progressLoaded) {
        _snapshot = await _store.load();
        _progressLoaded = true;
        if (_switchAccount()) await _store.save(_snapshot);
        notifyListeners();
      }
      _catalog ??= (await _loadLessons()).catalog;
      unawaited(_sync());
    } catch (e, stack) {
      _lessonsError = e;
      debugPrint('[Learning] could not load: $e\n$stack');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Lessons ────────────────────────────────────────────────────────────

  /// True once the lessons are loaded.
  bool get isReady => _catalog != null;

  /// Why loading failed, or null.
  Object? get loadError => _lessonsError;

  LessonCatalog get catalog => _catalog!;

  /// Unlocking and lesson states for the current progress.
  LearningRules get rules => LearningRules(catalog, _snapshot.lessons);

  LessonProgress progressFor(String lessonId) =>
      _snapshot.lessons[lessonId] ?? LessonProgress.empty;

  // ── Stats (Home, Me, Translate) ────────────────────────────────────────

  int get xp => _snapshot.xp;

  /// The streak to show today (0 if a whole day was missed).
  int get streak => currentStreak(
        savedStreak: _snapshot.streak,
        lastActiveDate: _snapshot.lastActiveDate,
        today: _clock(),
      );

  /// Lessons with every part finished.
  int get lessonsCompleted => _snapshot.lessonsCompleted;

  // ── Saving (written once per finished part, never per tap) ─────────────

  /// Ids in the "paid" list, so XP is only ever paid once (§1.8).
  static String quickCheckPaidId(String partId) => 'quickCheck:$partId';
  static String lessonPaidId(String lessonId) => 'lesson:$lessonId';

  bool isPaid(String id) => _snapshot.paid.contains(id);

  /// XP earned in [lesson] so far: its paid quick checks (the XP chip on the
  /// lesson parts). The +20 for finishing is paid after the last part.
  int lessonXp(Lesson lesson) {
    final perCheck = catalog.settings.xp.quickCheck;
    var xp = 0;
    for (final part in lesson.parts) {
      if (part.template == 'P06' && isPaid(quickCheckPaidId(part.id))) xp += perCheck;
    }
    return xp;
  }

  /// Pays [amount] XP for [id] the first time only. Returns true if it paid.
  /// Saved on the phone; it reaches the cloud with the next finished part,
  /// lesson or quiz.
  Future<bool> payXpOnce(String id, int amount) async {
    if (!_snapshot.paid.add(id)) return false;
    _snapshot.xp += amount;
    notifyListeners();
    await _store.save(_snapshot);
    return true;
  }

  /// The XP a paid id is worth (for syncing and the merge on sign-in).
  int xpOfPaidId(String id) {
    final xp = catalog.settings.xp;
    if (id.startsWith('quickCheck:')) return xp.quickCheck;
    if (id.startsWith('lesson:')) return xp.lessonComplete;
    if (id.startsWith('question:')) return xp.perCorrect;
    return 0;
  }

  /// Saves that part [partIndex] (0-based) of [lesson] is finished, counts
  /// today for the streak, and marks the lesson completed after its last
  /// part. Parts already saved stay saved (a review changes nothing).
  Future<void> savePartDone(Lesson lesson, int partIndex) async {
    final before = progressFor(lesson.id);
    final done = partIndex + 1 > before.partsDone ? partIndex + 1 : before.partsDone;
    final completed = before.completed || done >= lesson.partsCount;
    _snapshot.lessons[lesson.id] = before.copyWith(
      partsDone: done.clamp(0, lesson.partsCount),
      completed: completed,
      completedAt: before.completedAt ?? (completed ? _clock() : null),
    );
    _markActiveToday();
    notifyListeners();
    await _store.save(_snapshot);
    await _sync();
  }

  /// Pays the lesson XP after the last part, once. Returns true if it paid.
  Future<bool> payLessonComplete(Lesson lesson) async {
    final paid = await payXpOnce(lessonPaidId(lesson.id), catalog.settings.xp.lessonComplete);
    if (paid) await _sync();
    return paid;
  }

  /// Quiz questions are paid once each, the first time they are right.
  static String questionPaidId(String lessonId, String questionId) =>
      'question:$lessonId:$questionId';

  /// Saves a finished quiz attempt on the phone (§1.10): the best score,
  /// passed (≥ pass mark, which unlocks the next lesson), the streak day, and
  /// XP for the scored questions [rightIds] that were never right before.
  /// Called once when the last question ends; leaving a quiz saves nothing.
  /// Then it is synced (with a quizAttempts document) when signed in.
  Future<QuizAttemptResult> saveQuizResult(
    Lesson lesson, {
    required int correct,
    required int total,
    required Iterable<String> rightIds,
  }) async {
    final settings = catalog.settings;
    var xpEarned = 0;
    for (final id in rightIds) {
      if (_snapshot.paid.add(questionPaidId(lesson.id, id))) {
        xpEarned += settings.xp.perCorrect;
      }
    }
    _snapshot.xp += xpEarned;

    final passed = total > 0 && correct / total >= settings.passMark - 1e-9;
    final before = progressFor(lesson.id);
    final best = before.bestScore;
    _snapshot.lessons[lesson.id] = before.copyWith(
      bestScore: best == null || correct > best ? correct : best,
      passed: before.passed || passed,
    );
    // Only signed-in attempts go to quizAttempts; a guest's best scores
    // reach the cloud through the merge on sign-in instead.
    if (_uid != null) {
      _snapshot.pendingAttempts.add(QuizAttemptRecord(
        lessonId: lesson.id,
        score: correct,
        total: total,
        xpEarned: xpEarned,
        date: _clock(),
      ));
    }
    _markActiveToday();
    notifyListeners();
    await _store.save(_snapshot);
    await _sync();
    return QuizAttemptResult(
      correct: correct,
      total: total,
      xpEarned: xpEarned,
      passed: passed,
      lessonPassed: before.passed || passed,
    );
  }

  /// Streak rule (§1.11): the first activity of a day adds one if yesterday
  /// was active, otherwise the streak starts again at 1.
  void _markActiveToday() {
    final now = _clock();
    final today = dayKey(now);
    if (_snapshot.lastActiveDate == today) return;
    final kept = currentStreak(
      savedStreak: _snapshot.streak,
      lastActiveDate: _snapshot.lastActiveDate,
      today: now,
    );
    _snapshot.streak = kept + 1;
    _snapshot.lastActiveDate = today;
  }

  // ── Firestore sync ─────────────────────────────────────────────────

  void _onAccount(String? uid) {
    if (uid == _uid) return;
    _uid = uid;
    if (_progressLoaded && _switchAccount()) {
      notifyListeners();
      unawaited(_store.save(_snapshot));
    }
    unawaited(_sync());
  }

  /// A different account signed in on this phone: it starts from its own
  /// progress at once (empty until its cloud copy is read), so nothing it
  /// does is mixed with the previous account's. Returns true if it switched.
  bool _switchAccount() {
    final uid = _uid;
    final owner = _snapshot.ownerUid;
    if (uid == null || owner == null || owner == uid) return false;
    _snapshot = ProgressSnapshot(ownerUid: uid);
    _mergedFor = null;
    return true;
  }

  /// Sends what the cloud is missing. Nothing is sent for an account until
  /// its cloud copy has been read and merged in this session (a fresh
  /// install, or a sign-in while offline, waits); until then changes are
  /// only kept on the phone. Never throws: the phone copy is already saved.
  Future<void> _sync() async {
    final cloud = _cloud;
    final uid = _uid;
    if (cloud == null || uid == null || !_progressLoaded || _catalog == null) return;
    try {
      if (_mergedFor != uid) {
        await (_merging ??= _merge(cloud, uid).whenComplete(() => _merging = null));
        if (_mergedFor != uid) return; // not read yet: wait for the next save
      }
      if (_push(cloud, uid)) await _store.save(_snapshot);
    } catch (e) {
      // Offline with nothing cached: tried again after the next save.
      debugPrint('[Learning] sync skipped: $e');
    }
  }

  /// Reads the account's cloud copy and merges it in, keeping the best.
  /// XP paid on the phone before this is counted once: the merge adds only
  /// paid ids the cloud doesn't have. Then sends what the cloud is missing.
  Future<void> _merge(ProgressCloud cloud, String uid) async {
    final remote = await cloud.fetch(uid);
    if (_uid != uid) return; // signed out or switched while reading
    _snapshot = mergeProgress(local: _snapshot, cloud: remote, xpOf: xpOfPaidId)
      ..ownerUid = uid
      ..cloud = remote;
    _mergedFor = uid;
    _push(cloud, uid);
    notifyListeners();
    await _store.save(_snapshot);
  }

  /// One batch of merge writes with only what raises the known cloud copy:
  /// new paid ids (and their XP as an increment), higher lesson values, a
  /// later streak day, more lessons completed, and finished quiz attempts.
  /// Returns false when there was nothing to send.
  bool _push(ProgressCloud cloud, String uid) {
    final known = _snapshot.cloud;
    if (known == null || _snapshot.ownerUid != uid) return false;
    final update = raiseCloud(local: _snapshot, known: known, xpOf: xpOfPaidId);
    if (update.isEmpty) return false;
    cloud.write(uid, update);
    _snapshot.pendingAttempts.clear();
    return true;
  }

  @override
  void dispose() {
    _accounts?.cancel();
    super.dispose();
  }

  // ── Debug tools (debug builds only, see the Learn screen menu) ────────

  /// Replaces all lesson progress, to try the S01/S02 states. Not used in
  /// release builds.
  Future<void> debugReplaceLessons(Map<String, LessonProgress> lessons) async {
    assert(kDebugMode, 'debug only');
    _snapshot.lessons
      ..clear()
      ..addAll(lessons);
    notifyListeners();
    await _store.save(_snapshot);
    await _sync();
  }

  /// "Reset all progress": the phone copy starts fresh and, when signed in,
  /// this account's cloud progress is deleted too (progress fields and paid
  /// on users/{uid}, lessonProgress, quizAttempts; never the profile or
  /// role), so testing starts clean. Returns false if the cloud could not
  /// be cleared (then the next app start merges it back).
  Future<bool> debugResetAll() async {
    assert(kDebugMode, 'debug only');
    final uid = _uid;
    _snapshot = ProgressSnapshot(ownerUid: uid ?? _snapshot.ownerUid);
    _mergedFor = null;
    var cleared = true;
    final cloud = _cloud;
    if (cloud != null && uid != null) {
      try {
        await cloud.deleteProgress(uid).timeout(const Duration(seconds: 15));
        // The cloud is now known to be empty: later writes start from 0.
        _snapshot.cloud = CloudProgress();
        _mergedFor = uid;
      } catch (e) {
        debugPrint('[Learning] could not clear cloud progress: $e');
        cleared = false;
      }
    }
    notifyListeners();
    await _store.save(_snapshot);
    return cleared;
  }
}

/// What [LearningProgress.saveQuizResult] saved, for the result screen.
class QuizAttemptResult {
  const QuizAttemptResult({
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.passed,
    bool? lessonPassed,
  }) : lessonPassed = lessonPassed ?? passed;

  /// Right answers among the scored questions.
  final int correct;

  /// Scored questions.
  final int total;

  /// XP paid by this attempt (questions right for the first time).
  final int xpEarned;

  /// This attempt reached the pass mark.
  final bool passed;

  /// The quiz has been passed, now or before (the next lesson is open).
  final bool lessonPassed;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();
}
