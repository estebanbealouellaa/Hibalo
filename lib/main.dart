import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

// PROVIDERS
import 'providers/translator_provider.dart';
import 'providers/auth_provider.dart' as app;
import 'learning/state/learning_progress.dart';
import 'learning/sync/firestore_progress_cloud.dart';
import 'l10n/app_language.dart';

// SCREENS
import 'screens/splash_screen.dart';
import 'screens/quick_splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/admin_dashboard_screen.dart'; // ← ADDED

// THEME
import 'theme/v6_app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── INITIALIZE FIREBASE ─────────────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App language for the app's own words (English until the user picks one).
  await AppLanguage.instance.load();

  // First open (fresh install or cleared data) shows the full splash and
  // onboarding; every later launch shows the short plain splash.
  final prefs = await SharedPreferences.getInstance();
  final firstOpen = !(prefs.getBool(kHasSeenOnboarding) ?? false);

  runApp(
    MultiProvider(
      providers: [
        // TRANSLATOR PROVIDER
        ChangeNotifierProvider(create: (_) => TranslatorProvider()),

        // LEARNING PROGRESS (lessons, XP, streak) for Home, Me, Translate
        // and the learning screens. Loads from the phone in the background
        // and syncs to Firestore while signed in (phone only when not).
        ChangeNotifierProvider(
          create: (_) => LearningProgress(
            cloud: FirestoreProgressCloud(),
            accounts: FirebaseAuth.instance.authStateChanges().map((user) => user?.uid),
          )..load(),
        ),

        // AUTH PROVIDER
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
      ],

      child: HibaloApp(firstOpen: firstOpen),
    ),
  );
}

/// SharedPreferences key: onboarding was seen (set when it finishes).
const String kHasSeenOnboarding = 'hasSeenOnboarding';

class HibaloApp extends StatelessWidget {
  const HibaloApp({super.key, this.firstOpen = true});

  /// No onboarding seen yet: the full splash, then onboarding.
  final bool firstOpen;

  @override
  Widget build(BuildContext context) {
    // Rebuilds when the app language changes. Only the app's own words
    // follow it (see lib/l10n); lesson content never does.
    return ListenableBuilder(
      listenable: AppLanguage.instance,
      builder: (context, _) => MaterialApp(
        title: 'Hibalo',
        debugShowCheckedModeBanner: false,

        theme: buildAppTheme(),

        locale: AppLanguage.instance.locale,
        localizationsDelegates: AppLanguage.delegates,
        supportedLocales: AppLanguage.supportedLocales,

        home: AppRoot(firstOpen: firstOpen),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// APP ROOT
// ─────────────────────────────────────────────────────

enum _Phase { splash, quickSplash, onboarding, welcome, auth, home, admin }

/// Where the app goes after the splash.
enum LaunchTarget { onboarding, signUp, home, admin }

/// The launch rule: signed in → Home (admins → the admin dashboard);
/// signed out → onboarding on the first open, Sign Up after that.
LaunchTarget launchTarget({required bool firstOpen, required bool signedIn, required bool isAdmin}) {
  if (signedIn) return isAdmin ? LaunchTarget.admin : LaunchTarget.home;
  return firstOpen ? LaunchTarget.onboarding : LaunchTarget.signUp;
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key, this.firstOpen = true});

  /// First open: the full splash (mascot, tagline) and onboarding.
  /// Otherwise: the short plain splash (wordmark only).
  final bool firstOpen;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late _Phase _phase = widget.firstOpen ? _Phase.splash : _Phase.quickSplash;

  /// Welcome's Get started opens Sign Up; everything else opens Sign In.
  bool _authSignUp = false;

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

      // ── SHORT SPLASH (every later launch) ─
      case _Phase.quickSplash:
        return QuickSplashScreen(
          key: const ValueKey('quickSplash'),
          onReady: _onSplashFinished,
        );

      // ── ONBOARDING ────────────────────────
      case _Phase.onboarding:
        return OnboardingScreen(
          key: const ValueKey('onboarding'),
          onFinish: _onOnboardingFinished,
        );

      // ── WELCOME ───────────────────────────
      case _Phase.welcome:
        return WelcomeScreen(
          key: const ValueKey('welcome'),
          onGetStarted: () => _openAuth(signUp: true),
          onSignIn: () => _openAuth(signUp: false),
        );

      // ── AUTH ──────────────────────────────
      case _Phase.auth:
        return AuthScreen(
          key: ValueKey('auth-$_authSignUp'),
          startWithSignUp: _authSignUp,
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

  // ── SPLASH FINISHED: sign-in check, then route ──────
  Future<void> _onSplashFinished() async {
    final user = FirebaseAuth.instance.currentUser;
    final authProvider = context.read<app.AuthProvider>();
    if (user != null) await authProvider.refreshAdminRole(user.uid);
    if (!mounted) return;
    final target = launchTarget(
      firstOpen: widget.firstOpen,
      signedIn: user != null,
      isAdmin: authProvider.isAdmin,
    );
    setState(() {
      _authSignUp = target == LaunchTarget.signUp;
      _phase = switch (target) {
        LaunchTarget.onboarding => _Phase.onboarding,
        LaunchTarget.signUp => _Phase.auth,
        LaunchTarget.home => _Phase.home,
        LaunchTarget.admin => _Phase.admin,
      };
    });
  }

  // ── ONBOARDING FINISHED ─────────────────────────────
  Future<void> _onOnboardingFinished() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kHasSeenOnboarding, true);

    setState(() {
      _phase = _Phase.welcome;
    });
  }

  // ── WELCOME → SIGN IN / SIGN UP ─────────────────────
  void _openAuth({required bool signUp}) {
    setState(() {
      _authSignUp = signUp;
      _phase = _Phase.auth;
    });
  }

  // ── LOGOUT → straight to Sign Up ────────────────────
  void _onLogout() {
    setState(() {
      _authSignUp = true;
      _phase = _Phase.auth;
    });
  }
}
