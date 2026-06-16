import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// PROVIDERS
import 'providers/translator_provider.dart';
import 'providers/auth_provider.dart' as app;
import 'models/user_stats.dart';

// SCREENS
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_screen.dart'; // ← ADDED

// THEME
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INITIALIZE FIREBASE ─────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // TRANSLATOR PROVIDER
        ChangeNotifierProvider(create: (_) => TranslatorProvider()),

        // USER STATS PROVIDER
        ChangeNotifierProvider(create: (_) => UserStats()),

        // AUTH PROVIDER
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
      ],

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

      theme: AppTheme.light(),

      home: const AppRoot(),
    );
  }
}

// ─────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────

enum _Phase { splash, onboarding, auth, home, admin } // ← admin ADDED

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
      // ── SPLASH ─────────────────────────────
      case _Phase.splash:
        return SplashScreen(
          key: const ValueKey('splash'),
          onFinish: _onSplashFinished,
        );

      // ── ONBOARDING ────────────────────────
      case _Phase.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onFinish: _onOnboardingFinished,
        );

      // ── AUTH ──────────────────────────────
      case _Phase.auth:
        return AuthScreen(
          key: const ValueKey('auth'),
          onAuthSuccess: _onAuthSuccess, // ← uses helper now
        );

      // ── HOME ──────────────────────────────
      case _Phase.home:
        return HomeScreen(key: const ValueKey('home'), onLogout: _onLogout);

      // ── ADMIN DASHBOARD ───────────────────
      case _Phase.admin:
        return AdminDashboardScreen(
          key: const ValueKey('admin'),
          onLogout: _onLogout, // ← we'll add this param below
        );
    }
  }

  // ── AUTH SUCCESS — check role then route ────────────
  void _onAuthSuccess() {
    final authProvider = context.read<app.AuthProvider>();
    setState(() {
      _phase = authProvider.isAdmin ? _Phase.admin : _Phase.home;
    });
  }

  // ── SPLASH FINISHED ─────────────────────────────────
  Future<void> _onSplashFinished() async {
    final user = FirebaseAuth.instance.currentUser;

    // USER ALREADY LOGGED IN
    if (user != null) {
      final authProvider = context.read<app.AuthProvider>();
      await authProvider.refreshAdminRole(user.uid);
      if (!mounted) return;
      setState(() {
        _phase = authProvider.isAdmin
            ? _Phase.admin
            : _Phase.home; // ← route by role
      });
      return;
    }

    // CHECK ONBOARDING
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _phase = hasSeenOnboarding ? _Phase.auth : _Phase.onboarding;
    });
  }

  // ── ONBOARDING FINISHED ─────────────────────────────
  Future<void> _onOnboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    setState(() {
      _phase = _Phase.auth;
    });
  }

  // ── LOGOUT ──────────────────────────────────────────
  void _onLogout() {
    setState(() {
      _phase = _Phase.auth;
    });
  }
}
