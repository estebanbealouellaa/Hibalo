// The three launch paths: first open (full splash → onboarding), later
// launches signed in (plain splash → Home / admin) and signed out (plain
// splash → Sign Up).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/main.dart';
import 'package:hibalo_app/screens/quick_splash_screen.dart';
import 'package:hibalo_app/screens/splash_screen.dart';

void main() {
  group('launchTarget', () {
    test('first open, signed out → onboarding', () {
      expect(launchTarget(firstOpen: true, signedIn: false, isAdmin: false), LaunchTarget.onboarding);
    });
    test('later launch, signed out → Sign Up', () {
      expect(launchTarget(firstOpen: false, signedIn: false, isAdmin: false), LaunchTarget.signUp);
    });
    test('signed in → Home, admins → the admin dashboard', () {
      expect(launchTarget(firstOpen: false, signedIn: true, isAdmin: false), LaunchTarget.home);
      expect(launchTarget(firstOpen: false, signedIn: true, isAdmin: true), LaunchTarget.admin);
      expect(launchTarget(firstOpen: true, signedIn: true, isAdmin: false), LaunchTarget.home);
    });
  });

  testWidgets('first open shows the full splash (mascot, tagline)', (tester) async {
    await tester.pumpWidget(const HibaloApp(firstOpen: true));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(QuickSplashScreen), findsNothing);
    expect(find.text('Hiligaynon · Filipino'), findsOneWidget);
    // Leave before the splash timer moves on (that needs Firebase).
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('later launches show the plain splash: the wordmark only', (tester) async {
    var ready = 0;
    await tester.pumpWidget(MaterialApp(home: QuickSplashScreen(onReady: () => ready++)));
    expect(find.text('Hibalo'), findsOneWidget);
    expect(find.text('Hiligaynon · Filipino'), findsNothing);
    expect(find.byType(Image), findsNothing, reason: 'no mascot');
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump();
    expect(ready, 1, reason: 'the sign-in check starts at once');
    // A slow check shows the spinner after a second.
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
