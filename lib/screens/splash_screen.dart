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
    return Scaffold(
      backgroundColor: purple900,
      body: AnimatedOpacity(
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
          child: SafeArea(
            child: Column(
              children: [
                // Main Content
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Mascot
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
                              child: Text(
                                '🕊️',
                                style: TextStyle(fontSize: 64),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Title
                        AnimatedOpacity(
                          opacity: _loaded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: const Text(
                            'Hibalo',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: purple200,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
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
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Moving Loading Indicator
                        AnimatedOpacity(
                          opacity: _loaded ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 500),
                          child: const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                purple400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: AnimatedOpacity(
                    opacity: _loaded ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: const Text(
                      '© 2026 Hibalo. All Rights Reserved.',
                      style: TextStyle(
                        fontSize: 12,
                        color: purple600,
                        letterSpacing: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
