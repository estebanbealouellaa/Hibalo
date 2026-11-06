// Stage D: Me, Edit profile (username + local avatar), avatars (old
// DiceBear values still show), Settings › Privacy / Credits, Help.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/screens/about_screens.dart';
import 'package:hibalo_app/screens/edit_profile_screen.dart';
import 'package:hibalo_app/screens/help_support_screen.dart';
import 'package:hibalo_app/screens/profile_screen.dart';
import 'package:hibalo_app/screens/settings_screen.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6_avatar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _diceBearMochi = 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Mochi&size=128';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: LearningProgress.ready(catalog, ProgressSnapshot()),
        child: MaterialApp(theme: buildAppTheme(), home: home),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('Avatars', () {
    test('stable local values, and old DiceBear addresses map to the same slot', () {
      expect(avatarValue(0), 'asset:avatar1');
      expect(avatarIndexOf('asset:avatar6'), 5);
      expect(avatarIndexOf(_diceBearMochi), 2);
      expect(avatarIndexOf('https://api.dicebear.com/9.x/fun-emoji/png?seed=Other'), 0);
      expect(avatarIndexOf('https://example.com/me.png'), isNull);
      expect(avatarIndexOf(null), isNull);
    });

    testWidgets('a local avatar shows its picture', (tester) async {
      await pump(tester, const Scaffold(body: V6Avatar(photoUrl: 'asset:avatar4')));
      expect(find.image(const AssetImage('assets/images/profile/avatar4.webp')), findsOneWidget);
    });

    testWidgets('an old DiceBear photoUrl still shows (local avatar when it can\'t load)', (tester) async {
      await pump(tester, const Scaffold(body: V6Avatar(photoUrl: _diceBearMochi)));
      // Tests have no internet: the web picture fails and the matching local one shows.
      expect(find.image(const AssetImage('assets/images/profile/avatar3.webp')), findsOneWidget);
    });
  });

  group('Me', () {
    testWidgets('profile card and Account rows; Language is hidden', (tester) async {
      await pump(
        tester,
        ProfileScreen(userName: 'ana_hibalo', photoUrl: 'asset:avatar1', email: 'ana@example.com', onLogout: () {}),
      );
      expect(find.text('Me'), findsOneWidget);
      expect(find.text('ana_hibalo'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('${catalog.levels.first.title} · Level 1'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsOneWidget);
      for (final row in ['Edit profile', 'Settings', 'Help & Support', 'Log out']) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      expect(find.text('Language'), findsNothing);
    });

    testWidgets('Log out asks first; Stay keeps you, Log out logs out', (tester) async {
      var logouts = 0;
      await pump(tester, ProfileScreen(userName: 'ana', photoUrl: null, email: '', onLogout: () => logouts++));
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(find.text('Log out?'), findsOneWidget);
      expect(find.text('Your progress is saved. You can sign back in any time.'), findsOneWidget);
      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(logouts, 0);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Log out').last);
      await tester.pumpAndSettle();
      expect(logouts, 1);
    });

    testWidgets('pages open inside the Me tab; back returns to Me', (tester) async {
      await pump(
        tester,
        Scaffold(
          body: MeTab(userName: 'ana', photoUrl: 'asset:avatar2', onLogout: () {}),
          bottomNavigationBar: const SizedBox(height: 80, child: Text('BOTTOM BAR')),
        ),
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Clear translation history'), findsOneWidget);
      expect(find.text('BOTTOM BAR'), findsOneWidget, reason: 'the bottom bar stays');
      expect(MeTab.handleBack(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Account'), findsOneWidget);
      expect(MeTab.handleBack(), isFalse);
    });

    testWidgets('Me shows the new name and avatar after they change', (tester) async {
      Widget me(String name, String photo) => Scaffold(
        body: MeTab(userName: name, photoUrl: photo, onLogout: () {}),
      );
      await pump(tester, me('ana', 'asset:avatar1'));
      await pump(tester, me('ana_new', 'asset:avatar5'));
      expect(find.text('ana_new'), findsOneWidget);
      expect(find.image(const AssetImage('assets/images/profile/avatar5.webp')), findsOneWidget);
    });
  });

  group('Edit profile', () {
    testWidgets('username + avatar only; saves "asset:avatarN"; short name shows the error', (tester) async {
      final saved = <(String, String)>[];
      final results = <Object?>[];
      await pump(
        tester,
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async => results.add(
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      currentUsername: 'ana_hibalo',
                      currentPhotoUrl: _diceBearMochi,
                      save: (name, photo) async => saved.add((name, photo)),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Choose an avatar'), findsOneWidget);
      expect(find.text('10/30'), findsOneWidget);
      for (final hidden in ['Email', 'New password', 'Forgot your password?', 'Delete account']) {
        expect(find.text(hidden), findsNothing, reason: hidden);
      }
      // The old DiceBear avatar starts on its slot (3).
      expect(tester.getSemantics(find.bySemanticsLabel('Avatar 3')).flagsCollection.isSelected.name, 'isTrue');

      await tester.enterText(find.byType(TextField), 'An');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be at least 3 characters.'), findsOneWidget);
      expect(saved, isEmpty);

      await tester.enterText(find.byType(TextField), 'ana_new');
      await tester.tap(find.bySemanticsLabel('Avatar 5'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(saved, [('ana_new', 'asset:avatar5')]);
      expect(results, [true], reason: 'Me then shows "Profile updated"');
    });
  });

  group('Settings, Privacy, Credits, Help', () {
    testWidgets('Settings: Data and About rows; Privacy and Credits open', (tester) async {
      await pump(tester, const SettingsScreen());
      expect(find.text('Clear translation history'), findsOneWidget);
      expect(find.text('Clear saved words'), findsOneWidget);
      expect(find.text('App version'), findsNothing, reason: 'hidden: no version source yet');

      await tester.tap(find.text('Privacy policy'));
      await tester.pumpAndSettle();
      expect(find.text(kPrivacyIntro), findsOneWidget);
      expect(
        find.textContaining('Your translation history and saved words are kept only on your phone', findRichText: true),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Credits & licences'));
      await tester.pumpAndSettle();
      expect(find.text(kCreditsIntro), findsOneWidget);
      expect(find.textContaining('CC BY-NC 4.0', findRichText: true), findsOneWidget);
      await tester.ensureVisible(find.text('Open-source software'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open-source software'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('Help: one answer open at a time, and the contact row', (tester) async {
      await pump(tester, const HelpSupportScreen());
      expect(find.text(kFaqs[0].$2), findsOneWidget, reason: 'the first answer is open, as in Figma');
      await tester.tap(find.text(kFaqs[4].$1));
      await tester.pumpAndSettle();
      expect(find.text(kFaqs[4].$2), findsOneWidget);
      expect(find.text(kFaqs[0].$2), findsNothing);
      expect(find.text('Still need help?'), findsOneWidget);
      expect(find.text('Email us at $kSupportEmail'), findsOneWidget);
    });
  });
}
