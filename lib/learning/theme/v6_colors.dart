import 'package:flutter/material.dart';

/// V6 colours, copied from the Figma variables (file SpdWN5Jha…, page
/// "Version 6", collection "V6/Color"). The names follow the Figma names,
/// so "V6/Color/Accent/Lagoon Text" is [V6Colors.lagoonText].
///
/// Used by the learning screens only. The rest of the app keeps
/// lib/theme/app_colors.dart until it moves to V6.
abstract final class V6Colors {
  // Primary (violet)
  static const primary = Color(0xFF6837CD); // V6/Color/Primary
  static const primaryStrong = Color(0xFF321B58); // V6/Color/Primary Strong
  static const primaryContainer = Color(0xFFECE3FC); // V6/Color/Primary Container
  static const onPrimary = Color(0xFFFFFFFF); // V6/Color/On Primary
  static const onPrimaryContainer = Color(0xFF321B58); // V6/Color/On Primary Container
  static const onPrimaryMuted = Color(0xFFECE3FC); // V6/Color/On Primary Muted
  static const link = Color(0xFF6837CD); // V6/Color/Link

  // Backgrounds and surfaces
  static const background = Color(0xFFFFF9F1); // V6/Color/Background (cream)
  static const surface = Color(0xFFFFFFFF); // V6/Color/Surface
  static const surfaceTint = Color(0xFFF4EEFD); // V6/Color/Surface Tint
  static const neutralBackground = Color(0xFFF4F3F7); // V6/Color/Neutral Background

  // Text
  static const textPrimary = Color(0xFF261445); // V6/Color/Text/Primary
  static const textSecondary = Color(0xFF45306E); // V6/Color/Text/Secondary
  static const textMuted = Color(0xFF66558A); // V6/Color/Text/Muted
  static const textNeutral = Color(0xFF5F5C68); // V6/Color/Text/Neutral
  static const textNeutralStrong = Color(0xFF45434D); // V6/Color/Text/Neutral Strong
  static const textDisabled = Color(0xFFA99EC2); // V6/Color/Text/Disabled

  // Borders
  static const borderDivider = Color(0xFFE9E1F2); // V6/Color/Border/Divider
  static const borderInput = Color(0xFF9384B5); // V6/Color/Border/Input
  static const borderNeutral = Color(0xFF8E8B98); // V6/Color/Border/Neutral
  static const borderFocus = Color(0xFF6837CD); // V6/Color/Border/Focus

  // States
  static const stateDisabled = Color(0xFFE9E1F2); // V6/Color/State/Disabled
  static const navInactiveIcon = Color(0xFF9384B5); // V6/Color/Nav/Inactive Icon

  // Feedback
  static const success = Color(0xFF1B6E3F); // V6/Color/Success
  static const successContainer = Color(0xFFE6F4EC); // V6/Color/Success Container
  static const error = Color(0xFFB3261E); // V6/Color/Error
  static const errorContainer = Color(0xFFFCEBEA); // V6/Color/Error Container
  static const warning = Color(0xFF8A5300); // V6/Color/Warning
  static const warningContainer = Color(0xFFFFF4DB); // V6/Color/Warning Container

  // Accent: citrus (the lime "Accent")
  static const citrus = Color(0xFFDDF36B); // V6/Color/Accent
  static const onCitrus = Color(0xFF321B58); // V6/Color/On Accent
  static const citrusText = Color(0xFF556400); // V6/Color/Accent/Text
  static const citrusContainer = Color(0xFFF3FBCB); // V6/Color/Accent/Container

  // Accent: lagoon (teal)
  static const lagoon = Color(0xFF49BDA9); // V6/Color/Accent/Lagoon
  static const lagoonText = Color(0xFF1D6E60); // V6/Color/Accent/Lagoon Text
  static const lagoonContainer = Color(0xFFDDF3EF); // V6/Color/Accent/Lagoon Container

  // Accent: coral
  static const coral = Color(0xFFFF7864); // V6/Color/Accent/Coral
  static const coralText = Color(0xFFA63A28); // V6/Color/Accent/Coral Text
  static const coralContainer = Color(0xFFFFE8E3); // V6/Color/Accent/Coral Container
  static const coralTonal = Color(0xFFFFD3CA); // V6/Color/Accent/Coral Tonal
  static const tilePink = Color(0xFFFF7864); // V6/Color/Tile/Pink

  // Accent: glow (gold)
  static const glow = Color(0xFFF5C45B); // V6/Color/Accent/Glow
  static const glowText = Color(0xFF7A5200); // V6/Color/Accent/Glow Text
  static const glowTonal = Color(0xFFFCE7B8); // V6/Color/Accent/Glow Tonal
  static const glowContainerSoft = Color(0xFFFFF8EA); // V6/Color/Accent/Glow Container Soft

  // Primitives used directly in a few illustrations
  static const ink900 = Color(0xFF261445); // V6/Primitive/Ink/900
  static const ink700 = Color(0xFF45306E); // V6/Primitive/Ink/700
  static const neutral400 = Color(0xFF8E8B98); // V6/Primitive/Neutral/400
  static const skin400 = Color(0xFFD49A6A); // V6/Primitive/Skin/400
  static const skin600 = Color(0xFFB7794B); // V6/Primitive/Skin/600
}

/// V6 spacing and corner radius values (V6/Spacing/*, V6/Radius/*).
abstract final class V6Spacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;

  static const double radiusMedium = 12; // V6/Radius/Medium
  static const double radiusFull = 999; // V6/Radius/Full
}
