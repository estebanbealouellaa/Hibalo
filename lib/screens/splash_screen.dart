import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({super.key, required this.onFinish});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Mirrors the 3-phase logic: "enter" → "loaded" → "exit"
  bool _loaded = false;
  bool _exit = false;

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loaded = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _exit = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _exit ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 400),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [purple900, purple800, Color(0xFF0f051d)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mascot — bounces in (scale 0.6 → 1.0)
              AnimatedScale(
                scale: _loaded ? 1.0 : 0.6,
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    color: purple800,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🕊️', style: TextStyle(fontSize: 64)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Title fades in
              AnimatedOpacity(
                opacity: _loaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'Hibalo',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: purple200,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _loaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: const Text(
                  'HILIGAYNON · FILIPINO',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: purple400,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Page dot indicators
              AnimatedOpacity(
                opacity: _loaded ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i == 0;
                    return Container(
                      width: active ? 10 : 6,
                      height: active ? 10 : 6,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: active ? purple400 : purple600,
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
