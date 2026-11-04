import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';

/// S06 · Leave pop-up, lesson version. (The quiz version is added with the
/// quiz in step 4.) Returns true for Leave; Keep going, the scrim and system
/// back all return false and keep the exact state.
Future<bool> showLeaveLessonDialog(BuildContext context) async {
  final t = AppLocalizations.of(context);
  final leave = await showDialog<bool>(
    context: context,
    builder: (_) => LeaveDialog(title: t.leaveLessonTitle, text: t.leaveLessonText),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: V6Colors.coralTonal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned.fill(
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
            Text(title, textAlign: TextAlign.center, style: V6Text.titleLargeBold),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 4),
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
