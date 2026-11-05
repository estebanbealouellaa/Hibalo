// Stage A screens: onboarding Skip, the Sign In / Sign Up banners and
// Forgot password. Firebase is never touched: the auth provider and the
// reset call are fakes.

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/providers/auth_provider.dart';
import 'package:hibalo_app/screens/auth_screen.dart';
import 'package:hibalo_app/screens/forgot_password_screen.dart';
import 'package:hibalo_app/screens/onboarding_screen.dart';
import 'package:hibalo_app/screens/welcome_screen.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';
import 'package:provider/provider.dart';

/// Fails every sign in / sign up with [code], or succeeds when null.
class FakeAuth extends AuthProvider {
  FakeAuth(this.code, [this.message]);

  final String? code;
  final String? message;
  int signIns = 0;
  int signUps = 0;

  @override
  String? get errorCode => code;
  @override
  String? get errorMessage => message;

  @override
  Future<bool> signIn({required String email, required String password}) async {
    signIns++;
    return code == null;
  }

  @override
  Future<bool> signUp({required String name, required String email, required String password}) async {
    signUps++;
    return code == null;
  }
}

Future<void> _pump(WidgetTester tester, Widget child, {AuthProvider? auth}) async {
  tester.view.physicalSize = const Size(360, 760);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  Widget app = MaterialApp(theme: buildAppTheme(), home: child);
  if (auth != null) app = ChangeNotifierProvider<AuthProvider>.value(value: auth, child: app);
  await tester.pumpWidget(app);
  await tester.pump();
}

Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'ana@example.com');
  await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
  await tester.tap(find.text('Sign in'));
  await tester.pump();
  await tester.pump();
}

