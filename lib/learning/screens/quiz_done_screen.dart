import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../learning_routes.dart';
import '../state/learning_progress.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import '../theme/v6_theme.dart';

/// TEMPORARY stand-in for S04 Quiz result (built in step 5): the score,
/// accuracy and XP the attempt earned, whether it passed, and a way back to
/// the lessons. The attempt is already saved when this shows.
class QuizDoneScreen extends StatelessWidget {
  const QuizDoneScreen({super.key, required this.result});

  final QuizAttemptResult result;

  void _backToLessons(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == LearningRoutes.learnRoute || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToLessons(context);
      },
      child: LearningTheme(
        child: Scaffold(
          backgroundColor: V6Colors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/mascots/${result.passed ? 'firefly_celebrate' : 'firefly_thinking'}.webp',
                            width: 140,
                            height: 140,
                            errorBuilder: (_, _, _) => const SizedBox(width: 140, height: 140),
                          ),
                          const SizedBox(height: 12),
                          Text(t.quizDoneTitle, style: V6Text.headlineMediumExtraBold),
                          const SizedBox(height: 8),
                          Text(
                            t.quizDoneScore(result.correct, result.total),
                            textAlign: TextAlign.center,
                            style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: _Tile(label: t.quizDoneXp, value: t.xpGain(result.xpEarned))),
                              const SizedBox(width: 12),
                              Expanded(child: _Tile(label: t.quizDoneAccuracy, value: '${result.percent}%')),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            result.passed ? t.quizDonePassed : t.quizDoneNotPassed,
                            textAlign: TextAlign.center,
                            style: V6Text.titleMedium.copyWith(
                              color: result.passed ? V6Colors.success : V6Colors.coralText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.quizDoneNote,
                            textAlign: TextAlign.center,
                            style: V6Text.caption.copyWith(color: V6Colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () => _backToLessons(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: V6Colors.primary,
                        foregroundColor: V6Colors.onPrimary,
                        textStyle: V6Text.button,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(t.backToLessons),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        children: [
          Text(value, style: V6Text.headlineMediumExtraBold.copyWith(color: V6Colors.primary)),
          const SizedBox(height: 2),
          Text(label, style: V6Text.labelMedium.copyWith(color: V6Colors.textMuted)),
        ],
      ),
    );
  }
}
