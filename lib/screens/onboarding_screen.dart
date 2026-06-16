import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      emoji: '🕊️',
      title: 'Welcome to Hibalo!',
      subtitle: 'Translate between Hiligaynon and Filipino with ease',
    ),
    _OnboardingPage(
      emoji: '🎤',
      title: 'Speak & Translate',
      subtitle: 'Hold the mic button and speak in Hiligaynon or Filipino',
    ),
    _OnboardingPage(
      emoji: '✨',
      title: 'Ready to Translate',
      subtitle: "Let's start translating! Tap next to begin",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // ── FIX: Scaffold resets the default text style, removing the yellow underline
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [purpleDark, purple, purpleMid],
          ),
        ),
        child: Stack(
          children: [
            // Animated page content
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(
                key: ValueKey(_currentPage),
                child: _buildPage(_pages[_currentPage]),
              ),
            ),
            // Bottom navigation row
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Back button
                    if (_currentPage > 0)
                      _NavCircleButton(
                        onTap: () => setState(() => _currentPage--),
                        child: const Text(
                          '←',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                        color: purple,
                      )
                    else
                      const SizedBox(width: 48, height: 48),
                    // Dots
                    Row(
                      children: List.generate(3, (i) {
                        final active = i == _currentPage;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 10 : 6,
                          height: active ? 10 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? purpleLight : purple,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                    // Next / Finish
                    _NavCircleButton(
                      onTap: () {
                        if (_currentPage < 2) {
                          setState(() => _currentPage++);
                        } else {
                          widget.onFinish();
                        }
                      },
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 22,
                      ),
                      color: purpleLight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(page.emoji, style: const TextStyle(fontSize: 56)),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              page.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                decoration:
                    TextDecoration.none, // ── FIX: explicitly no underline
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              page.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: purpleLight,
                decoration:
                    TextDecoration.none, // ── FIX: explicitly no underline
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Simple data class ──────────────────────────────────────────────────────
class _OnboardingPage {
  final String emoji;
  final String title;
  final String subtitle;
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });
}

// ── Circle icon button ─────────────────────────────────────────────────────
class _NavCircleButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final Color color;

  const _NavCircleButton({
    required this.onTap,
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}
