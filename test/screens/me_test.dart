// Stage D: Me, Edit profile (username + local avatar), avatars (old
// DiceBear values still show), Settings › Privacy / Credits, Help.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/screens/edit_profile_screen.dart';
import 'package:hibalo_app/screens/help_support_screen.dart';
import 'package:hibalo_app/screens/profile_screen.dart';
import 'package:hibalo_app/screens/settings_screen.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6_avatar.dart';
import 'package:hibalo_app/l10n/app_localizations.dart';
import 'package:hibalo_app/services/account_service.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _diceBearMochi = 'https://api.dicebear.com/9.x/fun-emoji/png?seed=Mochi&size=128';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LessonCatalog catalog;
  setUpAll(() async {
    catalog = (await LessonRepository.load(rootBundle)).catalog;
  });
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
  final en = lookupAppLocalizations(const Locale('en'));

  Future<void> pump(WidgetTester tester, Widget home, {double height = 1000}) async {
    tester.view.physicalSize = Size(360, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: LearningProgress.ready(catalog, ProgressSnapshot()),
        child: MaterialApp(
          localizationsDelegates: AppLanguage.delegates,
          supportedLocales: AppLanguage.supportedLocales,
          theme: buildAppTheme(),
          home: home,
        ),
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
    testWidgets('profile card and Account rows, with Language', (tester) async {
      await pump(
        tester,
        ProfileScreen(userName: 'ana_hibalo', photoUrl: 'asset:avatar1', email: 'ana@example.com', onLogout: () {}),
      );
      expect(find.text('Me'), findsOneWidget);
      expect(find.text('ana_hibalo'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget);
      expect(find.text('${catalog.levels.first.title} · Level 1'), findsOneWidget);
      expect(find.text('DAY STREAK'), findsOneWidget);
      for (final row in ['Edit profile', 'Language', 'Settings', 'Help & Support', 'Log out']) {
        expect(find.text(row), findsOneWidget, reason: row);
      }
      expect(find.text('English'), findsOneWidget, reason: 'the Language row shows the current language');
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
    Future<(_FakeAccount, List<Object?>, List<int>)> openEdit(WidgetTester tester, {String? photo}) async {
      final account = _FakeAccount();
      final results = <Object?>[];
      final deleted = <int>[];
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
                      currentPhotoUrl: photo ?? _diceBearMochi,
                      account: account,
                      onAccountDeleted: () => deleted.add(1),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
        height: 1600,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return (account, results, deleted);
    }

    /// The text field under [label] (V6TextField: label, then the field).
    Finder field(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(V6TextField)),
      matching: find.byType(TextField),
    );

    const current = "Current password (to confirm it's you)";

    testWidgets('all Figma fields; username + avatar save as "asset:avatarN"; short name shows the error', (
      tester,
    ) async {
      final (account, results, _) = await openEdit(tester);
      for (final label in [
        'Choose an avatar',
        'Username',
        'Email',
        'New password',
        'Confirm new password',
        current,
        'Only needed to change your email or password.',
        'Forgot your password?',
        'Save changes',
        'Delete account',
      ]) {
        expect(find.text(label), findsWidgets, reason: label);
      }
      expect(find.text('10/30'), findsOneWidget);
      expect(find.text('ana@example.com'), findsOneWidget, reason: 'the email field shows the current email');
      // The old DiceBear avatar starts on its slot (3).
      expect(tester.getSemantics(find.bySemanticsLabel('Avatar 3')).flagsCollection.isSelected.name, 'isTrue');

      await tester.enterText(field('Username'), 'An');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Username must be at least 3 characters.'), findsOneWidget);
      expect(account.calls, isEmpty);

      await tester.enterText(field('Username'), 'ana_new');
      await tester.tap(find.bySemanticsLabel('Avatar 5'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(account.calls, ['save ana_new asset:avatar5'], reason: 'no password needed for name and avatar');
      expect(results, [true], reason: 'Me then shows "Profile updated"');
    });

    testWidgets('wrong current password: the error, and nothing changes', (tester) async {
      final (account, results, _) = await openEdit(tester);
      account.passwordOk = false;
      await tester.enterText(field('New password'), 'newpass123');
      await tester.enterText(field('Confirm new password'), 'newpass123');
      await tester.enterText(field(current), 'wrong1');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text("That password isn't right. Try again."), findsOneWidget);
      expect(account.calls, ['confirm wrong1']);
      expect(results, isEmpty);
    });

    testWidgets('new password: rules as Sign Up, needs the current password, then changes it', (tester) async {
      final (account, results, _) = await openEdit(tester);
      await tester.enterText(field('New password'), 'abc');
      await tester.enterText(field('Confirm new password'), 'abd');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('At least 6 characters'), findsOneWidget);
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(find.text('Enter your current password to change your email or password.'), findsOneWidget);
      expect(account.calls, isEmpty);

      await tester.enterText(field('New password'), 'newpass123');
      await tester.enterText(field('Confirm new password'), 'newpass123');
      await tester.enterText(field(current), 'old123');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(account.calls, ['confirm old123', 'save ana_hibalo asset:avatar3', 'password newpass123']);
      expect(results, [true]);
    });

    testWidgets('new email: verify link, "Check your new email", Resend link', (tester) async {
      final (account, results, _) = await openEdit(tester);
      await tester.enterText(field('Email'), 'ana.new@example.com');
      await tester.enterText(field(current), 'old123');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Check your new email'), findsOneWidget);
      expect(find.textContaining('We sent a link to ana.new@example.com'), findsOneWidget);
      await tester.tap(find.text('Resend link'));
      await tester.pumpAndSettle();
      expect(account.calls.where((c) => c == 'email ana.new@example.com'), hasLength(2));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(results, [true]);
    });

    testWidgets('Delete account: needs the current password, then confirm; Keep does nothing', (tester) async {
      final (account, _, deleted) = await openEdit(tester);
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your current password to delete your account.'), findsOneWidget);
      expect(find.text('Delete your account?'), findsNothing);

      await tester.enterText(field(current), 'old123');
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete your account?'), findsOneWidget);
      await tester.tap(find.text('Keep my account'));
      await tester.pumpAndSettle();
      expect(account.calls, isEmpty);

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account').last);
      await tester.pumpAndSettle();
      expect(account.calls, ['confirm old123', 'delete']);
      expect(deleted, [1], reason: 'then Sign Up');
    });

    testWidgets('Delete account with a wrong password deletes nothing', (tester) async {
      final (account, _, deleted) = await openEdit(tester);
      account.passwordOk = false;
      await tester.enterText(field(current), 'wrong1');
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete account').last);
      await tester.pumpAndSettle();
      expect(find.text("That password isn't right. Try again."), findsOneWidget);
      expect(account.calls, ['confirm wrong1']);
      expect(deleted, isEmpty);
    });
  });

  group('Settings, Privacy, Credits, Help', () {
    testWidgets('Settings: Data and About rows; Privacy and Credits open', (tester) async {
      await pump(tester, const SettingsScreen());
      expect(find.text('Clear translation history'), findsOneWidget);
      expect(find.text('Clear saved words'), findsOneWidget);
      expect(find.text('App version'), findsOneWidget);
      expect(find.text('Hibalo 1.0.0'), findsOneWidget);

      await tester.tap(find.text('Privacy policy'));
      await tester.pumpAndSettle();
      expect(find.text(en.privacyIntro), findsOneWidget);
      expect(
        find.textContaining('Your translation history and saved words are kept only on your phone', findRichText: true),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Credits & licences'));
      await tester.pumpAndSettle();
      expect(find.text(en.creditsIntro), findsOneWidget);
      expect(find.textContaining('CC BY-NC 4.0', findRichText: true), findsOneWidget);
      await tester.ensureVisible(find.text('Open-source software'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open-source software'));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
    });

    testWidgets('Help: one answer open at a time, and the contact row', (tester) async {
      await pump(tester, const HelpSupportScreen());
      expect(find.text(faqs(en)[0].$2), findsOneWidget, reason: 'the first answer is open, as in Figma');
      await tester.tap(find.text(faqs(en)[4].$1));
      await tester.pumpAndSettle();
      expect(find.text(faqs(en)[4].$2), findsOneWidget);
      expect(find.text(faqs(en)[0].$2), findsNothing);
      expect(find.text('Still need help?'), findsOneWidget);
      expect(find.text('Email us at $kSupportEmail'), findsOneWidget);
    });
  });
}

/// Records what Edit profile asks the account to do.
class _FakeAccount implements AccountActions {
  final calls = <String>[];
  bool passwordOk = true;

  @override
  String? get email => 'ana@example.com';

  @override
  Future<void> saveProfile(String username, String photoUrl) async => calls.add('save $username $photoUrl');

  @override
  Future<void> confirmPassword(String password) async {
    calls.add('confirm $password');
    if (!passwordOk) throw const AccountException(AccountProblem.wrongPassword);
  }

  @override
  Future<void> changeEmail(String newEmail) async => calls.add('email $newEmail');

  @override
  Future<void> changePassword(String newPassword) async => calls.add('password $newPassword');

  @override
  Future<void> deleteAccount() async => calls.add('delete');
}
