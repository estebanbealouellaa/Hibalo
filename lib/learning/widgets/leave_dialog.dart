import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';

/// S06 · Leave pop-up, lesson version. Returns true for Leave; Keep going,
/// the scrim and system back all return false and keep the exact state.
Future<bool> showLeaveLessonDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return _show(context, t.leaveLessonTitle, t.leaveLessonText);
}

/// S06 · Leave pop-up, quiz version ("Your answers won't be saved.").
Future<bool> showLeaveQuizDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return _show(context, t.leaveQuizTitle, t.leaveQuizText);
}

Future<bool> _show(BuildContext context, String title, String text) async {
  final leave = await showDialog<bool>(
    context: context,
    // Figma scrim: Primary Strong at 45%.
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
    builder: (_) => LeaveDialog(title: title, text: text),
  );
  return leave ?? false;
}

class LeaveDialog extends StatelessWidget {
  const LeaveDialog({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: V6Colors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // Figma "Dialog": 311 wide, padding 24/24/20, 12 between items.
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // "Mascot circle · firefly_wrong": an 88 circle with the firefly
            // drawn larger on top (it spills past the 113 x 128 box).
            Center(
              child: SizedBox(
                width: 113,
                height: 128,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 13,
                      top: 40,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          color: V6Colors.coralTonal,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -17,
                      top: -11,
                      width: 148,
                      height: 147,
                      child: Image.asset(
                        'assets/images/mascots/firefly_wrong.webp',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: V6Text.titleLargeExtraBold),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: FilledButton.styleFrom(
                  backgroundColor: V6Colors.primary,
                  foregroundColor: V6Colors.onPrimary,
                  textStyle: V6Text.button,
                  shape: const StadiumBorder(),
                ),
                child: Text(t.keepGoing),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: V6Colors.error,
                  textStyle: V6Text.button,
                ),
                child: Text(t.leave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
