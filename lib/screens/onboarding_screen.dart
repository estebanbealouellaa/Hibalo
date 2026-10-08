import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// First-run tour. Four swipeable pages, each with a drawn illustration and
/// one Hiligaynon word the learner picks up on the way in.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pages = PageController();
  late final AnimationController _ambient;

  int _page = 0;

  /// Continuous page position, used for the parallax background.
  double _offset = 0;

  static const List<_Slide> _slides = [
    _Slide(
      art: _Art.mark,
      title: 'Welcome to Hibalo',
      body:
          'Translate between Hiligaynon and Filipino, and learn the '
          'language while you do it.',
      word: 'Hibalo',
      gloss: 'to know',
    ),
    _Slide(
      art: _Art.mic,
      title: 'Speak and translate',
      body:
          'Hold the mic and talk in Hiligaynon or Filipino. Type it, say '
          'it, or point your camera at it.',
      word: 'Hambal',
      gloss: 'to speak',
    ),
    _Slide(
      art: _Art.lessons,
      title: 'Learn level by level',
      body:
          'Short lessons with flip cards, chats and quick checks. Finish '
          'Beginner to open Intermediate, then Advanced.',
      word: 'Tuon',
      gloss: 'to study',
    ),
    _Slide(
      art: _Art.streak,
      title: 'Come back tomorrow',
      body:
          'Earn XP for every answer and build a daily streak. A few '
          'minutes a day is all it takes.',
      word: 'Adlaw-adlaw',
      gloss: 'every day',
    ),
  ];

  bool get _isLast => _page == _slides.length - 1;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pages.addListener(() {
      final p = _pages.page ?? 0;
      if ((p - _offset).abs() > 0.004) setState(() => _offset = p);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_isLast) {
      widget.onFinish();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;

    return Scaffold(
      backgroundColor: purpleDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [purpleDark, purple, purpleMid],
          ),
        ),
        child: Stack(
          children: [
            // Background orbs that slide as the pages move.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _ambient,
                  builder: (_, __) => CustomPaint(
                    painter: _OrbPainter(
                      t: reduce ? 0 : _ambient.value,
                      shift: _offset,
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── Skip ──
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedOpacity(
                      opacity: _isLast ? 0 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                        child: TextButton(
                          onPressed: _isLast ? null : widget.onFinish,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Pages ──
                  Expanded(
                    child: PageView.builder(
                      controller: _pages,
                      itemCount: _slides.length,
                      onPageChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() => _page = i);
                      },
                      itemBuilder: (_, i) => _SlideView(
                        slide: _slides[i],
                        index: i,
                        offset: _offset,
                        ambient: _ambient,
                        reduce: reduce,
                      ),
                    ),
                  ),

                  // ── Dots ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < _slides.length; i++)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                          width: i == _page ? 26 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _page
                                ? Colors.white
                                : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── CTA ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                    child: SizedBox(
                      width: double.infinity,
                      child: _PushButton(
                        onTap: _next,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Row(
                            key: ValueKey(_isLast),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_isLast ? 'Magsimula' : 'Dayon'),
                              const SizedBox(width: 8),
                              Icon(
                                _isLast
                                    ? Icons.auto_awesome_rounded
                                    : Icons.arrow_forward_rounded,
                                size: 20,
                                color: purple,
                              ),
                            ],
                          ),
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
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SLIDE
// ═════════════════════════════════════════════════════════════════════════════
enum _Art { mark, mic, lessons, streak }

class _Slide {
  final _Art art;
  final String title;
  final String body;

  /// One Hiligaynon word taught by the slide itself.
  final String word;
  final String gloss;

  const _Slide({
    required this.art,
    required this.title,
    required this.body,
    required this.word,
    required this.gloss,
  });
}

class _SlideView extends StatelessWidget {
  final _Slide slide;
  final int index;
  final double offset;
  final Animation<double> ambient;
  final bool reduce;

  const _SlideView({
    required this.slide,
    required this.index,
    required this.offset,
    required this.ambient,
    required this.reduce,
  });

  @override
  Widget build(BuildContext context) {
    // How far this page is from the centre: 0 when settled, ±1 when adjacent.
    final delta = (index - offset).clamp(-1.0, 1.0);
    final settled = 1 - delta.abs();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration, drifting slightly against the swipe.
          Transform.translate(
            offset: Offset(delta * -46, 0),
            child: Transform.scale(
              scale: 0.86 + settled * 0.14,
              child: SizedBox(
                width: 210,
                height: 210,
                child: AnimatedBuilder(
                  animation: ambient,
                  builder: (_, __) => CustomPaint(
                    painter: _SlideArtPainter(
                      art: slide.art,
                      t: reduce ? 0.2 : ambient.value,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Opacity(
            opacity: settled.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(delta * 28, 0),
              child: Column(
                children: [
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: -0.4,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: Colors.white.withOpacity(0.72),
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // The word this slide quietly teaches.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.22)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slide.word,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: purpleLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          slide.gloss,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ILLUSTRATIONS
// Drawn in a 160 x 160 design space and scaled, so there are no assets to ship.
// ═════════════════════════════════════════════════════════════════════════════
class _SlideArtPainter extends CustomPainter {
  final _Art art;
  final double t; // 0..1, loops
  _SlideArtPainter({required this.art, required this.t});

  double _pulse([double cycles = 1, double phase = 0]) =>
      (math.sin((t * cycles + phase) * 2 * math.pi) + 1) / 2;

  Paint _w(double o) => Paint()..color = Colors.white.withOpacity(o);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 160;
    canvas.save();
    canvas.scale(s);

    // Shared backdrop: a soft disc that breathes.
    const c = Offset(80, 80);
    canvas.drawCircle(c, 68 + _pulse() * 3, _w(0.07));
    canvas.drawCircle(c, 54, _w(0.10));

    switch (art) {
      case _Art.mark:
        _firefly(canvas);
        break;
      case _Art.mic:
        _mic(canvas);
        break;
      case _Art.lessons:
        _lessons(canvas);
        break;
      case _Art.streak:
        _streak(canvas);
        break;
    }
    canvas.restore();
  }

  /// The Hibalo logo: a firefly (alitaptap). Drawn in the shared 160 x 160
  /// space, so it sits with the other illustrations.
  void _firefly(Canvas canvas) {
    const gold = Color(0xFFFFD45C);
    const goldDeep = Color(0xFFFFB627);
    const ink = Color(0xFF3B2470);

    // The onboarding loop is 8 s long, so these counts give roughly two
    // glows and three wing beats per second.
    final pulse = _pulse(16);
    final bob = math.sin(16 * t * 2 * math.pi + 0.5) * 3;

    canvas.save();
    canvas.translate(0, bob);

    // Trail of light drifting behind it.
    for (int i = 0; i < 6; i++) {
      final p = ((t * 16 + i / 6) % 1);
      canvas.drawCircle(
        Offset(60 - p * 40 - i * 2, 112 + p * 28 + math.sin(p * math.pi) * -8),
        4.2 * (1 - p) + 0.8,
        Paint()..color = gold.withOpacity((1 - p) * 0.75),
      );
    }

    // Tilt so it reads as flying up and to the right.
    canvas.translate(82, 78);
    canvas.rotate(0.42);
    canvas.translate(-80, -80);

    // Glow around the lantern.
    const lamp = Offset(80, 106);
    final gr = 40 + pulse * 8;
    canvas.drawCircle(
      lamp,
      gr,
      Paint()
        ..shader = RadialGradient(
          colors: [gold.withOpacity(0.55 + pulse * 0.25), gold.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: lamp, radius: gr)),
    );

    // Wings: two pairs, fluttering.
    final flap = math.sin(24 * t * 2 * math.pi) * 0.32;
    for (final side in [-1.0, 1.0]) {
      for (final layer in [0, 1]) {
        canvas.save();
        canvas.translate(80 + side * 5, 68);
        canvas.rotate(side * (0.75 + (layer == 0 ? 0.35 : 0) + flap));
        final w = layer == 0 ? 20.0 : 24.0;
        final h = layer == 0 ? 40.0 : 50.0;
        final rect = Rect.fromCenter(
          center: Offset(0, -h / 2 + 3),
          width: w,
          height: h,
        );
        canvas.drawOval(rect, _w(layer == 0 ? 0.35 : 0.72));
        canvas.drawOval(
          rect,
          Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8,
        );
        canvas.drawLine(
          Offset.zero,
          Offset(0, -h + 10),
          Paint()
            ..color = Colors.white.withOpacity(0.6)
            ..strokeWidth = 1.2,
        );
        canvas.restore();
      }
    }

    // Lantern (abdomen).
    final lantern = Rect.fromCenter(center: lamp, width: 29, height: 40);
    canvas.drawOval(
      lantern,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(goldDeep, gold, 0.3)!,
            Color.lerp(gold, Colors.white, pulse * 0.45)!,
          ],
        ).createShader(lantern),
    );
    final seg = Paint()
      ..color = goldDeep.withOpacity(0.7)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(80, 95), width: 24, height: 10),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(80, 104), width: 27, height: 10),
      0.2,
      math.pi - 0.4,
      false,
      seg,
    );

    // Thorax and head.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(80, 72), width: 27, height: 24),
      _w(1),
    );
    canvas.drawCircle(const Offset(80, 53), 11.5, _w(1));

    // Eyes.
    final eye = Paint()..color = ink;
    canvas.drawCircle(const Offset(75.5, 52), 2.8, eye);
    canvas.drawCircle(const Offset(84.5, 52), 2.8, eye);

    // Antennae with glowing tips.
    final sway = math.sin(16 * t * 2 * math.pi + 0.2) * 2;
    final ant = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(76, 44)
        ..quadraticBezierTo(69, 31, 59 + sway, 24),
      ant,
    );
    canvas.drawPath(
      Path()
        ..moveTo(84, 44)
        ..quadraticBezierTo(91, 31, 101 + sway, 24),
      ant,
    );
    final tip = Paint()..color = gold;
    canvas.drawCircle(Offset(59 + sway, 24), 3.4, tip);
    canvas.drawCircle(Offset(101 + sway, 24), 3.4, tip);

    canvas.restore();
  }

  /// A microphone with sound waves rippling outward.
  void _mic(Canvas canvas) {
    // Ripples.
    for (int i = 0; i < 3; i++) {
      final p = ((t * 1.2 + i / 3) % 1);
      canvas.drawCircle(
        const Offset(80, 74),
        26 + p * 40,
        Paint()
          ..color = Colors.white.withOpacity((1 - p) * 0.3)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke,
      );
    }

    // Capsule body.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(66, 40, 28, 52),
        const Radius.circular(14),
      ),
      _w(1),
    );
    // Grille lines.
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(72, 54.0 + i * 10),
        Offset(88, 54.0 + i * 10),
        Paint()
          ..color = purple.withOpacity(0.55)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
    }
    // Cradle and stand.
    canvas.drawArc(
      const Rect.fromLTWH(54, 58, 52, 52),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(77, 106, 6, 16),
        const Radius.circular(3),
      ),
      _w(1),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(64, 120, 32, 6),
        const Radius.circular(3),
      ),
      _w(1),
    );
  }

  /// A stack of lesson cards, the top one lifting gently.
  void _lessons(Canvas canvas) {
    final lift = _pulse() * 5;

    // Back cards.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(44, 56, 72, 54),
        const Radius.circular(12),
      ),
      _w(0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 50, 72, 54),
        const Radius.circular(12),
      ),
      _w(0.6),
    );

    // Front card.
    canvas.save();
    canvas.translate(0, -lift);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(52, 44, 72, 54),
        const Radius.circular(12),
      ),
      _w(1),
    );
    // Lines of "text".
    final line = Paint()
      ..color = purple.withOpacity(0.45)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(62, 58), const Offset(104, 58), line);
    canvas.drawLine(const Offset(62, 68), const Offset(94, 68), line);
    // A ticked answer.
    canvas.drawCircle(const Offset(66, 84), 7, Paint()..color = purple);
    canvas.drawPath(
      Path()
        ..moveTo(63, 84)
        ..lineTo(65.5, 87)
        ..lineTo(70, 81),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(const Offset(78, 84), const Offset(108, 84), line);
    canvas.restore();

    // Three level rungs climbing to the right.
    for (int i = 0; i < 3; i++) {
      final on = (t * 1.5).floor() % 3 >= i;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(36.0 + i * 32, 124.0 - i * 8, 24, 8.0 + i * 8),
          const Radius.circular(4),
        ),
        _w(on ? 0.9 : 0.3),
      );
    }
  }

  /// A flame with an XP bolt, for the daily streak.
  void _streak(Canvas canvas) {
    final flicker = _pulse(2);

    // Flame.
    final flame = Path()
      ..moveTo(80, 36)
      ..cubicTo(104, 58, 112, 70, 112, 86)
      ..cubicTo(112, 106, 98, 118, 80, 118)
      ..cubicTo(62, 118, 48, 106, 48, 86)
      ..cubicTo(48, 70, 56, 58, 80, 36)
      ..close();
    canvas.drawPath(flame, _w(0.95));

    // Inner flame, brighter and flickering.
    final inner = Path()
      ..moveTo(80, 64)
      ..cubicTo(94, 78, 98, 86, 98, 94 - flicker * 3)
      ..cubicTo(98, 106, 90, 112, 80, 112)
      ..cubicTo(70, 112, 62, 106, 62, 94 - flicker * 3)
      ..cubicTo(62, 86, 66, 78, 80, 64)
      ..close();
    canvas.drawPath(inner, Paint()..color = purple);

    // XP bolt inside.
    canvas.drawPath(
      Path()
        ..moveTo(84, 78)
        ..lineTo(72, 96)
        ..lineTo(80, 96)
        ..lineTo(76, 110)
        ..lineTo(90, 90)
        ..lineTo(81, 90)
        ..close(),
      _w(1),
    );

    // Day ticks underneath.
    for (int i = 0; i < 5; i++) {
      final on = i <= (t * 5).floor() % 5;
      canvas.drawCircle(
        Offset(52.0 + i * 14, 134),
        on ? 5 : 3.5,
        _w(on ? 0.9 : 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(_SlideArtPainter old) => old.t != t || old.art != art;
}

// ═════════════════════════════════════════════════════════════════════════════
// BACKGROUND
// ═════════════════════════════════════════════════════════════════════════════
class _OrbPainter extends CustomPainter {
  final double t;
  final double shift; // current page position, for parallax
  _OrbPainter({required this.t, required this.shift});

  static const List<List<double>> _orbs = [
    [0.15, 0.20, 0.36, 1.0, 0.0, 60],
    [0.85, 0.30, 0.26, 0.7, 0.3, -90],
    [0.75, 0.82, 0.42, 0.5, 0.6, 120],
    [0.20, 0.72, 0.22, 0.9, 0.8, -50],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _orbs.length; i++) {
      final o = _orbs[i];
      final drift = math.sin((t * o[3] + o[4]) * 2 * math.pi);
      final center = Offset(
        o[0] * size.width + drift * 16 - shift * o[5],
        o[1] * size.height - drift * 18,
      );
      final r = o[2] * size.width;
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withOpacity(i.isEven ? 0.07 : 0.05),
              Colors.white.withOpacity(0),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t || old.shift != shift;
}

// ═════════════════════════════════════════════════════════════════════════════
// CTA BUTTON — presses down like a real key
// ═════════════════════════════════════════════════════════════════════════════
class _PushButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _PushButton({required this.child, required this.onTap});

  @override
  State<_PushButton> createState() => _PushButtonState();
}

class _PushButtonState extends State<_PushButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    const depth = 5.0;
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) {
        _set(false);
        widget.onTap();
      },
      onTapCancel: () => _set(false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _down ? depth : 0,
          bottom: _down ? 0 : depth,
        ),
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              offset: Offset(0, _down ? 0 : depth),
            ),
          ],
        ),
        child: Center(
          child: DefaultTextStyle(
            style: const TextStyle(
              color: purple,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
              decoration: TextDecoration.none,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
