// Longer Filipino and Hiligaynon words must fit at the Galaxy A03's width
// (360 dp). Any overflow fails the test.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/l10n/app_language.dart';
import 'package:hibalo_app/l10n/app_localizations.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/progress.dart';
import 'package:hibalo_app/learning/state/learning_progress.dart';
import 'package:hibalo_app/screens/edit_profile_screen.dart';
import 'package:hibalo_app/screens/help_support_screen.dart';
import 'package:hibalo_app/screens/language_screen.dart';
import 'package:hibalo_app/screens/profile_screen.dart';
import 'package:hibalo_app/screens/settings_screen.dart';
import 'package:hibalo_app/screens/translate/history_screen.dart';
import 'package:hibalo_app/services/account_service.dart';
import 'package:hibalo_app/theme/v6_app_theme.dart';
import 'package:hibalo_app/widgets/v6/v6.dart';
import 'package:hibalo_app/widgets/v6/v6_nav_bar.dart';
import 'package:hibalo_app/widgets/v6/v6_translate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _NoAccount implements AccountActions {
  @override
  String? get email => 'estudyante.hiligaynon@example.com';
  @override
  Future<void> saveProfile(String username, String photoUrl) async {}
  @override
  Future<void> confirmPassword(String password) async {}
  @override
  Future<void> changeEmail(String newEmail) async {}
  @override
  Future<void> changePassword(String newPassword) async {}
  @override
  Future<void> deleteAccount() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LearningProgress progress;
  setUpAll(() async {
    progress = LearningProgress.ready((await LessonRepository.load(rootBundle)).catalog, ProgressSnapshot());
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

  final screens = <String, Widget Function(AppLocalizations t)>{
    'Me': (_) => ProfileScreen(
      userName: 'mahaba_ang_pangalan_ko',
      photoUrl: 'asset:avatar1',
      email: 'estudyante.hiligaynon@example.com',
      onLogout: () {},
    ),
    'Edit profile': (_) => EditProfileScreen(currentUsername: 'ana_hibalo', account: _NoAccount()),
    'Settings': (_) => const SettingsScreen(),
    'Language': (_) => const LanguageScreen(),
    'Help': (_) => const HelpSupportScreen(),
    'History': (_) => const TranslateHistoryScreen(),
    'Saved': (_) => const TranslateHistoryScreen(showSaved: true),
    'Translate cards + bottom bar': (t) => Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LanguageSwitchCard(from: 'Hiligaynon', to: 'Filipino', onSwap: () {}),
          const SizedBox(height: 16),
          TranslationInputCard(
            language: 'Hiligaynon',
            textArea: const Text('Maayong aga'),
            characters: 11,
            filled: true,
            translating: true,
            onSpeak: () {},
            onScan: () {},
            onTranslate: () {},
            onClear: () {},
          ),
          const SizedBox(height: 16),
          TranslationResultCard(
            language: 'Filipino',
            text: 'Magandang umaga',
            translating: false,
            onListen: () {},
            onCopy: () {},
            onShare: () {},
            onSave: () {},
          ),
          const SizedBox(height: 16),
          V6MessageCard(
            icon: Icons.error_outline_rounded,
            title: t.camCouldntReadTitle,
            message: t.camCouldntReadBody,
            actions: [
              V6Button(label: t.tryAgain, style: V6ButtonStyle.secondary, onPressed: () {}),
              V6Button(label: t.camChooseAnother, style: V6ButtonStyle.text, onPressed: () {}),
            ],
          ),
        ],
      ),
      bottomNavigationBar: V6NavBar(
        selected: 0,
        onSelect: (_) {},
        items: [
          V6NavItem(Icons.home_rounded, t.navHome),
          V6NavItem(Icons.translate_rounded, t.navTranslate),
          V6NavItem(Icons.menu_book_rounded, t.navLearn),
          V6NavItem(Icons.person_rounded, t.navMe),
        ],
      ),
    ),
  };

  for (final lang in ['fil', 'hil']) {
    for (final MapEntry(key: name, value: build) in screens.entries) {
      testWidgets('$name fits in $lang at 360 dp', (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(
          ChangeNotifierProvider.value(
            value: progress,
            child: MaterialApp(
              theme: buildAppTheme(),
              locale: Locale(lang),
              localizationsDelegates: AppLanguage.delegates,
              supportedLocales: AppLanguage.supportedLocales,
              home: Builder(builder: (context) => build(AppLocalizations.of(context))),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