void main() {
  // ── Onboarding ─────────────────────────────────────────────────────────

  group('Onboarding', () {
    testWidgets('Skip finishes onboarding from page 1', (tester) async {
      var finished = 0;
      await _pump(tester, OnboardingScreen(onFinish: () => finished++));
      expect(find.text('Welcome to Hibalo'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      expect(finished, 1);
    });

    testWidgets('Next through all 3 pages; the last has no Skip and Get started finishes', (tester) async {
      var finished = 0;
      await _pump(tester, OnboardingScreen(onFinish: () => finished++));
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Type it, say it, or snap it'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Learn a little every day'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(finished, 0);
      await tester.tap(find.text('Get started'));
      expect(finished, 1);
    });
  });

  testWidgets('Welcome: Get started and I already have an account', (tester) async {
    var started = 0, signIn = 0;
    await _pump(tester, WelcomeScreen(onGetStarted: () => started++, onSignIn: () => signIn++));
    await tester.tap(find.text('Get started'));
    await tester.tap(find.text('I already have an account'));
    expect((started, signIn), (1, 1));
  });

  // ── Sign In / Sign Up banners ─────────────────────────────────────────

  group('Auth banners', () {
    testWidgets('wrong password: the error banner "Wrong email or password."', (tester) async {
      final auth = FakeAuth('invalid-credential', 'The supplied auth credential is incorrect.');
      await _pump(tester, AuthScreen(onAuthSuccess: () {}), auth: auth);
      expect(find.text('Welcome back.'), findsOneWidget);
      await _signIn(tester);
      expect(auth.signIns, 1);
      final banner = tester.widget<V6Banner>(find.byType(V6Banner));
      expect(banner.type, V6BannerType.error);
      expect(find.text('Wrong email or password.'), findsOneWidget);
    });

    testWidgets('no internet: the warning banner on Sign In and Sign Up', (tester) async {
      final auth = FakeAuth('network-request-failed', 'A network error has occurred.');
      await _pump(tester, AuthScreen(onAuthSuccess: () {}), auth: auth);
      await _signIn(tester);
      expect(tester.widget<V6Banner>(find.byType(V6Banner)).type, V6BannerType.warning);
      expect(find.text('No internet. Connect to sign in.'), findsOneWidget);

      expect(
        AuthBanner.fromError(code: 'network-request-failed', message: null, isLogin: false).message,
        'No internet. Connect to sign up.',
      );
    });

    testWidgets('Sign Up: email in use shows the banner and marks the email field', (tester) async {
      final auth = FakeAuth('email-already-in-use', 'The email address is already in use by another account.');
      await _pump(tester, AuthScreen(onAuthSuccess: () {}, startWithSignUp: true), auth: auth);
      expect(find.text('Join Hibalo.'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'ana_hibalo');
      await tester.enterText(fields.at(1), 'ana@example.com');
      await tester.enterText(fields.at(2), 'secret123');
      await tester.enterText(fields.at(3), 'secret123');
      await tester.ensureVisible(find.text('Create account'));
      await tester.tap(find.text('Create account'));
      await tester.pump();
      await tester.pump();
      expect(auth.signUps, 1);
      expect(find.text('This email is already in use.'), findsOneWidget);
    });

    testWidgets('switching Sign Up → Sign In keeps the password hidden', (tester) async {
      await _pump(tester, AuthScreen(onAuthSuccess: () {}, startWithSignUp: true), auth: FakeAuth(null));
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields, hasLength(2));
      expect(fields[0].obscureText, isFalse, reason: 'email');
      expect(fields[1].obscureText, isTrue, reason: 'password');
    });

    testWidgets('other errors keep Firebase\'s own message, as before', (tester) async {
      final b = AuthBanner.fromError(code: 'too-many-requests', message: 'Try again later.', isLogin: true);
      expect((b.type, b.message), (V6BannerType.error, 'Try again later.'));
    });

    testWidgets('the validators still run first (nothing is sent)', (tester) async {
      final auth = FakeAuth(null);
      await _pump(tester, AuthScreen(onAuthSuccess: () {}), auth: auth);
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      expect(find.text('Enter your email'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(auth.signIns, 0);
    });

    testWidgets('success calls onAuthSuccess (the app root then routes admins)', (tester) async {
      var ok = 0;
      await _pump(tester, AuthScreen(onAuthSuccess: () => ok++), auth: FakeAuth(null));
      await _signIn(tester);
      expect(ok, 1);
      expect(find.byType(V6Banner), findsNothing);
    });
  });

  // ── Forgot password ───────────────────────────────────────────────────

  group('Forgot password', () {
    testWidgets('Send reset link → Check your email, with the address', (tester) async {
      final sent = <String>[];
      await _pump(tester, ForgotPasswordScreen(sendReset: (e) async => sent.add(e)));
      expect(find.text('Forgot your password?'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), ' ana@example.com ');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      await tester.pump();
      expect(sent, ['ana@example.com']);
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('We sent a reset link to ana@example.com.'), findsOneWidget);

      await tester.tap(find.text('Resend link'));
      await tester.pump();
      await tester.pump();
      expect(sent, hasLength(2));
      expect(find.text('Reset link sent again'), findsOneWidget);
    });

    testWidgets('a bad email is caught before sending', (tester) async {
      final sent = <String>[];
      await _pump(tester, ForgotPasswordScreen(sendReset: (e) async => sent.add(e)));
      await tester.enterText(find.byType(TextFormField), 'not-an-email');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      expect(find.text('That email doesn\'t look right'), findsOneWidget);
      expect(sent, isEmpty);
    });

    testWidgets('no internet shows the warning banner and stays on the form', (tester) async {
      await _pump(
        tester,
        ForgotPasswordScreen(sendReset: (_) async => throw FirebaseAuthException(code: 'network-request-failed')),
      );
      await tester.enterText(find.byType(TextFormField), 'ana@example.com');
      await tester.tap(find.text('Send reset link'));
      await tester.pump();
      await tester.pump();
      expect(find.text('No internet. Connect to send the link.'), findsOneWidget);
      expect(find.text('Check your email'), findsNothing);
    });

    testWidgets('Sign In links to Forgot password with the typed email', (tester) async {
      await _pump(tester, AuthScreen(onAuthSuccess: () {}), auth: FakeAuth(null));
      await tester.enterText(find.byType(TextFormField).at(0), 'ana@example.com');
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'ana@example.com'), findsOneWidget);
    });
  });
}
