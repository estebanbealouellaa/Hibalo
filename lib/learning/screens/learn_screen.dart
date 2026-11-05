import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../logic/unlocking.dart';
import '../models/catalog.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/learning_snack_bar.dart';
import '../widgets/lesson_row.dart';
import 'learn_debug_menu.dart';

/// S01 · Learn: search, level tabs and the lesson list of the chosen level.
/// Everything comes from lessons.json and the saved progress.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final _search = TextEditingController();
  String _query = '';

  /// The chosen level tab (index into catalog.levels).
  int _levelIndex = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgress>();
    final t = AppLocalizations.of(context);

    return LearningTheme(
      child: Scaffold(
        backgroundColor: V6Colors.background,
        // Tapping anywhere outside the search field closes the keyboard.
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            child: !progress.isReady
                ? _NotReady(progress: progress)
                : _content(context, progress, t),
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, LearningProgress progress, AppLocalizations t) {
    final catalog = progress.catalog;
    final rules = progress.rules;
    final levels = catalog.levels;
    final level = levels[_levelIndex.clamp(0, levels.length - 1)];
    final lessons = _filter(level.lessons);
    // Figma "No results": the "Lessons" heading is hidden.
    final noResults = level.lessons.isNotEmpty && lessons.isEmpty;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.list(
            children: [
              _topBar(context, t),
              const SizedBox(height: 4),
              Text(
                t.learnSubtitle,
                style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
              ),
              const SizedBox(height: 14),
              _searchField(t),
              const SizedBox(height: 14),
              _levelTabs(context, rules, levels, t),
              ..._lockedHint(rules, levels, t),
              const SizedBox(height: 14),
              if (!noResults) ...[
                Text(t.learnLessonsHeading, style: V6Text.titleLarge),
                const SizedBox(height: 14),
              ],
            ],
          ),
        ),
        if (level.lessons.isEmpty)
          SliverToBoxAdapter(child: _Message(title: t.learnComingSoon))
        else if (lessons.isEmpty)
          SliverToBoxAdapter(
            child: _NoResults(
              query: _query.trim(),
              picture: 'assets/images/mascots/firefly_find.webp',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverList.separated(
              itemCount: lessons.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) =>
                  _row(context, catalog, rules, lessons[i], t),
            ),
          ),
      ],
    );
  }

  /// Lessons of the tab whose title contains the search text.
  List<Lesson> _filter(List<Lesson> lessons) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return lessons;
    return [for (final l in lessons) if (l.title.toLowerCase().contains(q)) l];
  }

  Widget _topBar(BuildContext context, AppLocalizations t) {
    // In the app S01 is the Learn tab (no back arrow; the bottom bar
    // replaces it). Pushed on its own (tests), it keeps the arrow. Asking the
    // route also rebuilds this when routes above it come and go.
    final canPop = !(ModalRoute.of(context)?.isFirst ?? true);
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              tooltip: t.back,
              icon: const Icon(Icons.arrow_back_rounded, color: V6Colors.textPrimary),
            ),
          Expanded(child: Text(t.learnTitle, style: V6Text.screenTitle)),
          if (kDebugMode)
            IconButton(
              onPressed: () => showLearnDebugMenu(context),
              tooltip: 'Debug: set progress',
              icon: const Icon(Icons.bug_report_outlined, color: V6Colors.textMuted),
            ),
        ],
      ),
    );
  }

  Widget _searchField(AppLocalizations t) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: V6Colors.borderDivider),
    );
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _search,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        style: V6Text.bodyMedium,
        decoration: InputDecoration(
          hintText: t.learnSearchHint,
          hintStyle: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 10),
            child: Icon(Icons.search_rounded, color: V6Colors.textSecondary),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 24),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _search.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close_rounded, color: V6Colors.textMuted),
                ),
          filled: true,
          fillColor: V6Colors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: V6Colors.borderFocus, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _levelTabs(
    BuildContext context,
    LearningRules rules,
    List<Level> levels,
    AppLocalizations t,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        // Room for the lock badge, which sticks out above the tab.
        padding: const EdgeInsets.only(top: 6, right: 6),
        child: Row(
          children: [
            for (var i = 0; i < levels.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _LevelTab(
                title: levels[i].title,
                selected: i == _levelIndex,
                locked: !rules.isLevelUnlocked(levels[i]),
                lockedLabel: t.rowLocked,
                onTap: () => _selectLevel(context, rules, levels[i], i, t),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectLevel(
    BuildContext context,
    LearningRules rules,
    Level level,
    int index,
    AppLocalizations t,
  ) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!rules.isLevelUnlocked(level)) {
      final previous = rules.blockingLevel(level);
      showLearningSnackBar(
        context,
        t.learnLevelLocked(previous?.title ?? '', level.title),
      );
      return;
    }
    setState(() => _levelIndex = index);
  }

  /// "Intermediate and Advanced: finish Beginner to unlock", while any
  /// level is locked.
  List<Widget> _lockedHint(LearningRules rules, List<Level> levels, AppLocalizations t) {
    final locked = [for (final l in levels) if (!rules.isLevelUnlocked(l)) l];
    if (locked.isEmpty) return const [];
    final blocking = rules.blockingLevel(locked.first);
    final names = locked.map((l) => l.title).toList();
    final joined = names.length == 1
        ? names.single
        : '${names.sublist(0, names.length - 1).join(', ')} ${t.listAnd} ${names.last}';
    return [
      const SizedBox(height: 14),
      Text(
        t.learnLockedLevelsHint(joined, blocking?.title ?? ''),
        style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
      ),
    ];
  }

  Widget _row(
    BuildContext context,
    LessonCatalog catalog,
    LearningRules rules,
    Lesson lesson,
    AppLocalizations t,
  ) {
    final state = rules.rowState(lesson);
    final meta = switch (state) {
      LessonRowState.completed ||
      LessonRowState.current =>
        t.lessonMeta(lesson.partsCount, lesson.estMinutes),
      LessonRowState.quizPending => _quizPendingText(catalog, lesson, t),
      LessonRowState.locked => _lockedText(rules, lesson, t),
    };

    return LessonRow(
      number: lesson.order,
      title: lesson.title,
      meta: meta,
      state: state,
      icon: lesson.icon,
      fallbackPicture: catalog.settings.missingPicture,
      stateLabel: switch (state) {
        LessonRowState.completed => t.rowCompleted,
        LessonRowState.locked => t.rowLocked,
        _ => null,
      },
      onTap: () {
        // Opening a lesson (or its message) closes the search keyboard.
        FocusManager.instance.primaryFocus?.unfocus();
        _onRowTap(context, lesson, state, meta);
      },
    );
  }

  void _onRowTap(BuildContext context, Lesson lesson, LessonRowState state, String meta) {
    switch (state) {
      case LessonRowState.completed || LessonRowState.current:
        LearningRoutes.openLessonDetail(context, lesson);
      case LessonRowState.quizPending:
        LearningRoutes.openLessonComplete(context, lesson);
      case LessonRowState.locked:
        showLearningSnackBar(context, meta, icon: Icons.lock_rounded);
    }
  }

  String _quizPendingText(LessonCatalog catalog, Lesson lesson, AppLocalizations t) {
    final next = catalog.nextLesson(lesson.id);
    if (next != null) return t.rowQuizPending(next.order);
    return t.rowQuizPendingLast(catalog.levelOf(lesson.id)?.title ?? '');
  }

  /// "Pass Lesson N quiz to unlock" / "Finish Lesson N to unlock".
  String _lockedText(LearningRules rules, Lesson lesson, AppLocalizations t) {
    final required = rules.requiredLesson(lesson);
    if (required == null) {
      // Locked only because its level is locked.
      final level = rules.catalog.levelOf(lesson.id);
      final previous = level == null ? null : rules.blockingLevel(level);
      return t.learnLevelLocked(previous?.title ?? '', level?.title ?? '');
    }
    return lesson.unlock.needs == UnlockNeed.complete
        ? t.rowLockedFinish(required.order)
        : t.rowLockedPassQuiz(required.order);
  }
}

/// One level tab (48 px pill), with a lock badge when locked.
class _LevelTab extends StatelessWidget {
  const _LevelTab({
    required this.title,
    required this.selected,
    required this.locked,
    required this.lockedLabel,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final bool locked;
  final String lockedLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? '$title, $lockedLabel' : title,
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: selected ? V6Colors.primary : V6Colors.neutralBackground,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: onTap,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: V6Text.labelLargeBold.copyWith(
                    color: selected ? V6Colors.onPrimary : V6Colors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          if (locked)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: V6Colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: V6Colors.primary, width: 1.5),
                ),
                child: const Icon(Icons.lock_rounded, size: 12, color: V6Colors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// "No lessons found for 'x'" with the searching firefly.
class _NoResults extends StatelessWidget {
  const _NoResults({required this.query, required this.picture});

  final String query;
  final String picture;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Figma "No results": 40 from the hint, a 140 x 160 firefly over a
    // 112 glow circle, then the two lines, 10 apart.
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
      child: Column(
        children: [
          SizedBox(
            width: 140,
            height: 160,
            child: Stack(
              children: [
                Positioned(
                  left: 14,
                  top: 48,
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(
                      color: V6Colors.glow,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Image.asset(
                    picture,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t.learnNoResultsTitle(query),
            textAlign: TextAlign.center,
            style: V6Text.titleLargeBold,
          ),
          const SizedBox(height: 10),
          Text(
            t.learnNoResultsHint,
            textAlign: TextAlign.center,
            style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
      ),
    );
  }
}

/// Shown while the lessons load, or if they couldn't be loaded.
class _NotReady extends StatelessWidget {
  const _NotReady({required this.progress});

  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (progress.loadError == null) {
      return const Center(child: CircularProgressIndicator(color: V6Colors.primary));
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.learnLoadError, style: V6Text.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: progress.load, child: Text(t.tryAgain)),
          ],
        ),
      ),
    );
  }
}
