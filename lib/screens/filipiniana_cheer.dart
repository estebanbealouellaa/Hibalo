import 'dart:math' as math;

import 'package:flutter/material.dart';

// ═════════════════════════════════════════════════════════════════════════════
// FILIPINIANA CHEER
// A woman in a terno (butterfly sleeves) waving and cheering. Everything is
// drawn with a CustomPainter, so there are no image assets to ship and it
// stays sharp at any size.
//
//   const FilipinianaCheer(size: 220)
//
// ═════════════════════════════════════════════════════════════════════════════
class FilipinianaCheer extends StatefulWidget {
  final double size;

  /// Colour of the saya (skirt). The bodice and sleeves follow it.
  final Color gown;

  /// Set false to hold a still pose (useful for screenshots or reduced motion).
  final bool animate;

  const FilipinianaCheer({
    super.key,
    this.size = 220,
    this.gown = const Color(0xFF9B1B5A),
    this.animate = true,
  });

  @override
  State<FilipinianaCheer> createState() => _FilipinianaCheerState();
}

class _FilipinianaCheerState extends State<FilipinianaCheer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.animate) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant FilipinianaCheer old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.animate && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the system "reduce motion" setting.
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.18,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          painter: _FilipinianaPainter(
            t: reduce ? 0.12 : _c.value,
            gown: widget.gown,
          ),
        ),
      ),
    );
  }
}

class _FilipinianaPainter extends CustomPainter {
  final double t; // 0..1, loops
  final Color gown;
  _FilipinianaPainter({required this.t, required this.gown});

  // Design space: 220 x 260. Everything below is written in those units and
  // scaled to whatever size the widget was given.
  static const double _w = 220;
  static const double _h = 260;

  static const Color _skin = Color(0xFFE8B07C);
  static const Color _skinShade = Color(0xFFD29A66);
  static const Color _hair = Color(0xFF241A2E);
  static const Color _gold = Color(0xFFF2C14E);

  double _wave(double cycles, [double phase = 0]) =>
      math.sin((t * cycles + phase) * 2 * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / _w, size.height / _h);
    canvas.save();
    canvas.translate((size.width - _w * s) / 2, (size.height - _h * s) / 2);
    canvas.scale(s);

    final bob = _wave(2) * 3.5; // body bounce
    final sway = _wave(2, 0.25) * 0.045; // skirt sway, in radians
    final armL = _wave(3) * 0.30; // left arm swing
    final armR = _wave(3, 0.5) * 0.30; // right arm swing

    _sparkles(canvas);
    _shadow(canvas, bob);

    canvas.save();
    canvas.translate(0, bob);

    _skirt(canvas, sway);
    _arm(canvas, isLeft: true, swing: armL);
    _arm(canvas, isLeft: false, swing: armR);
    _bodice(canvas);
    _sleeve(canvas, isLeft: true, flutter: armL);
    _sleeve(canvas, isLeft: false, flutter: armR);
    _head(canvas);

