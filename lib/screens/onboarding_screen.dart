import '../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/v6/v6.dart';

/// Onboarding 1–3 (Figma 667:7189 / 667:7250 / 667:7324), shown once.
/// A coloured hero with the firefly and floating preview cards, then the
/// word of the slide, a title and a line. Skip (pages 1–2) and the last
/// page's Get started both call [onFinish], which saves that onboarding
/// was seen.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _Slide {
  const _Slide({
    required this.hero,
    required this.softOrb,
    required this.mascot,
    required this.word,
    required this.title,
    required this.body,
  });

  final Color hero;
  final Color softOrb;
  final String mascot;
  final String word;
  final String title;
  final String body;
}

List<_Slide> _slidesFor(AppLocalizations t) => [
  _Slide(
    hero: V6Colors.primary,
    softOrb: V6Colors.primaryContainer,
    mascot: 'firefly_hello',
    word: 'Hibalo · malaman',
    title: t.onboard1Title,
    body: t.onboard1Body,
  ),
  _Slide(
    hero: V6Colors.lagoon,
    softOrb: V6Colors.lagoonContainer,
    mascot: 'firefly_phone',
    word: 'Hambal · magsalita',
    title: t.onboard2Title,
    body: t.onboard2Body,
  ),
  _Slide(
    hero: V6Colors.coral,
    softOrb: V6Colors.coralContainer,
    mascot: 'firefly_reading',
    word: 'Tuon · mag-aral',
    title: t.onboard3Title,
    body: t.onboard3Body,
  ),
];

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _page = 0;

  bool get _isLast => _page == _slidesFor(AppLocalizations.of(context)).length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _next() {
    if (_isLast) {
      widget.onFinish();
      return;
    }
    _pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: V6Colors.background,
        body: LayoutBuilder(
          builder: (context, box) {
            final sx = box.maxWidth / 375;
            final sy = (box.maxHeight / 812).clamp(0.0, sx);
            final bottom = MediaQuery.paddingOf(context).bottom;
            return Stack(
              children: [
                PageView.builder(
                  controller: _pages,
                  itemCount: _slidesFor(AppLocalizations.of(context)).length,
                  onPageChanged: (p) => setState(() => _page = p),
                  itemBuilder: (_, i) => _SlideView(slide: _slidesFor(AppLocalizations.of(context))[i], index: i, sx: sx, sy: sy),
                ),
                // Skip: pages 1–2, white on the hero (Figma 295, 28).
                if (!_isLast)
                  Positioned(
                    right: 8 * sx,
                    top: 28 * sy,
                    child: TextButton(
                      onPressed: widget.onFinish,
                      style: TextButton.styleFrom(
                        foregroundColor: V6Colors.onPrimary,
                        minimumSize: const Size(72, 48),
                        textStyle: V6Text.labelLargeBold,
                      ),
                      child: Text(t.onboardSkip),
                    ),
                  ),
                // Page dots and Next / Get started (Figma y 684).
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: bottom + 24 * sy,
                  child: Row(
                    children: [
                      _Dots(count: _slidesFor(AppLocalizations.of(context)).length, current: _page),
                      const Spacer(),
                      SizedBox(
                        width: 160,
                        child: V6Button(
                          label: _isLast ? t.welcomeGetStarted : t.onboardNext,
                          expand: true,
                          onPressed: _next,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One page: hero (orbs, firefly, preview cards) and the text below.
class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide, required this.index, required this.sx, required this.sy});

  final _Slide slide;
  final int index;
  final double sx;
  final double sy;

  Widget _orb(double left, double top, double d, Color color) => Positioned(
        left: left * sx,
        top: top * sy,
        width: d * sy,
        height: d * sy,
        child: DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );

  Widget _at(double left, double top, Widget child, {double turns = 0}) => Positioned(
        left: left * sx,
        top: top * sy,
        child: Transform.rotate(angle: turns * 3.14159265 / 180, child: Transform.scale(scale: sy, alignment: Alignment.topLeft, child: child)),
      );

  @override
  Widget build(BuildContext context) {
    final decor = switch (index) {
      0 => [
          _orb(72, 120, 230, slide.softOrb),
          _orb(240, 136, 144, kV6HaloOrb),
          _orb(284, 128, 112, V6Colors.citrus),
          _orb(24, 402, 64, V6Colors.citrus),
          _orb(228, 364, 132, kV6HaloOrb),
          _orb(276, 392, 104, V6Colors.glow),
          _orb(172, 66, 22, V6Colors.coral),
          _orb(34, 232, 16, V6Colors.lagoon),
          _orb(150, 432, 14, V6Colors.glow),
        ],
      1 => [
          _orb(72, 120, 230, slide.softOrb),
          _orb(-49.5, 146.5, 167, kV6HaloOrb),
          _orb(-46, 190, 140, V6Colors.citrus),
          _orb(133.5, 435.5, 81, kV6HaloOrb),
          _orb(166, 410, 56, V6Colors.citrus),
          _orb(268, 408, 120, V6Colors.glow),
          _orb(232, 70, 20, V6Colors.coral),
          _orb(112, 404, 14, V6Colors.primary),
        ],
      _ => [
          _orb(72, 120, 230, slide.softOrb),
          _orb(230.5, -7.5, 155, kV6HaloOrb),
          _orb(286, -22, 124, V6Colors.citrus),
          _orb(38, 252, 60, V6Colors.citrus),
          _orb(-15.5, 366.5, 139, kV6HaloOrb),
          _orb(-30, 402, 116, V6Colors.glow),
          _orb(192, 60, 24, V6Colors.lagoon),
          _orb(24, 206, 16, V6Colors.primary),
          _orb(302, 282, 20, V6Colors.glow),
          _orb(152, 444, 14, V6Colors.citrus),
        ],
    };
    final cards = switch (index) {
      0 => [
          _at(19, 96, const _Bubble(label: 'Hiligaynon', text: 'Kamusta ka?', violet: true), turns: 4),
          _at(222, 302, const _Bubble(label: 'Filipino', text: 'Kumusta ka?'), turns: -4),
        ],
      1 => [
          _at(18, 88, const _TranslateCard(), turns: 3),
          _at(300, 160, const _IconChip(icon: Icons.mic_rounded, filled: true)),
          _at(290, 330, const _IconChip(icon: Icons.photo_camera_rounded)),
          _at(30, 318, const _IconChip(icon: Icons.text_fields_rounded)),
        ],
      _ => [
          _at(22, 100, _Pill(icon: Icons.local_fire_department_rounded, iconColor: V6Colors.coral, text: '3 ${AppLocalizations.of(context).homeDayStreak}'), turns: 4),
          _at(236, 196, const _Pill(icon: Icons.bolt_rounded, iconColor: V6Colors.glowText, text: '120 XP'), turns: -4),
          _at(136, 328, const _LessonCard(), turns: -3),
        ],
    };
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(left: 0, right: 0, top: 0, height: 504 * sy, child: ColoredBox(color: slide.hero)),
        ...decor,
        Positioned(left: 0, right: 0, top: 484 * sy, bottom: 0, child: const ColoredBox(color: V6Colors.background)),
        Positioned(
          left: 77 * sx,
          top: 135 * sy,
          width: 221 * sy,
          height: 250 * sy,
          child: Image.asset(
            'assets/images/mascots/${slide.mascot}.webp',
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        ...cards,
        Positioned(
          left: 24,
          right: 24,
          top: 516 * sy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              V6Chip(label: slide.word),
              const SizedBox(height: 10),
              Text(slide.title, style: V6AppText.headlineLargeExtraBold),
              const SizedBox(height: 10),
              Text(slide.body, style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      label: t.onboardPageOf(current + 1, count),
      child: Row(
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: i == current ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current ? V6Colors.primary : V6Colors.borderInput,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Preview cards (decorative) ─────────────────────────────────────────────

const _cardShadow = [BoxShadow(color: Color(0x2E331A59), blurRadius: 16, offset: Offset(0, 6))];

BoxDecoration _cardDecoration([double radius = 16]) => BoxDecoration(
      color: V6Colors.surface,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: _cardShadow,
    );

class _Bubble extends StatelessWidget {
  const _Bubble({required this.label, required this.text, this.violet = false});

  final String label;
  final String text;
  final bool violet;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
            Text(
              text,
              style: V6Text.titleMediumBold.copyWith(color: violet ? V6Colors.primary : V6Colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslateCard extends StatelessWidget {
  const _TranslateCard();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Magandang umaga', style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 17, color: V6Colors.primary),
                const SizedBox(width: 6),
                Text('Maayong aga', style: V6Text.titleMediumBold.copyWith(color: V6Colors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, this.filled = false});

  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: filled ? V6Colors.primary : V6Colors.surface,
          shape: BoxShape.circle,
          boxShadow: _cardShadow,
        ),
        child: Icon(icon, size: 24, color: filled ? V6Colors.onPrimary : V6Colors.primary),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.iconColor, required this.text});

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _cardDecoration(999),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: iconColor),
            const SizedBox(width: 5),
            Text(text, style: V6Text.labelLargeBold),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
        decoration: _cardDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: V6Colors.citrus, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text('2', style: V6Text.labelLessonNumber.copyWith(color: V6Colors.onCitrus)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Greetings & Courtesy', style: V6Text.labelLargeBold),
                Text(AppLocalizations.of(context).lessonMeta(12, 10), style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
