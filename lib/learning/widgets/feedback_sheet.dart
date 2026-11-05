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
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
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
          'firefly_wrong',
        ),
      FeedbackType.timeout => (
          V6Colors.coralContainer,
          V6Colors.coralText,
          V6Colors.coral,
          V6Colors.primaryStrong,
          'firefly_wrong',
        ),
      FeedbackType.info => (
          V6Colors.primaryContainer,
          V6Colors.primary,
          V6Colors.primary,
          V6Colors.onPrimary,
          'firefly_reading',
        ),
    };
    final heading = title ??
        switch (type) {
          FeedbackType.correct => t.feedbackCorrect,
          FeedbackType.wrong || FeedbackType.timeout => t.feedbackWrong,
          FeedbackType.info => '',
        };

    // Figma "Feedback Sheet": padding 20, radius 24 on top, 16 between the
    // top row and Continue; a 64 x 72 firefly, then the title
    // (Headline/Medium · ExtraBold) and its lines, 4 apart. The 24 px
    // gesture bar in Figma is the system's: only the real inset is added.
    final detailColor = type == FeedbackType.correct ? V6Colors.success : V6Colors.error;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/mascots/$mascot.webp',
                width: 64,
                height: 72,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox(width: 64, height: 72),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading.isNotEmpty)
                      Text(heading, style: V6Text.headlineMediumExtraBold.copyWith(color: accent)),
                    if (xp != null) ...[
                      const SizedBox(height: 4),
                      Text(t.xpGain(xp!), style: V6Text.labelLargeBold.copyWith(color: accent)),
                    ],
                    if (answer != null && type != FeedbackType.correct) ...[
                      const SizedBox(height: 4),
                      Text(
                        type == FeedbackType.info ? '' : t.correctAnswerLabel,
                        style: V6Text.labelLargeBold.copyWith(color: detailColor),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              answer!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: V6Text.hilWordExtraBold,
                            ),
                          ),
                          // Shown when the JSON has answerAudio, even before
                          // the clip is recorded (it then plays nothing).
                          if (answerAudio != null) ...[
                            const SizedBox(width: 8),
                            AudioButton(
                              clip: answerAudio,
                              label: t.playAudio,
                              size: 24,
                              iconSize: 24,
                              background: Colors.transparent,
                              foreground: detailColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                    if (detail != null) ...[
                      const SizedBox(height: 4),
                      Text(detail!, style: V6Text.labelLargeBold.copyWith(color: detailColor)),
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
