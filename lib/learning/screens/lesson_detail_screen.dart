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
import '../widgets/lesson_image.dart';

/// S02 Lesson Detail: not started, in progress or completed (Lesson 1 uses the same layout).
class LessonDetailScreen extends StatelessWidget {
  const LessonDetailScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgress>();
    final t = AppLocalizations.of(context);
    final lesson = progress.isReady ? progress.catalog.lessonById(lessonId) : null;

    return LearningTheme(
      child: Scaffold(
        backgroundColor: V6Colors.background,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: t.back,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          titleSpacing: 0,
          toolbarHeight: 64,
          title: lesson == null ? null : Text(t.lessonNumber(lesson.order)),
        ),
        body: lesson == null
            ? const Center(child: CircularProgressIndicator(color: V6Colors.primary))
            : _Body(lesson: lesson, progress: progress),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.lesson, required this.progress});

  final Lesson lesson;
  final LearningProgress progress;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rules = progress.rules;
    final state = rules.detailState(lesson);
    final done = rules.partsDone(lesson);
    final settings = progress.catalog.settings;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner: 335 × 197, cover-cropped; firefly on light violet if missing.
          AspectRatio(
            aspectRatio: 335 / 197,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LessonImage(
                path: lesson.coverImage,
                fallback: settings.missingPicture,
                fallbackColor: V6Colors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            lesson.title,
            textAlign: TextAlign.center,
            style: V6Text.headlineMediumExtraBold,
          ),
          const SizedBox(height: 6),
          Center(child: _Chip(t.lessonMeta(lesson.partsCount, lesson.estMinutes))),
          if (state == LessonDetailState.completed) ...[
            const SizedBox(height: 6),
            Center(child: _Chip(_completedChipText(t))),
          ],
          const SizedBox(height: 16),
          Text(t.inThisLesson, style: V6Text.titleMedium),
          for (final objective in lesson.objectives) ...[
            const SizedBox(height: 10),
            _Objective(objective),
          ],
          const SizedBox(height: 16),
          _PrimaryButton(
            label: switch (state) {
              LessonDetailState.notStarted => t.startLesson,
              LessonDetailState.inProgress => t.continueLesson,
              LessonDetailState.completed => t.reviewLesson,
            },
            onPressed: () => LearningRoutes.openLessonPlayer(
              context,
              lesson,
              startPart: state == LessonDetailState.inProgress
                  ? rules.firstUnfinishedPart(lesson)
                  : 0,
              review: state == LessonDetailState.completed,
            ),
          ),
          if (state == LessonDetailState.completed && lesson.hasQuiz) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => LearningRoutes.openQuiz(context, lesson),
                style: TextButton.styleFrom(
                  foregroundColor: V6Colors.primary,
                  textStyle: V6Text.button,
                ),
                child: Text(t.retakeQuiz),
              ),
            ),
          ],
          if (state != LessonDetailState.completed) ...[
            const SizedBox(height: 16),
            _ProgressCard(done: done, total: lesson.partsCount),
          ],
        ],
      ),
    );
  }

  /// "Completed · Quiz 7/8" with the best quiz score, or just "Completed"
  /// when there is no quiz (Lesson 1) or no finished attempt yet.
  String _completedChipText(AppLocalizations t) {
    final quiz = lesson.quiz;
    final best = progress.progressFor(lesson.id).bestScore;
    if (quiz == null || best == null) return t.completedChip;
    return t.completedQuizChip(best, quiz.scoredQuestions.length);
  }
}

/// Citrus pill: "12 parts • 10 min" or "Completed · Quiz 7/8".
class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const ShapeDecoration(color: V6Colors.citrus, shape: StadiumBorder()),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: V6Text.labelMedium.copyWith(color: V6Colors.onCitrus),
      ),
    );
  }
}

class _Objective extends StatelessWidget {
  const _Objective(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: V6Colors.citrus, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, size: 17, color: V6Colors.primaryStrong),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: V6Colors.primary,
          foregroundColor: V6Colors.onPrimary,
          textStyle: V6Text.button,
          shape: const StadiumBorder(),
        ),
        child: Text(label),
      ),
    );
  }
}

/// "Lesson progress" card with the bar and "X / N parts".
class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.lessonProgressTitle, style: V6Text.labelLargeBold),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(V6Spacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : done / total,
                    minHeight: 8,
                    color: V6Colors.primary,
                    backgroundColor: V6Colors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                t.partsProgress(done, total),
                style: V6Text.labelLargeBold.copyWith(color: V6Colors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
