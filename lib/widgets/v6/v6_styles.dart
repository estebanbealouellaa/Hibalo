import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import '../../learning/theme/v6_text.dart';

/// V6 text styles used outside the Learning module that the learning tokens
/// (lib/learning/theme/v6_text.dart) don't have. Same Figma names; the
/// learning files stay untouched.
abstract final class V6AppText {
  static TextStyle _s(double size, FontWeight weight, double? lineHeightPx, {double letterSpacing = 0}) =>
      TextStyle(
        fontFamily: kV6FontFamily,
        fontSize: size,
        fontWeight: weight,
        height: lineHeightPx == null ? null : lineHeightPx / size,
        letterSpacing: letterSpacing,
        color: V6Colors.textPrimary,
      );

  /// V6/Wordmark/Small: "HIBALO" (letter spacing 10% of 14).
  static final wordmarkSmall = _s(14, FontWeight.w800, 14, letterSpacing: 1.4);

  /// V6/Display/Wordmark: "Hibalo" on the splash.
  static final displayWordmark = _s(48, FontWeight.w800, 48);

  /// V6/Label/Field: the uppercase field label on auth screens.
  static final labelField = _s(12, FontWeight.w800, 20, letterSpacing: 0.72);

  /// V6/Headline/Large · ExtraBold.
  static final headlineLargeExtraBold = _s(28, FontWeight.w800, 36, letterSpacing: -0.2);

  /// V6/Body/Large · Medium.
  static final bodyLargeMedium = V6Text.bodyLargeMedium;
}
