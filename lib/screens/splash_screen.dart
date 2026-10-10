import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Opening screen for Hibalo.
///
/// The whole sequence runs about 2.8 seconds: the firefly flies in, the
/// wordmark and a rotating Hiligaynon greeting fade in, a progress bar fills,
/// then everything lifts away and [onFinish] is called.
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Entrance, staggered across the elements.
  late final AnimationController _intro;

  // Slow, continuous motion: drifting orbs, wings and the lantern glow.
  late final AnimationController _ambient;

  bool _exit = false;

  static const Duration _hold = Duration(milliseconds: 1700);

  /// Greetings that cycle under the wordmark, each with its Filipino echo.
  static const List<List<String>> _words = [
    ['Maayong aga', 'Magandang umaga'],
    ['Kamusta ka?', 'Kumusta ka?'],
    ['Salamat gid', 'Salamat talaga'],
    ['Maayong gab-i', 'Magandang gabi'],
  ];
  int _word = 0;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    _intro.forward();

    // Flip the greeting partway through the hold.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _word = 1);

    await Future.delayed(_hold - const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _exit = true);

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    widget.onFinish();
  }

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  /// Fade-and-rise for one element, on its own slice of the intro.
  Widget _enter({
    required double begin,
    required Widget child,
    double rise = 18,
  }) {
    final a = CurvedAnimation(
      parent: _intro,
      curve: Interval(
        begin,
        (begin + 0.45).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(
          offset: Offset(0, (1 - a.value) * rise),
          child: c,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final word = _words[_word % _words.length];

    return Scaffold(
      backgroundColor: purpleDark,
      body: AnimatedOpacity(
        opacity: _exit ? 0 : 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeIn,
        child: AnimatedScale(
          scale: _exit ? 1.06 : 1,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeIn,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [purpleDark, purple, purpleMid],
              ),
            ),
            child: Stack(
              children: [
                // Drifting background orbs.
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _ambient,
                      builder: (_, _) => CustomPaint(
                        painter: _OrbPainter(reduce ? 0 : _ambient.value),
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ── Logo: the firefly flies in ──
                              AnimatedBuilder(
                                animation: Listenable.merge([_intro, _ambient]),
                                builder: (_, _) => SizedBox(
                                  width: 160,
                                  height: 160,
                                  child: CustomPaint(
                                    painter: _FireflyPainter(
                                      t: reduce ? 0.15 : _ambient.value,
                                      entrance: CurvedAnimation(
                                        parent: _intro,
                                        curve: const Interval(
                                          0,
                                          0.6,
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ).value,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 28),

                              // ── Wordmark ──
                              _enter(
                                begin: 0.3,
                                child: const Text(
                                  'Hibalo',
                                  style: TextStyle(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                    height: 1,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              _enter(
                                begin: 0.4,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _dot(),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Hiligaynon · Filipino',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: purpleLight,
                                        letterSpacing: 1.6,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    _dot(),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),

                              // ── Rotating greeting ──
                              _enter(
                                begin: 0.5,
                                child: SizedBox(
                                  height: 52,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 450),
                                    transitionBuilder: (child, a) =>
                                        FadeTransition(
                                          opacity: a,
                                          child: SlideTransition(
                                            position: Tween(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(a),
                                            child: child,
                                          ),
                                        ),
                                    child: Column(
                                      key: ValueKey(_word),
                                      children: [
                                        Text(
                                          word[0],
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          word[1],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withValues(
                                              alpha: 0.55,
                                            ),
                                            decoration: TextDecoration.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Progress bar ──
                      _enter(
                        begin: 0.55,
                        rise: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 2200),
                            curve: Curves.easeInOut,
                            builder: (_, v, _) => ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: v,
                                minHeight: 5,
                                backgroundColor: Colors.white.withValues(alpha: 0.16),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 26),

                      // ── Footer ──
                      _enter(
                        begin: 0.65,
                        rise: 8,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            '© 2026 Hibalo. All rights reserved.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.white.withValues(alpha: 0.45),
                              letterSpacing: 0.6,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot() => Container(
    width: 4,
    height: 4,
    decoration: const BoxDecoration(color: purpleLight, shape: BoxShape.circle),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// THE HIBALO LOGO — a firefly (alitaptap)
//
// A small light that finds its way in the dark, for an app whose name means
// "to know". The wings flutter, the lantern glows, and a trail of light drifts
// behind it. [t] loops 0..1 with the ambient controller; [entrance] runs 0..1
// once, and the firefly flies in from the lower left as it rises.
// ═════════════════════════════════════════════════════════════════════════════
class _FireflyPainter extends CustomPainter {
  /// 0..1, loops.
  final double t;

  /// 0..1 entrance progress.
  final double entrance;

  /// Wing beats per loop of [t]. A whole number keeps the loop seamless.
  final int flaps;

  /// Lantern glows per loop of [t].
  final int glows;

  _FireflyPainter({
    required this.t,
    this.entrance = 1,
  }) : flaps = 36, glows = 24;

  static const Color _gold = Color(0xFFFFD45C);
  static const Color _goldDeep = Color(0xFFFFB627);
  static const Color _ink = Color(0xFF3B2470);

  double _wave(double cycles, [double phase = 0]) =>
      math.sin((t * cycles + phase) * 2 * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final e = entrance.clamp(0.0, 1.0);
    if (e <= 0) return;

    final s = math.min(size.width, size.height) / 120;
    canvas.save();
    canvas.translate((size.width - 120 * s) / 2, (size.height - 120 * s) / 2);
    canvas.scale(s);

    final pulse = (_wave(glows.toDouble()) + 1) / 2; // lantern glow, 0..1
    final bob = _wave(glows.toDouble(), 0.25) * 2.2; // gentle hover

    // Halo behind everything.
    canvas.drawCircle(
      const Offset(60, 60),
      54 + pulse * 3,
      Paint()..color = Colors.white.withValues(alpha: (0.06 + pulse * 0.04) * e),
    );
    canvas.drawCircle(
      const Offset(60, 60),
      44,
      Paint()..color = Colors.white.withValues(alpha: 0.10 * e),
    );

    // Fly in from the lower left.
    canvas.translate((1 - e) * -30, (1 - e) * 30 + bob);

    _trail(canvas, e);

    // Tilt so it reads as flying up and to the right.
    canvas.save();
    canvas.translate(62, 58);
    canvas.rotate(0.42);
    canvas.translate(-60, -60);

    _glow(canvas, pulse, e);
    _wings(canvas, e);
    _body(canvas, pulse, e);

    canvas.restore();
    canvas.restore();
  }

  // Trail of light dots drifting behind the firefly.
  void _trail(Canvas canvas, double e) {
    for (int i = 0; i < 6; i++) {
      final p = ((t * glows + i / 6) % 1);
      final x = 44 - p * 30 - i * 1.5;
      final y = 84 + p * 22 + math.sin(p * math.pi) * -6;
      final r = 3.2 * (1 - p) + 0.6;
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = _gold.withValues(alpha: (1 - p) * 0.75 * e),
      );
    }
  }

  // Soft glow around the lantern.
  void _glow(Canvas canvas, double pulse, double e) {
    const c = Offset(60, 80);
    final r = 30 + pulse * 6;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _gold.withValues(alpha: (0.55 + pulse * 0.25) * e),
            _gold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  // Two pairs of fluttering wings.
  void _wings(Canvas canvas, double e) {
    final flap = _wave(flaps.toDouble()) * 0.32;

    for (final side in [-1.0, 1.0]) {
      for (final layer in [0, 1]) {
        canvas.save();
        canvas.translate(60 + side * 4, 52);
        canvas.rotate(side * (0.75 + (layer == 0 ? 0.35 : 0) + flap));
        final w = layer == 0 ? 15.0 : 18.0;
        final h = layer == 0 ? 30.0 : 38.0;
        final rect = Rect.fromCenter(
          center: Offset(0, -h / 2 + 2),
          width: w,
          height: h,
        );
        canvas.drawOval(
          rect,
          Paint()
            ..color = Colors.white.withValues(alpha: (layer == 0 ? 0.35 : 0.72) * e),
        );
        canvas.drawOval(
          rect,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.9 * e)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        canvas.drawLine(
          Offset.zero,
          Offset(0, -h + 8),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.6 * e)
            ..strokeWidth = 1,
        );
        canvas.restore();
      }
    }
  }

  // Head, thorax and the glowing lantern.
  void _body(Canvas canvas, double pulse, double e) {
    final lantern = Rect.fromCenter(
      center: const Offset(60, 78),
      width: 22,
      height: 30,
    );
    canvas.drawOval(
      lantern,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(_goldDeep, _gold, 0.3)!.withValues(alpha: e),
            Color.lerp(_gold, Colors.white, pulse * 0.45)!.withValues(alpha: e),
          ],
        ).createShader(lantern),
    );

    final seg = Paint()
      ..color = _goldDeep.withValues(alpha: 0.7 * e)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(60, 70), width: 18, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(60, 77), width: 20, height: 8),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );

    final body = Paint()..color = Colors.white.withValues(alpha: e);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(60, 55), width: 20, height: 18),
      body,
    );
    canvas.drawCircle(const Offset(60, 41), 8.5, body);

    final eye = Paint()..color = _ink.withValues(alpha: e);
    canvas.drawCircle(const Offset(56.5, 40), 2.1, eye);
    canvas.drawCircle(const Offset(63.5, 40), 2.1, eye);

    // Antennae with glowing tips.
    final ant = Paint()
      ..color = Colors.white.withValues(alpha: e)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final sway = _wave(glows.toDouble(), 0.1) * 1.5;
    canvas.drawPath(
      Path()
        ..moveTo(57, 34)
        ..quadraticBezierTo(52, 24, 45 + sway, 19),
      ant,
    );
    canvas.drawPath(
      Path()
        ..moveTo(63, 34)
        ..quadraticBezierTo(68, 24, 75 + sway, 19),
      ant,
    );
    final tip = Paint()..color = _gold.withValues(alpha: e);
    canvas.drawCircle(Offset(45 + sway, 19), 2.6, tip);
    canvas.drawCircle(Offset(75 + sway, 19), 2.6, tip);
  }

  @override
  bool shouldRepaint(_FireflyPainter old) =>
      old.t != t || old.entrance != entrance;
}

// ═════════════════════════════════════════════════════════════════════════════
// BACKGROUND ORBS
// ═════════════════════════════════════════════════════════════════════════════
class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  // x, y, radius, speed, phase — all as fractions of the screen.
  static const List<List<double>> _orbs = [
    [0.12, 0.18, 0.34, 1.0, 0.0],
    [0.88, 0.26, 0.26, 0.7, 0.3],
    [0.78, 0.84, 0.40, 0.5, 0.6],
    [0.18, 0.76, 0.22, 0.9, 0.8],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _orbs.length; i++) {
      final o = _orbs[i];
      final drift = math.sin((t * o[3] + o[4]) * 2 * math.pi);
      final center = Offset(
        o[0] * size.width + drift * 18,
        o[1] * size.height - drift * 22,
      );
      final r = o[2] * size.width;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: i.isEven ? 0.07 : 0.05),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}