    canvas.restore();
    canvas.restore();
  }

  // ── Ground shadow ─────────────────────────────────────────────────────────
  void _shadow(Canvas canvas, double bob) {
    final tightness = 1 - (bob / 10);
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(110, 250),
        width: 118 * tightness,
        height: 16 * tightness,
      ),
      Paint()..color = Colors.black.withOpacity(0.12),
    );
  }

  // ── Saya (skirt) ──────────────────────────────────────────────────────────
  void _skirt(Canvas canvas, double sway) {
    canvas.save();
    // Pivot the skirt at the waist so the hem swings.
    canvas.translate(110, 160);
    canvas.rotate(sway);
    canvas.translate(-110, -160);

    final path = Path()
      ..moveTo(90, 158)
      ..lineTo(130, 158)
      ..cubicTo(152, 196, 170, 226, 178, 244)
      ..quadraticBezierTo(110, 258, 42, 244)
      ..cubicTo(50, 226, 68, 196, 90, 158)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lighten(gown, 0.06), gown],
        ).createShader(const Rect.fromLTWH(40, 150, 140, 100)),
    );

    // Fold lines.
    final fold = Paint()
      ..color = Colors.white.withOpacity(0.16)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(104, 170)
        ..quadraticBezierTo(96, 212, 86, 246),
      fold,
    );
    canvas.drawPath(
      Path()
        ..moveTo(124, 172)
        ..quadraticBezierTo(136, 212, 148, 244),
      fold,
    );

    // Embroidered hem.
    canvas.drawPath(
      Path()
        ..moveTo(44, 240)
        ..quadraticBezierTo(110, 254, 176, 240),
      Paint()
        ..color = _gold.withOpacity(0.9)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  // ── Bodice and waist sash ─────────────────────────────────────────────────
  void _bodice(Canvas canvas) {
    final path = Path()
      ..moveTo(84, 112)
      ..quadraticBezierTo(110, 104, 136, 112)
      ..lineTo(131, 162)
      ..quadraticBezierTo(110, 168, 89, 162)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF6E6), Color(0xFFF6E3C4)],
        ).createShader(const Rect.fromLTWH(80, 100, 60, 70)),
    );

    // Sash across the waist.
    canvas.drawPath(
      Path()
        ..moveTo(87, 150)
        ..quadraticBezierTo(110, 157, 133, 150)
        ..lineTo(131, 162)
        ..quadraticBezierTo(110, 168, 89, 162)
        ..close(),
      Paint()..color = _gold,
    );

    // Neckline.
    canvas.drawPath(
      Path()
        ..moveTo(96, 110)
        ..quadraticBezierTo(110, 124, 124, 110),
      Paint()
        ..color = _skinShade.withOpacity(0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Butterfly sleeves (the terno signature) ───────────────────────────────
  void _sleeve(Canvas canvas, {required bool isLeft, required double flutter}) {
    canvas.save();
    final pivot = Offset(isLeft ? 88 : 132, 116);
    canvas.translate(pivot.dx, pivot.dy);
    if (isLeft) canvas.scale(-1, 1); // mirror for the left side
    canvas.rotate(-flutter * 0.5);

    // A wing that rises from the shoulder and points outward.
    final wing = Path()
      ..moveTo(-4, 2)
      ..cubicTo(26, -28, 46, -24, 48, -4)
      ..cubicTo(50, 14, 30, 24, 2, 20)
      ..close();

    canvas.drawPath(
      wing,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBF2), Color(0xFFF0DCB8)],
        ).createShader(const Rect.fromLTWH(-6, -30, 60, 56)),
    );

    // Stiffened fold line that gives the sleeve its shape.
    canvas.drawPath(
      Path()
        ..moveTo(2, 4)
        ..quadraticBezierTo(28, -12, 44, -4),
      Paint()
        ..color = _gold.withOpacity(0.75)
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.restore();
  }

  // ── Raised, waving arms ───────────────────────────────────────────────────
  void _arm(Canvas canvas, {required bool isLeft, required double swing}) {
    canvas.save();
    final shoulder = Offset(isLeft ? 92 : 128, 120);
    canvas.translate(shoulder.dx, shoulder.dy);
    canvas.rotate(isLeft ? swing : -swing);

    final dir = isLeft ? -1.0 : 1.0;
    final elbow = Offset(26 * dir, -32);
    final hand = Offset(40 * dir, -74);

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(elbow.dx, elbow.dy, hand.dx, hand.dy),
      Paint()
        ..color = _skin
        ..strokeWidth = 11
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );

    // Open hand.
    canvas.drawCircle(hand, 9.5, Paint()..color = _skin);
    // Fingers, as three short strokes fanning upward.
    final finger = Paint()
      ..color = _skin
      ..strokeWidth = 4.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = -1; i <= 1; i++) {
      canvas.drawLine(hand, hand + Offset(i * 5.0 + dir * 2, -11), finger);
    }

    // Motion arcs beside the waving hand.
    final motion = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (int i = 1; i <= 2; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: hand, radius: 14.0 + i * 7),
        dir > 0 ? -1.1 : 2.2,
        0.9,
        false,
        motion,
      );
    }
    canvas.restore();
  }

  // ── Head, hair and happy face ─────────────────────────────────────────────
  void _head(Canvas canvas) {
    const center = Offset(110, 80);

    // Neck.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(103, 96, 14, 20),
        const Radius.circular(7),
      ),
      Paint()..color = _skinShade,
    );

    // Face.
    canvas.drawCircle(center, 25, Paint()..color = _skin);

    // Hair: a cap over the top of the head plus a bun.
    final hairPaint = Paint()..color = _hair;
    canvas.drawPath(
      Path()
        ..moveTo(85, 84)
        ..cubicTo(80, 46, 140, 46, 135, 84)
        ..cubicTo(132, 70, 126, 62, 110, 62)
        ..cubicTo(94, 62, 88, 70, 85, 84)
        ..close(),
      hairPaint,
    );
    canvas.drawCircle(const Offset(110, 48), 13, hairPaint);
    // Sampaguita flower tucked into the bun.
    final petal = Paint()..color = Colors.white;
    for (int i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      canvas.drawCircle(
        Offset(127 + math.cos(a) * 5, 52 + math.sin(a) * 5),
        3.4,
        petal,
      );
    }
    canvas.drawCircle(const Offset(127, 52), 2.6, Paint()..color = _gold);

    // Closed, happy eyes.
    final eye = Paint()
      ..color = _hair
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(100, 84), radius: 5),
      math.pi,
      math.pi,
      false,
      eye,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(120, 84), radius: 5),
      math.pi,
      math.pi,
      false,
      eye,
    );

    // Blush.
    final blush = Paint()..color = const Color(0xFFE8738A).withOpacity(0.35);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(94, 92), width: 13, height: 8),
      blush,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(126, 92), width: 13, height: 8),
      blush,
    );

    // Open smile.
    final mouth = Path()
      ..moveTo(102, 94)
      ..quadraticBezierTo(110, 104, 118, 94)
      ..close();
    canvas.drawPath(mouth, Paint()..color = const Color(0xFF7A2E3C));
  }

  // ── Sparkles around the figure ────────────────────────────────────────────
  void _sparkles(Canvas canvas) {
    const spots = [
      Offset(28, 92),
      Offset(192, 104),
      Offset(44, 36),
      Offset(178, 44),
      Offset(14, 158),
      Offset(206, 164),
    ];
    for (int i = 0; i < spots.length; i++) {
      final pulse =
          (math.sin((t * 2 + i / spots.length) * 2 * math.pi) + 1) / 2;
      final r = 3 + pulse * 4;
      final paint = Paint()
        ..color = Colors.white.withOpacity(0.25 + pulse * 0.5);
      final c = spots[i];
      // Four-pointed star.
      final p = Path()
        ..moveTo(c.dx, c.dy - r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
        ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
        ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
        ..close();
      canvas.drawPath(p, paint);
    }
  }

  Color _lighten(Color c, double amount) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(_FilipinianaPainter old) => old.t != t || old.gown != gown;
}

