import 'package:flutter/material.dart';

import '../learning/theme/v6_text.dart';
import 'app_colors.dart';
import 'v6_app_theme.dart';

class AppTheme {
  /// Plus Jakarta Sans (bundled), the V6 font, everywhere.
  static const String _font = kV6FontFamily;

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

  /// The app-wide V6 theme (see v6_app_theme.dart).
  static ThemeData light() => buildAppTheme();

}
