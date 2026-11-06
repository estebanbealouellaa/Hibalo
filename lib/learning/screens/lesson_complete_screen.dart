import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/result_parts.dart';

/// S03 Lesson complete, after the last part or from a "Quiz pending" row on S01.
class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({super.key, required this.lessonId, required this.xpJustPaid});

  final String lessonId;

  /// True right after the lesson XP was paid; false when it was paid
  /// before (reopened from S01, or a review).
  final bool xpJustPaid;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final progress = context.read<LearningProgress>();
    final catalog = progress.catalog;
    final lesson = catalog.lessonById(lessonId)!;
    final xp = catalog.settings.xp.lessonComplete;
    final next = catalog.nextLesson(lesson.id);
    final letters = !lesson.hasQuiz;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) LearningRoutes.backToLearn(context);
      },
      child: LearningTheme(
        child: Scaffold(
          backgroundColor: V6Colors.background,
          body: SafeArea(
            child: ResultBody(
              top: [
                const FireflyGlow(mascot: 'firefly_celebrate', glow: V6Colors.citrus),
                Text(
                  t.lessonCompleteTitle,
                  textAlign: TextAlign.center,
                  style: V6Text.headlineXl.copyWith(color: V6Colors.textPrimary),
                ),
                Text(
                  t.lessonCompleteLine(lesson.order, lesson.title),
                  textAlign: TextAlign.center,
                  style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
                ),
                StatRow(
                  gap: 10,
                  left: StatTile(
                    value: xpJustPaid ? t.statXpPlus(xp) : '$xp',
                    label: xpJustPaid ? t.statXpLabel : t.xpAlreadyEarned,
                    background: V6Colors.glowTonal,
                    foreground: V6Colors.glowText,
                  ),
                  right: StatTile(
                    value: '${letters ? lesson.letters.length : lesson.newWordsCount}',
                    label: letters ? t.lettersLabel : t.newWordsLabel,
                    background: V6Colors.coralContainer,
                    foreground: V6Colors.coralText,
                  ),
                ),
                if (letters && next != null) UnlockChip(text: t.lessonUnlockedChip(next.order), unlocked: true),
              ],
              buttons: [
                if (!letters)
                  ResultPrimaryButton(
                    label: t.takeLessonQuiz,
                    onPressed: () => LearningRoutes.startQuiz(context, lesson, replace: true),
                  )
                else if (next != null)
                  ResultPrimaryButton(
                    label: t.continueToLesson(next.order),
                    onPressed: () => LearningRoutes.openLessonDetailFromLearn(context, next),
                  ),
                ResultTextButton(label: t.backToLessons, onPressed: () => LearningRoutes.backToLearn(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
