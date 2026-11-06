import 'package:flutter/material.dart';

import 'v6_colors.dart';
import 'v6_text.dart';

/// The V6 look for the learning screens only (wrap them in [LearningTheme]).
ThemeData buildLearningTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: V6Colors.primary,
    brightness: Brightness.light,
  ).copyWith(
    primary: V6Colors.primary,
    onPrimary: V6Colors.onPrimary,
    primaryContainer: V6Colors.primaryContainer,
    onPrimaryContainer: V6Colors.onPrimaryContainer,
    secondary: V6Colors.citrus,
    onSecondary: V6Colors.onCitrus,
    tertiary: V6Colors.lagoon,
    error: V6Colors.error,
    errorContainer: V6Colors.errorContainer,
    surface: V6Colors.surface,
    onSurface: V6Colors.textPrimary,
    onSurfaceVariant: V6Colors.textMuted,
    outline: V6Colors.borderInput,
    outlineVariant: V6Colors.borderDivider,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: kV6FontFamily,
    scaffoldBackgroundColor: V6Colors.background,
    textTheme: TextTheme(
      headlineLarge: V6Text.headlineXl,
      headlineMedium: V6Text.headlineMedium,
      titleLarge: V6Text.titleLarge,
      titleMedium: V6Text.titleMedium,
      bodyLarge: V6Text.bodyLarge,
      bodyMedium: V6Text.bodyMedium,
      labelLarge: V6Text.labelLarge,
      labelMedium: V6Text.labelMedium,
      labelSmall: V6Text.labelSmall,
      bodySmall: V6Text.caption,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: V6Colors.background,
      foregroundColor: V6Colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: V6Text.appBarTitle,
    ),
    dividerTheme: const DividerThemeData(color: V6Colors.borderDivider),
  );
}

class LearningTheme extends StatelessWidget {
  const LearningTheme({super.key, required this.child});

  final Widget child;

  static final ThemeData _theme = buildLearningTheme();

  @override
  Widget build(BuildContext context) => Theme(data: _theme, child: child);
}
