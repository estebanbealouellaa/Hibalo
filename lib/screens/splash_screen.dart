import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/v6/v6.dart';

/// Splash (Figma 659:7167): a violet screen with the orbs, the firefly,
/// "Hibalo", the tagline, a citrus spinner and the footer. It shows for
/// about 1.7 s while the app starts, then calls [onFinish] (the app root
/// decides: onboarding the first time, Welcome, or Home if signed in).
class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  /// How long the splash stays (Figma: about 1.5 s while the app loads;
  /// the old splash took about 3.3 s).
  static const Duration _hold = Duration(milliseconds: 1700);

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_hold, () {
      if (mounted) widget.onFinish();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: V6Colors.primary,
        body: LayoutBuilder(
          builder: (context, box) {
            // Figma's 375 × 812 frame, scaled to the phone's width; the
            // spinner and footer keep their distance from the bottom.
            final s = box.maxWidth / 375;
            final bottom = MediaQuery.paddingOf(context).bottom;
            return Stack(
              children: [
                V6Orb(left: 57.5, top: 190, diameter: 260, color: kV6SoftOrb, scale: s),
                V6Orb(left: 190, top: 170, diameter: 150, color: V6Colors.citrus, scale: s),
                V6Orb(left: 36, top: 360, diameter: 90, color: V6Colors.citrus, scale: s),
                V6Orb(left: 236, top: 340, diameter: 120, color: V6Colors.glow, scale: s),
                Positioned(
                  left: 63.5 * s,
                  top: 180 * s,
                  width: 248 * s,
                  height: 277 * s,
                  child: FadeTransition(
                    opacity: reduce ? const AlwaysStoppedAnimation(1) : _intro,
                    child: Image.asset(
                      'assets/images/mascots/firefly_base.webp',
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Positioned(
                  left: 20 * s,
                  right: 20 * s,
                  top: 500 * s,
                  child: Column(
                    children: [
                      Text(
                        'Hibalo',
                        textAlign: TextAlign.center,
                        style: V6AppText.displayWordmark.copyWith(color: V6Colors.onPrimary),
                      ),
                      SizedBox(height: 16 * s),
                      Text(
                        'Hiligaynon · Filipino',
                        textAlign: TextAlign.center,
                        style: V6Text.bodyLargeMedium.copyWith(color: V6Colors.onPrimaryMuted),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottom + 70 * s,
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: V6Colors.citrus,
                        backgroundColor: V6Colors.onPrimary.withValues(alpha: 0.3),
                        semanticsLabel: 'Loading',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: bottom + 24 * s,
                  child: Text(
                    '© 2026 Hibalo · PUP Sto. Tomas',
                    textAlign: TextAlign.center,
                    style: V6Text.caption.copyWith(color: V6Colors.onPrimaryMuted),
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
