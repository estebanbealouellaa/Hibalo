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
/// lessons (for the Learn screens). Saving parts, quizzes and XP is added in
/// steps 3–5; Firestore sync in step 5.
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

  // ── Debug tools (debug builds only, see the Learn screen menu) ────────

  /// Replaces all lesson progress, to try the S01/S02 states before the
  /// lesson and quiz players exist. Not used in release builds.
  Future<void> debugReplaceLessons(Map<String, LessonProgress> lessons) async {
    assert(kDebugMode, 'debug only');
    _snapshot.lessons
      ..clear()
      ..addAll(lessons);
    notifyListeners();
    await _store.save(_snapshot);
  }
}
