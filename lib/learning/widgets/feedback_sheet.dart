import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';
import 'parts/part_common.dart';

/// F01–F04: which feedback sheet to show.
enum FeedbackType {
  /// F01 Correct (green).
  correct,

  /// F02 Wrong (red).
  wrong,

  /// F03 Time's up (coral). Used by the quiz in step 4.
  timeout,

  /// F04 Sample answer (lavender). Used by the quiz in step 4.
  info,
}

/// Shows a feedback sheet over a dimmed screen. Tapping the scrim or
/// dragging does not close it; only Continue does (§5).
Future<void> showFeedbackSheet(
  BuildContext context, {
  required FeedbackType type,
  String? title,
  int? xp,
  String? answer,
  String? answerAudio,
  String? detail,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PopScope(
      canPop: false,
      child: FeedbackSheet(
        type: type,
        title: title,
        xp: xp,
        answer: answer,
        answerAudio: answerAudio,
        detail: detail,
      ),
    ),
  );
}

/// The sheet itself (Figma "Feedback · Correct / Wrong / Time's up /
/// Sample answer"): firefly, title, detail lines and a full-width Continue.
class FeedbackSheet extends StatelessWidget {
  const FeedbackSheet({
    super.key,
    required this.type,
    this.title,
    this.xp,
    this.answer,
    this.answerAudio,
    this.detail,
  });

  final FeedbackType type;

  /// Overrides the default title (e.g. "Time's up!" in step 4).
  final String? title;

  /// "+N XP" on F01; null hides it (already paid).
  final int? xp;

  /// The correct answer (F02, F03) or the model answer (F04).
  final String? answer;

  /// Audio for [answer], or null (no button).
  final String? answerAudio;

  /// The explain line (P06) or other detail.
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (background, accent, button, buttonText, mascot) = switch (type) {
      FeedbackType.correct => (
          V6Colors.successContainer,
          V6Colors.success,
          V6Colors.primary,
          V6Colors.onPrimary,
          'firefly_celebrate',
        ),
      FeedbackType.wrong => (
          V6Colors.errorContainer,
          V6Colors.coralText,
          V6Colors.coral,
          V6Colors.primaryStrong,
          'firefly_idk',
        ),
      FeedbackType.timeout => (
          V6Colors.coralContainer,
          V6Colors.coralText,
          V6Colors.coral,
          V6Colors.primaryStrong,
          'firefly_thinking',
        ),
      FeedbackType.info => (
          V6Colors.primaryContainer,
          V6Colors.primary,
          V6Colors.primary,
          V6Colors.onPrimary,
          'firefly_writing',
        ),
    };
    final heading = title ??
        switch (type) {
          FeedbackType.correct => t.feedbackCorrect,
          FeedbackType.wrong || FeedbackType.timeout => t.feedbackWrong,
          FeedbackType.info => '',
        };

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 16 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/mascots/$mascot.webp',
                width: 56,
                height: 56,
                errorBuilder: (_, _, _) => const SizedBox(width: 56, height: 56),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading.isNotEmpty)
                      Text(heading, style: V6Text.headlineMediumExtraBold.copyWith(color: accent)),
                    if (xp != null)
                      Text(t.xpGain(xp!), style: V6Text.labelLargeBold.copyWith(color: accent)),
                    if (answer != null && type != FeedbackType.correct) ...[
                      const SizedBox(height: 2),
                      Text(t.correctAnswerLabel,
                          style: V6Text.labelLargeBold.copyWith(color: accent)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              answer!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: V6Text.bodyLargeBold,
                            ),
                          ),
                          if (answerAudio != null)
                            AudioButton(
                              clip: answerAudio!,
                              label: t.playAudio,
                              size: 32,
                              background: Colors.transparent,
                              foreground: accent,
                            ),
                        ],
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: 4),
                      Text(detail!, style: V6Text.labelLargeSemiBold.copyWith(color: accent)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: button,
                foregroundColor: buttonText,
                textStyle: V6Text.button,
                shape: const StadiumBorder(),
              ),
              child: Text(t.continueButton),
            ),
          ),
        ],
      ),
    );
  }
}
