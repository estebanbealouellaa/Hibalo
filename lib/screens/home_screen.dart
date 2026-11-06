import '../l10n/app_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../learning/learning_routes.dart';
import '../learning/screens/learn_screen.dart';
import '../providers/translator_provider.dart';
import '../services/account_service.dart';
import '../services/translation_store.dart';
import '../widgets/v6/v6_nav_bar.dart';
import 'home/home_tab.dart';
import 'language_screen.dart';
import 'profile_screen.dart';
import 'translator_screen.dart';

/// The signed-in app: four tabs (Home · Translate · Learn · Me); lessons and quizzes open full screen on top.
class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  /// Name and photo; the real app reads them from users/{uid}. Tests pass
  /// a fixed stream.
  final Stream<Map<String, dynamic>?>? userDoc;

  /// Replaces the four tab screens (tests only, so no translator engine or
  /// Firebase is needed).
  @visibleForTesting
  final List<Widget>? tabs;

  const HomeScreen({super.key, required this.onLogout, this.userDoc, this.tabs});

  static const int homeTab = 0;
  static const int translateTab = 1;
  static const int learnTab = 2;
  static const int meTab = 3;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _tab = HomeScreen.homeTab;
  int get tab => _tab;

  late final Stream<Map<String, dynamic>?> _userDoc = widget.userDoc ?? _firestoreUser();

  static Stream<Map<String, dynamic>?> _firestoreUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);
    return FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots().map((d) => d.data());
  }

  @override
  void initState() {
    super.initState();
    // "Back to lessons", Continue on S04/S05 and Leave return to Learn.
    LearningRoutes.showLearnTab = _showLearn;
    TranslationStore.instance.setUser(FirebaseAuthSafe.uid());
    if (widget.tabs == null) {
      // After a verified email change, users/{uid} gets the new email.
      syncEmail();
      // Figma 705:7496: only right after Sign Up, once.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) askLanguageAfterSignUp(context, uid: FirebaseAuthSafe.uid());
      });
    }
  }

  @override
  void dispose() {
    if (LearningRoutes.showLearnTab == _showLearn) LearningRoutes.showLearnTab = null;
    super.dispose();
  }

  void _showLearn() {
    if (mounted) select(HomeScreen.learnTab);
  }

  /// Rebuilds the Learn tab (search and level tab cleared) after it is left.
  int _learnGeneration = 0;

  void select(int tab) {
    if (tab != _tab) _resetTab(_tab);
    setState(() => _tab = tab);
  }

  /// A tab the user leaves returns to its first page; full-screen lesson and quiz screens aren't inside the tabs.
  void _resetTab(int tab) {
    switch (tab) {
      case HomeScreen.translateTab:
        TranslateTab.closePages();
      case HomeScreen.meTab:
        MeTab.closePages();
      case HomeScreen.learnTab:
        _learnGeneration++;
    }
  }

  Future<void> _logout() async {
    TranslationStore.instance.setUser(null);
    try {
      context.read<TranslatorProvider>().clearText();
    } catch (_) {
      // No translator (tests).
    }
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // No Firebase (tests).
    }
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      stream: _userDoc,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final userName = (data?['username'] as String?) ?? AppLocalizations.of(context).meUser;
        final photoUrl = (data?['photoUrl'] as String?) ?? FirebaseAuthSafe.photoUrl();
        return PopScope(
          canPop: _tab == HomeScreen.homeTab,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            // Translate cancels a running photo scan first.
            if (_tab == HomeScreen.translateTab && TranslateTab.handleBack()) return;
            if (_tab == HomeScreen.meTab && MeTab.handleBack()) return;
            select(HomeScreen.homeTab);
          },
          // Dark status-bar icons on the light tabs (a tab can still set
          // its own).
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.dark,
            child: Scaffold(
              body: IndexedStack(
                index: _tab,
                children: [
                  for (final (i, tab)
                      in (widget.tabs ??
                              [
                                HomeTab(
                                  userName: userName,
                                  photoUrl: photoUrl,
                                  onOpenLearn: () => select(HomeScreen.learnTab),
                                ),
                                const TranslateTab(),
                                const LearnScreen(),
                                MeTab(userName: userName, photoUrl: photoUrl, onLogout: _logout),
                              ])
                          .indexed)
                    // A new key after leaving Learn = a fresh lesson list.
                    i == HomeScreen.learnTab ? KeyedSubtree(key: ValueKey(_learnGeneration), child: tab) : tab,
                ],
              ),
              bottomNavigationBar: V6NavBar(
                selected: _tab,
                onSelect: select,
                items: [
                  V6NavItem(Icons.home_rounded, AppLocalizations.of(context).navHome),
                  V6NavItem(Icons.translate_rounded, AppLocalizations.of(context).navTranslate),
                  V6NavItem(Icons.menu_book_rounded, AppLocalizations.of(context).navLearn),
                  V6NavItem(Icons.person_rounded, AppLocalizations.of(context).navMe),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The signed-in user's Firebase photo, or null (also when Firebase isn't
/// set up, as in tests).
abstract final class FirebaseAuthSafe {
  static String? photoUrl() {
    try {
      return FirebaseAuth.instance.currentUser?.photoURL;
    } catch (_) {
      return null;
    }
  }

  static String? uid() {
    try {
      return FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }
}
