import 'package:flutter/material.dart';

import '../theme/v6_colors.dart';
import '../theme/v6_text.dart';

/// The short dark message used on the Learn screens (Figma: "Finish Beginner
/// to unlock Intermediate"). Replaces any message already showing.
void showLearningSnackBar(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle_rounded,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: V6Colors.primaryStrong,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(V6Spacing.radiusMedium)),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: V6Colors.citrus, size: 20),
          const SizedBox(width: V6Spacing.s12),
          Expanded(
            child: Text(
              message,
              style: V6Text.labelLargeSemiBold.copyWith(color: V6Colors.onPrimary),
            ),
          ),
        ],
      ),
    ),
  );
}
