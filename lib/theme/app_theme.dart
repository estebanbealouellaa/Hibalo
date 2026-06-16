import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  /// DM Sans fallback (Segoe UI on Windows).
  static const String _font = 'Segoe UI';

  static TextStyle get screenTitle => const TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static TextStyle get badgeText => const TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: purple,
  );

  static TextStyle get displayLarge => const TextStyle(
    fontFamily: _font,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: ink,
    height: 1.0,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: ink,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: ink,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: inkSoft,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: inkMuted,
  );

  static TextStyle get labelCaps => const TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.2,
    color: inkMuted,
  );

  static BoxDecoration purpleHeroDecoration({double radius = 32}) =>
      BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [purple, purpleMid],
        ),
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration cardDecoration({Color? color, double radius = 16}) =>
      BoxDecoration(
        color: color ?? offWhite,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderLight),
      );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: _font,
      scaffoldBackgroundColor: white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: purple,
        brightness: Brightness.light,
        primary: purple,
        surface: offWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: _font,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: offWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderMid),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderMid),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: purple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight),
        ),
      ),
    );
  }
}