// ═════════════════════════════════════════════════════════════════════════════
// LESSON ARTWORK
// Flat vector motifs for the lesson banners, drawn in white over whatever
// gradient the card uses. One motif per lesson, chosen by lesson number.
// ═════════════════════════════════════════════════════════════════════════════
class LessonArt extends StatelessWidget {
  final int lessonNumber;

  /// Scales the motif down for small badges.
  final double opacity;

  const LessonArt({super.key, required this.lessonNumber, this.opacity = 1});

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _LessonArtPainter(lessonNumber, opacity),
    size: Size.infinite,
  );
}

class _LessonArtPainter extends CustomPainter {
  final int number;
  final double opacity;
  _LessonArtPainter(this.number, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    // Design space is 200 x 140, anchored to the right of the banner.
    final s = size.height / 140;
    canvas.save();
    canvas.translate(size.width - 200 * s, 0);
    canvas.scale(s);

    switch (number % 3) {
      case 1:
        _greetings(canvas);
        break;
      case 2:
        _people(canvas);
        break;
      default:
        _rings(canvas);
    }
    canvas.restore();
  }

  Paint _fill(double o) =>
      Paint()..color = Colors.white.withOpacity(o * opacity);
  Paint _stroke(double o, double w) => Paint()
    ..color = Colors.white.withOpacity(o * opacity)
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  /// Lesson 1: a sunrise with speech bubbles — greetings by time of day.
  void _greetings(Canvas canvas) {
    // Sun disc and rays, low on the right like a rising sun.
    const sun = Offset(142, 104);
    canvas.drawCircle(sun, 30, _fill(0.16));
    canvas.drawCircle(sun, 20, _fill(0.3));
    for (int i = 0; i < 7; i++) {
      final a = math.pi + i * math.pi / 6;
      canvas.drawLine(
        sun + Offset(math.cos(a) * 36, math.sin(a) * 36),
        sun + Offset(math.cos(a) * 46, math.sin(a) * 46),
        _stroke(0.3, 4),
      );
    }

    // Big speech bubble with three dots.
    final bubble = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 26, 96, 54),
      const Radius.circular(20),
    );
    canvas.drawRRect(bubble, _fill(0.22));
    canvas.drawPath(
      Path()
        ..moveTo(50, 78)
        ..lineTo(44, 96)
        ..lineTo(68, 78)
        ..close(),
      _fill(0.22),
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(56.0 + i * 18, 53), 5.5, _fill(0.55));
    }

    // Small reply bubble.
    final small = RRect.fromRectAndRadius(
      const Rect.fromLTWH(112, 14, 52, 32),
      const Radius.circular(14),
    );
    canvas.drawRRect(small, _fill(0.3));
  }

  /// Lesson 2: two figures in conversation — pronouns and identity.
  void _people(Canvas canvas) {
    // Back figure.
    canvas.drawCircle(const Offset(68, 54), 20, _fill(0.2));
    canvas.drawPath(
      Path()
        ..moveTo(36, 124)
        ..quadraticBezierTo(68, 78, 100, 124)
        ..close(),
      _fill(0.2),
    );

    // Front figure, overlapping.
    canvas.drawCircle(const Offset(124, 66), 26, _fill(0.32));
    canvas.drawPath(
      Path()
        ..moveTo(82, 132)
        ..quadraticBezierTo(124, 80, 166, 132)
        ..close(),
      _fill(0.32),
    );

    // The link between them: a small "we" bubble above.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(78, 6, 60, 30),
        const Radius.circular(15),
      ),
      _fill(0.45),
    );
    canvas.drawCircle(const Offset(96, 21), 4.5, _fill(0.9));
    canvas.drawCircle(const Offset(108, 21), 4.5, _fill(0.9));
    canvas.drawCircle(const Offset(120, 21), 4.5, _fill(0.9));
  }

  /// Fallback motif for later lessons.
  void _rings(Canvas canvas) {
    const c = Offset(120, 70);
    for (int i = 3; i >= 1; i--) {
      canvas.drawCircle(c, 20.0 * i, _stroke(0.16, 5));
    }
    canvas.drawCircle(c, 18, _fill(0.3));
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawCircle(
        c + Offset(math.cos(a) * 60, math.sin(a) * 60),
        5,
        _fill(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(_LessonArtPainter old) =>
      old.number != number || old.opacity != opacity;
}
