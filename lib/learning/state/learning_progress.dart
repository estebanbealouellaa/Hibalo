import 'package:flutter/foundation.dart';

import '../data/lesson_repository.dart';
import '../logic/streak.dart';
import '../logic/unlocking.dart';
import '../models/catalog.dart';
import '../models/progress.dart';
import '../services/progress_store.dart';

/// The learner's progress for the whole app: lessons, XP, streak and
/// unlocking. Provided at the top of the app, so Home, Me, Translate and the
/// learning screens all show the same numbers.
///
/// Loads in two halves: the saved progress (fast, for the stat chips) and the
/// lessons (for the Learn screens). Finished parts, lesson XP and the streak
/// are saved on the phone here; quiz results and Firestore sync come in
/// steps 4–5.
class LearningProgress extends ChangeNotifier {
  LearningProgress({
    ProgressStore? store,
    Future<LessonRepository> Function()? loadLessons,
    DateTime Function()? clock,
  })  : _store = store ?? ProgressStore(),
        _loadLessons = loadLessons ?? LessonRepository.instance,
        _clock = clock ?? DateTime.now;

  /// A ready-made instance for tests and previews: no loading needed.
  @visibleForTesting
  LearningProgress.ready(
    LessonCatalog catalog,
    ProgressSnapshot snapshot, {
    ProgressStore? store,
    DateTime Function()? clock,
  })  : _store = store ?? ProgressStore(),
        _loadLessons = LessonRepository.instance,
        _clock = clock ?? DateTime.now,
        _catalog = catalog,
        _snapshot = snapshot,
        _progressLoaded = true;

  final ProgressStore _store;
  final Future<LessonRepository> Function() _loadLessons;
  final DateTime Function() _clock;

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
        notifyListeners();
      }
      _catalog ??= (await _loadLessons()).catalog;
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
  Future<bool> payXpOnce(String id, int amount) async {
    if (!_snapshot.paid.add(id)) return false;
    _snapshot.xp += amount;
    notifyListeners();
    await _store.save(_snapshot);
    return true;
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
  }

  /// Pays the lesson XP after the last part, once. Returns true if it paid.
  Future<bool> payLessonComplete(Lesson lesson) =>
      payXpOnce(lessonPaidId(lesson.id), catalog.settings.xp.lessonComplete);

  /// Quiz questions are paid once each, the first time they are right.
  static String questionPaidId(String lessonId, String questionId) =>
      'question:$lessonId:$questionId';

  /// Saves a finished quiz attempt on the phone (§1.10): the best score,
  /// passed (≥ pass mark, which unlocks the next lesson), the streak day, and
  /// XP for the scored questions [rightIds] that were never right before.
  /// Called once when the last question ends; leaving a quiz saves nothing.
  /// (The Firestore sync comes in step 5.)
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
    _markActiveToday();
    notifyListeners();
    await _store.save(_snapshot);
    return QuizAttemptResult(correct: correct, total: total, xpEarned: xpEarned, passed: passed);
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

  // ── Debug tools (debug builds only, see the Learn screen menu) ────────

  /// Replaces all lesson progress, to try the S01/S02 states before the
  /// lesson and quiz players exist. Not used in release builds.
  Future<void> debugReplaceLessons(Map<String, LessonProgress> lessons) async {
    assert(kDebugMode, 'debug only');
    _snapshot.lessons
      ..clear()
      ..addAll(lessons);
    if (lessons.isEmpty) {
      // "Reset all progress" starts completely fresh.
      _snapshot
        ..xp = 0
        ..streak = 0
        ..lastActiveDate = null
        ..paid.clear();
    }
    notifyListeners();
    await _store.save(_snapshot);
  }
}

/// What [LearningProgress.saveQuizResult] saved, for the result screen.
class QuizAttemptResult {
  const QuizAttemptResult({
    required this.correct,
    required this.total,
    required this.xpEarned,
    required this.passed,
  });

  /// Right answers among the scored questions.
  final int correct;

  /// Scored questions.
  final int total;

  /// XP paid by this attempt (questions right for the first time).
  final int xpEarned;

  /// This attempt reached the pass mark.
  final bool passed;

  int get percent => total == 0 ? 0 : (correct * 100 / total).round();
}
