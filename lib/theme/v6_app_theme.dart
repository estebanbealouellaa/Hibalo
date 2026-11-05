import 'package:flutter/material.dart';

import '../learning/theme/v6_colors.dart';
import '../learning/theme/v6_text.dart';
import '../learning/theme/v6_theme.dart';

/// The app-wide V6 theme. It starts from the Learning theme (same tokens,
/// same Plus Jakarta Sans) and adds what the other screens need. The
/// Learning screens keep their own [LearningTheme] wrapper, so nothing here
/// changes how they look.
ThemeData buildAppTheme() {
  final base = buildLearningTheme();
  return base.copyWith(
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: V6Colors.primaryStrong,
      contentTextStyle: V6Text.labelLargeSemiBold.copyWith(color: V6Colors.onPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(color: V6Colors.primary),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: V6Colors.primary,
      selectionColor: V6Colors.primary.withValues(alpha: 0.25),
      selectionHandleColor: V6Colors.primary,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: V6Colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: V6Text.titleLargeBold,
      contentTextStyle: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: V6Colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
