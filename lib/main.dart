import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

import 'providers/translator_provider.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INITIALIZE FIREBASE ─────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslatorProvider(),
      child: const HibaloApp(),
    ),
  );
}

class HibaloApp extends StatelessWidget {
  const HibaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hibalo',
      debugShowCheckedModeBanner: false,

      // ── APP THEME ───────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: purple600,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: purple600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: purple600, width: 2),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: purple600,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),

      home: const AppRoot(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// APP ROOT
//
// Launch flow for NEW users:       Splash → Onboarding → Auth → Home
// Launch flow for RETURNING users: Splash → Home  (already logged in)
//                                  Splash → Auth  (logged out, seen onboarding)
// ─────────────────────────────────────────────────────────────────────────────
enum _Phase { splash, onboarding, auth, home }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  _Phase _phase = _Phase.splash;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _buildPhase(),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      // ── 1. SPLASH ──────────────────────────────────────────────────
      case _Phase.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinish: _onSplashFinished,
        );

      // ── 2. ONBOARDING (new users only) ─────────────────────────────
      case _Phase.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onFinish: _onOnboardingFinished,
        );

      // ── 3. AUTH ────────────────────────────────────────────────────
      case _Phase.auth:
        return AuthScreen(
          key: const ValueKey('auth'),
          onAuthSuccess: () => setState(() => _phase = _Phase.home),
        );

      // ── 4. HOME ────────────────────────────────────────────────────
      case _Phase.home:
        return HomeScreen(
          key: const ValueKey('home'),
          onLogout: _onLogout, // ── FIX: pass logout callback
        );
    }
  }

  // ── SPLASH FINISHED ─────────────────────────────────────────────
  Future<void> _onSplashFinished() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() => _phase = _Phase.home);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _phase = hasSeenOnboarding ? _Phase.auth : _Phase.onboarding;
    });
  }

  // ── ONBOARDING FINISHED ─────────────────────────────────────────
  Future<void> _onOnboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    setState(() => _phase = _Phase.auth);
  }

  // ── LOGOUT ──────────────────────────────────────────────────────
  void _onLogout() {
    setState(() => _phase = _Phase.auth);
  }
}
