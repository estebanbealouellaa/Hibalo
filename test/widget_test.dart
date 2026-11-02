// Smoke test: the app's root widget builds and starts on the splash screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hibalo_app/main.dart';
import 'package:hibalo_app/screens/splash_screen.dart';

void main() {
  testWidgets('HibaloApp starts on the splash screen', (tester) async {
    await tester.pumpWidget(const HibaloApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AppRoot), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);

    // Leave the splash before its timer ends: moving on needs Firebase.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
