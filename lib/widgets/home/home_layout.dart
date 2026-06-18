import 'package:flutter/material.dart';

/// Responsive spacing derived from the 375×812 Figma frame.
class HomeLayout {
  HomeLayout._(this.width);

  factory HomeLayout.of(BuildContext context) =>
      HomeLayout._(MediaQuery.sizeOf(context).width);

  final double width;

  double get horizontalPadding => width * 22 / 375;
  double get heroHeight => width * 221 / 375;
  double get sheetOverlap => width * 30 / 375;
  double get sheetTopRadius => width * 26 / 375;
  double get gridGap => width * 11 / 375;
  double get cardAspectRatio => 164.5 / 150;
  double get bottomNavClearance => 88;
}
