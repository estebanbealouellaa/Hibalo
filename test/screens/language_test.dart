// The language pop-up (after Sign Up only), Me › Language, and every UI string in English, Filipino and Hiligaynon.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/l10n/app_localizations.dart';
import 'package:hibalo_app/screens/language_screen.dart';
import 'package:hibalo_app/screens/settings_screen.dart';
import 'package:hibalo_app/services/language_prompt.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An app that follows AppLanguage, like main.dart.
Widget _app(Widget home) => ListenableBuilder(
  listenable: AppLanguage.instance,
  builder: (_, _) => MaterialApp(
    theme: buildAppTheme(),
    locale: AppLanguage.instance.locale,
    localizationsDelegates: AppLanguage.delegates,
    supportedLocales: AppLanguage.supportedLocales,
    home: home,
  ),
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Hibalo',
      packageName: 'com.example.hibalo_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });
  tearDown(() => AppLanguage.instance.setLanguage('English'));

  testWidgets('after Sign Up the pop-up shows once; Continue saves the choice', (tester) async {
    LanguagePrompt.resetForTest();
    await tester.runAsync(() => LanguagePrompt.afterSignUp('u1'));
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(onPressed: () => askLanguageAfterSignUp(context, uid: 'u1'), child: const Text('home')),
          ),
        ),
      ),
    );
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();
    expect(find.text('Piliin ang iyong wika'), findsOneWidget, reason: 'the pop-up previews the choice');
    await tester.tap(find.text('Magpatuloy'));
    await tester.pumpAndSettle();
    expect(AppLanguage.instance.language, 'Filipino');
    expect((await SharedPreferences.getInstance()).getString('app_language'), 'Filipino');

    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    expect(find.text('Piliin ang iyong wika'), findsNothing, reason: 'only once');
  });

  testWidgets('only a brand-new account sees the pop-up; signing in never shows it', (tester) async {
    LanguagePrompt.resetForTest();
    String uid = 'existing';
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => askLanguageAfterSignUp(context, uid: uid),
              child: const Text('home'),
            ),
          ),
        ),
      ),
    );
    Future<bool> opens() async {
      await tester.tap(find.text('home'));
      await tester.pumpAndSettle();
      final shown = find.text('Choose your language').evaluate().isNotEmpty;
      if (shown) {
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }
      return shown;
    }

    expect(await opens(), isFalse, reason: 'existing account signing in (first time on this phone too)');
    expect(await opens(), isFalse);

    // Sign Up: marked seen right away, keyed by uid, and Home shows it once.
    await tester.runAsync(() => LanguagePrompt.afterSignUp('newbie'));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(LanguagePrompt.seenKey('newbie')), isTrue);
    expect(await opens(), isFalse, reason: 'another account is on Home');
    uid = 'newbie';
    expect(await opens(), isTrue, reason: 'right after Sign Up');
    expect(await opens(), isFalse, reason: 'never twice');

    // Signing in again later (or after a reinstall) never shows it.
    LanguagePrompt.resetForTest();
    expect(await opens(), isFalse);
  });

  testWidgets('Me › Language changes the app right away, with a snackbar', (tester) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const LanguageScreen()));
    expect(find.text('App language'), findsOneWidget);
    expect(
      find.text('Changes the menus and buttons right away. Lessons stay in Hiligaynon with Filipino meanings.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Hiligaynon'));
    await tester.pumpAndSettle();
    expect(AppLanguage.instance.language, 'Hiligaynon');
    expect(find.text('Gin-ilisan ang lenguahe sa Hiligaynon'), findsOneWidget);
    expect(find.text('Lenguahe sang app'), findsOneWidget, reason: 'the screen itself is now in Hiligaynon');

    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();
    expect(find.text('Pinalitan ang wika sa Filipino'), findsOneWidget);
    expect(find.text('Wika ng app'), findsOneWidget);
  });

  testWidgets('other screens follow the setting (Settings in Filipino)', (tester) async {
    await AppLanguage.instance.setLanguage('Filipino');
    await tester.pumpWidget(_app(const SettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Tungkol sa app'), findsOneWidget);
    expect(find.text('Patakaran sa privacy'), findsOneWidget);
    expect(find.text('Bersyon ng app'), findsOneWidget);
  });

  test('every English UI string has Filipino and Hiligaynon', () {
    Map<String, dynamic> arb(String lang) =>
        jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync()) as Map<String, dynamic>;
    final en = arb('en').keys.where((k) => !k.startsWith('@')).toSet();
    for (final lang in ['fil', 'hil']) {
      final other = arb(lang).keys.where((k) => !k.startsWith('@')).toSet();
      expect(en.difference(other), isEmpty, reason: '$lang is missing keys');
    }
    expect(lookupAppLocalizations(const Locale('hil')).navMe, 'Ako');
  });
}
