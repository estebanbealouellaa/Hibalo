import 'package:flutter/material.dart';

import 'v6_colors.dart';

/// The bundled font family (assets/fonts/plus_jakarta_sans, see pubspec.yaml).
const String kV6FontFamily = 'PlusJakartaSans';

/// Figma gives line height in pixels; Flutter wants a multiple of the font size.
TextStyle _style(
  double size,
  FontWeight weight,
  double lineHeightPx, {
  double letterSpacing = 0,
  bool italic = false,
}) {
  return TextStyle(
    fontFamily: kV6FontFamily,
    fontSize: size,
    fontWeight: weight,
    height: lineHeightPx / size,
    letterSpacing: letterSpacing,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    color: V6Colors.textPrimary,
  );
}

/// V6 text styles from Figma; "100%" line height = exactly the font size.
abstract final class V6Text {
  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;
  static const _extraBold = FontWeight.w800;

  // Headlines and titles
  static final headlineXl = _style(32, _extraBold, 40, letterSpacing: -0.3);
  static final headlineLargeTight = _style(28, _extraBold, 34, letterSpacing: -1);
  /// The S01 "Learn" title (Figma uses −0.28 tracking on this instance).
  static final screenTitle = _style(28, _extraBold, 34, letterSpacing: -0.28);
  static final headlineMedium = _style(24, _bold, 32);
  static final headlineMediumExtraBold = _style(24, _extraBold, 32);
  static final headlineMediumExtraBoldItalic = _style(24, _extraBold, 32, italic: true);
  static final appBarTitle = _style(22, _extraBold, 28);
  static final titleLarge = _style(20, _semiBold, 28);
  static final titleLargeBold = _style(20, _bold, 28);
  static final titleLargeExtraBold = _style(20, _extraBold, 28);
  static final titleMedium = _style(16, _semiBold, 24, letterSpacing: 0.1);
  static final titleMediumBold = _style(16, _bold, 24, letterSpacing: 0.1);

  // Body
  static final bodyLarge = _style(16, _regular, 24, letterSpacing: 0.2);
  static final bodyLargeMedium = _style(16, _medium, 24, letterSpacing: 0.2);
  static final bodyLargeSemiBold = _style(16, _semiBold, 24, letterSpacing: 0.2);
  static final bodyLargeSemiBoldItalic =
      _style(16, _semiBold, 24, letterSpacing: 0.2, italic: true);
  static final bodyLargeBold = _style(16, _bold, 24, letterSpacing: 0.2);
  static final bodyMedium = _style(14, _regular, 20, letterSpacing: 0.2);
  static final bodyMediumSemiBold = _style(14, _semiBold, 20, letterSpacing: 0.2);
  static final bodyMediumSemiBoldItalic =
      _style(14, _semiBold, 20, letterSpacing: 0.2, italic: true);
  static final bodyInput = _style(20, _regular, 28);

  // Labels, captions and buttons
  static final button = _style(16, _semiBold, 24, letterSpacing: 0.1);
  static final labelLarge = _style(14, _medium, 20, letterSpacing: 0.1);
  static final labelLargeSemiBold = _style(14, _semiBold, 20, letterSpacing: 0.1);
  static final labelLargeBold = _style(14, _bold, 20, letterSpacing: 0.1);
  static final labelMedium = _style(12, _medium, 16, letterSpacing: 0.4);
  static final labelMediumBold = _style(12, _bold, 16, letterSpacing: 0.4);
  static final labelSmall = _style(10, _medium, 14.3);
  static final caption = _style(12, _regular, 16, letterSpacing: 0.3);
  static final captionSemiBold = _style(12, _semiBold, 16, letterSpacing: 0.3);
  static final overline = _style(12, _extraBold, 16, letterSpacing: 8);

  // Special labels ("100%" line height)
  static final labelXp = _style(12, _bold, 12);
  static final labelLessonNumber = _style(15, _extraBold, 15);
  static final labelLetter = _style(14, _extraBold, 14);
  static final labelLanguage = _style(16, _bold, 16);
  static final displayLetterCard = _style(34, _extraBold, 40, letterSpacing: -0.3);

  // Hiligaynon words
  static final hilWordBold = _style(18, _bold, 26);
  static final hilWordBoldItalic = _style(18, _bold, 26, italic: true);
  static final hilWordExtraBold = _style(18, _extraBold, 26);
  static final hilResultExtraBold = _style(22, _extraBold, 30);
  static final hilResultExtraBoldItalic = _style(22, _extraBold, 30, italic: true);
}
