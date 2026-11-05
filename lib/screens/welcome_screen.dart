import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/v6/v6.dart';

/// Welcome (Figma 468:1880): the violet hero with the flag firefly, then
/// "Start with a hello." with Get started (→ Sign Up) and "I already have
/// an account" (→ Sign In).
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onGetStarted, required this.onSignIn});

  final VoidCallback onGetStarted;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: V6Colors.background,
        body: LayoutBuilder(
          builder: (context, box) {
            // Figma's 375 × 812 frame: x follows the width, y the smaller
            // of the two scales, so short phones still fit.
            final sx = box.maxWidth / 375;
            final sy = (box.maxHeight / 812).clamp(0.0, sx);
            final heroHeight = 504 * sy;
            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  height: heroHeight,
                  child: const ColoredBox(color: V6Colors.primary),
                ),
                _orb(198, 73, 240, kV6SoftOrb, sx, sy),
                _orb(254, 102, 165, V6Colors.citrus, sx, sy),
                _orb(194, 354, 117, V6Colors.citrus, sx, sy),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 484 * sy,
                  bottom: 0,
                  child: const ColoredBox(color: V6Colors.background),
                ),
                _orb(261, 413, 151, V6Colors.glow, sx, sy),
                Positioned(
                  left: 87 * sx,
                  top: 252 * sy,
                  width: 221.5 * sy,
                  height: 250.8 * sy,
                  child: Image.asset(
                    'assets/images/mascots/firefly_flag.webp',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                Positioned(
                  left: 24,
                  right: 24,
                  top: 48 * sy,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const V6Wordmark(color: V6Colors.onPrimary),
                      SizedBox(height: 26 * sy),
                      const V6Chip(label: 'HILIGAYNON'),
                      SizedBox(height: 12 * sy),
                      SizedBox(
                        width: 300,
                        child: Text(
                          'Words make\nroom for us.',
                          style: V6Text.headlineXl.copyWith(color: V6Colors.onPrimary),
                        ),
                      ),
                      SizedBox(height: 12 * sy),
                      SizedBox(
                        width: 170,
                        child: Text(
                          'Learn everyday Hiligaynon, one small conversation at a time.',
                          style: V6Text.bodyMedium.copyWith(color: V6Colors.onPrimaryMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  top: 516 * sy,
                  bottom: 0,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('Start with a hello.', style: V6Text.headlineMedium),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            'Translate, listen and learn at your pace.',
                            style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted),
                          ),
                        ),
                        SizedBox(height: 32 * sy),
                        V6Button(label: 'Get started', expand: true, onPressed: onGetStarted),
                        SizedBox(height: 12 * sy),
                        Center(child: V6TextLink(label: 'I already have an account', onTap: onSignIn)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static Widget _orb(double left, double top, double d, Color color, double sx, double sy) => Positioned(
        left: left * sx,
        top: top * sy,
        width: d * sy,
        height: d * sy,
        child: DecoratedBox(decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}
