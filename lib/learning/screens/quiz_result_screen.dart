import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../logic/quiz_logic.dart';
import '../models/catalog.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';
import '../widgets/result_parts.dart';

/// S04 Quiz result; the attempt is already saved.
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({super.key, required this.lessonId, required this.result, required this.answers});

  final String lessonId;
  final QuizAttemptResult result;

  final List<AnsweredQuestion> answers;

  /// The chip text and whether it shows as unlocked.
  static (String, bool) chipFor(AppLocalizations t, LessonCatalog catalog, Lesson lesson, QuizAttemptResult result) {
    final next = catalog.nextLesson(lesson.id);
    final level = catalog.levelOf(lesson.id)!;
    // A lesson passed before keeps the next one open, even after a weaker
    // retake.
    if (result.lessonPassed) {
      return (next == null ? t.levelCompleteChip(level.title) : t.lessonUnlockedChip(next.order), true);
    }
    return (next == null ? t.passToFinishLevelChip(level.title) : t.passToUnlockChip(next.order), false);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final catalog = context.read<LearningProgress>().catalog;
    final lesson = catalog.lessonById(lessonId)!;
    final ratio = result.total == 0 ? 0.0 : result.correct / result.total;
    final tier = catalog.settings.tierFor(ratio);
    final passed = result.passed;
    final (chip, unlocked) = chipFor(t, catalog, lesson, result);

    void review() async {
      final again = await LearningRoutes.openQuizReview(context, lesson, result, answers);
      if (again == true && context.mounted) LearningRoutes.startQuiz(context, lesson, replace: true);
    }

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
                FireflyGlow(
                  mascot: passed ? 'firefly_celebrate' : 'firefly_wrong',
                  glow: passed ? V6Colors.citrus : V6Colors.coralTonal,
                ),
                Text(
                  tier.title,
                  textAlign: TextAlign.center,
                  style: V6Text.headlineXl.copyWith(color: V6Colors.textPrimary),
                ),
                Text(
                  passed
                      ? t.quizScoreLinePassed(result.correct, result.total)
                      : t.quizScoreLine(result.correct, result.total),
                  textAlign: TextAlign.center,
                  style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
                ),
                StatRow(
                  left: StatTile(
                    value: t.xpGain(result.xpEarned),
                    label: t.xpEarnedLabel,
                    background: V6Colors.glowTonal,
                    foreground: V6Colors.glowText,
                  ),
                  right: StatTile(
                    value: t.accuracyValue(result.percent),
                    label: t.accuracyLabel,
                    background: passed ? V6Colors.lagoonContainer : V6Colors.coralContainer,
                    foreground: passed ? V6Colors.lagoonText : V6Colors.coralText,
                  ),
                ),
                UnlockChip(text: chip, unlocked: unlocked),
              ],
              buttons: [
                passed
                    ? ResultPrimaryButton(label: t.continueButton, onPressed: () => LearningRoutes.backToLearn(context))
                    : ResultPrimaryButton(
                        label: t.tryAgain,
                        onPressed: () => LearningRoutes.startQuiz(context, lesson, replace: true),
                      ),
                ResultTextButton(label: t.reviewAnswers, onPressed: review),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
