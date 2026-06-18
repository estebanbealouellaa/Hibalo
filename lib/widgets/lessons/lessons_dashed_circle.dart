import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class DashedCircleBorder extends StatelessWidget {
  final double size;
  final Color borderColor;
  final Color backgroundColor;
  final Widget child;

  const DashedCircleBorder({
    super.key,
    required this.size,
    required this.borderColor,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashedCirclePainter(
          borderColor: borderColor,
          backgroundColor: backgroundColor,
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color borderColor;
  final Color backgroundColor;

  _DashedCirclePainter({
    required this.borderColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()..color = backgroundColor,
    );

    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dashLength = 5.0;
    const gapLength = 4.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + gapLength)) / radius;
      final sweepAngle = dashLength / radius;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
