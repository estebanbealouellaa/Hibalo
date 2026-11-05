import 'package:flutter/material.dart';

import '../../learning/theme/v6_colors.dart';
import 'v6_styles.dart';

/// Brand pieces shared by Splash, Welcome, Onboarding and the account
/// screens.

/// "HIBALO" (V6/Wordmark/Small) in [color].
class V6Wordmark extends StatelessWidget {
  const V6Wordmark({super.key, this.color = V6Colors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Text('HIBALO', style: V6AppText.wordmarkSmall.copyWith(color: color));
}

/// "Logo mark" (64 × 64): the firefly over a 44 × 40 citrus orb.
class V6LogoMark extends StatelessWidget {
  const V6LogoMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    final k = size / 64;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              left: 16 * k,
              top: 24 * k,
              width: 44 * k,
              height: 40 * k,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: V6Colors.citrus, shape: BoxShape.circle),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/images/mascots/firefly_base.webp',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A decorative circle placed in a 375-wide design frame; [scale] maps the
/// Figma coordinates onto the real screen width.
class V6Orb extends StatelessWidget {
  const V6Orb({
    super.key,
    required this.left,
    required this.top,
    required this.diameter,
    required this.color,
    required this.scale,
  });

  final double left;
  final double top;
  final double diameter;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * scale,
      top: top * scale,
      width: diameter * scale,
      height: diameter * scale,
      child: DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    );
  }
}

/// The soft violet orb on purple panels (Welcome, Splash).
const Color kV6SoftOrb = Color(0x66FFFFFF);

/// The halo orbs on Onboarding (a lighter ring behind citrus and glow).
const Color kV6HaloOrb = Color(0x33FFFFFF);
