import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_language.dart';
import '../l10n/app_localizations.dart';
import '../learning/models/catalog.dart';
import '../learning/state/learning_progress.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_avatar.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'language_screen.dart';
import 'home/home_tab.dart' show StatPill;
import 'settings_screen.dart';

/// The Me tab: its own navigator, so Edit profile, Settings, Help, Privacy
/// and Credits open inside the tab with the bottom bar showing (Figma 06).
class MeTab extends StatelessWidget {
  const MeTab({super.key, required this.userName, required this.photoUrl, required this.onLogout});

  final String userName;
  final String? photoUrl;
  final VoidCallback onLogout;

  static final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  /// Back on the Me tab closes the open page; true when handled.
  static bool handleBack() {
    final nav = _navigator.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return false;
  }

  /// Leaving the tab: back to the Me page.
  static void closePages() {
    _navigator.currentState?.popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    // The pages read the latest name and avatar from [_MeScope] (the
    // navigator builds its first page only once).
    return _MeScope(
      userName: userName,
      photoUrl: photoUrl,
      onLogout: onLogout,
      child: Navigator(
        key: _navigator,
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ),
    );
  }
}

class _MeScope extends InheritedWidget {
  const _MeScope({required this.userName, required this.photoUrl, required this.onLogout, required super.child});

  final String userName;
  final String? photoUrl;
  final VoidCallback onLogout;

  @override
  bool updateShouldNotify(_MeScope old) => old.userName != userName || old.photoUrl != photoUrl;
}

/// The signed-in user's email, or null (also when Firebase isn't set up,
/// as in tests).
String? _email() {
  try {
    return FirebaseAuth.instance.currentUser?.email;
  } catch (_) {
    return null;
  }
}

/// The level the learner is on now (first unlocked, unfinished) and its
/// number, for the "Beginner · Level 1" chip.
(Level, int)? currentLevel(LearningProgress progress) {
  if (!progress.isReady) return null;
  final levels = progress.catalog.levels;
  for (var i = 0; i < levels.length; i++) {
    if (progress.rules.isLevelUnlocked(levels[i]) && !progress.rules.isLevelFinished(levels[i])) {
      return (levels[i], i);
    }
  }
  return levels.isEmpty ? null : (levels.last, levels.length - 1);
}

/// Me (Figma 607:5271): the profile card and the Account rows.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userName, this.photoUrl, this.onLogout, this.email});

  /// For tests; inside [MeTab] these come from the tab.
  final String? userName;
  final String? photoUrl;
  final VoidCallback? onLogout;

  /// For tests; the signed-in user's email when null.
  final String? email;

  ({String userName, String? photoUrl, VoidCallback onLogout}) _data(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_MeScope>();
    return (
      userName: userName ?? scope?.userName ?? AppLocalizations.of(context).meUser,
      photoUrl: photoUrl ?? scope?.photoUrl,
      onLogout: onLogout ?? scope?.onLogout ?? () {},
    );
  }

  Future<void> _openEditProfile(
    BuildContext context,
    String userName,
    String? photoUrl,
    VoidCallback onLogout,
  ) async {
    HapticFeedback.lightImpact();
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentUsername: userName,
          currentPhotoUrl: photoUrl,
          // Delete account: the same way out as Log out (→ Sign Up).
          onAccountDeleted: onLogout,
        ),
      ),
    );
    // Figma 629:6451.
    if (saved == true && context.mounted) showV6Snackbar(context, AppLocalizations.of(context).meProfileUpdated);
  }

  void _open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  /// Figma 608:5645.
  Future<void> _logout(BuildContext context, VoidCallback onLogout) async {
    final t = AppLocalizations.of(context);
    final logOut = t.meLogOut;
    final picked = await showV6ChoiceDialog(
      context,
      mascot: 'firefly_goodbye',
      mascotCircle: V6Colors.coralTonal,
      title: t.meLogOutTitle,
      message: t.meLogOutBody,
      primaryLabel: t.meStay,
      textActions: [logOut],
      dangerActions: {logOut},
    );
    if (picked == logOut) onLogout();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<LearningProgress>();
    final t = AppLocalizations.of(context);
    final (:userName, :photoUrl, :onLogout) = _data(context);
    final level = currentLevel(progress);
    final mail = email ?? _email();
    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: V6Colors.primary,
          onRefresh: progress.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SizedBox(
                height: 64,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(t.meTitle, style: V6Text.headlineLargeTight.copyWith(letterSpacing: -0.28)),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: V6Colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: V6Colors.borderDivider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        V6Avatar(photoUrl: photoUrl, size: 64),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: V6Text.titleLargeBold,
                              ),
                              if (mail != null && mail.isNotEmpty)
                                Text(
                                  mail,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                                ),
                              if (level != null) ...[
                                const SizedBox(height: 6),
                                V6Chip(label: t.homeLevelChip(level.$1.title, level.$2 + 1), tone: V6ChipTone.brand),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: t.meEditProfile,
                            onPressed: () => _openEditProfile(context, userName, photoUrl, onLogout),
                            style: IconButton.styleFrom(backgroundColor: V6Colors.primaryContainer),
                            icon: const Icon(Icons.edit_rounded, color: V6Colors.primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatPill(
                            icon: Icons.local_fire_department_rounded,
                            value: progress.streak,
                            label: t.homeDayStreak,
                            color: V6Colors.coral,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatPill(
                            icon: Icons.menu_book_rounded,
                            value: progress.lessonsCompleted,
                            label: progress.lessonsCompleted == 1 ? t.homeLesson : t.homeLessons,
                            color: V6Colors.lagoon,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatPill(
                            icon: Icons.bolt_rounded,
                            value: progress.xp,
                            label: t.homeXp,
                            color: V6Colors.citrus,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(t.meAccount, style: V6Text.titleMediumBold),
              const SizedBox(height: 12),
              V6ListCard(
                children: [
                  V6ListRow(
                    icon: Icons.person_rounded,
                    title: t.meEditProfile,
                    subtitle: t.meEditProfileSub,
                    onTap: () => _openEditProfile(context, userName, photoUrl, onLogout),
                  ),
                  V6ListRow(
                    icon: Icons.language_rounded,
                    title: t.meLanguageRow,
                    subtitle: AppLanguage.instance.language,
                    onTap: () => _open(context, const LanguageScreen()),
                  ),
                  V6ListRow(
                    icon: Icons.settings_rounded,
                    title: t.meSettings,
                    subtitle: t.meSettingsSub,
                    onTap: () => _open(context, const SettingsScreen()),
                  ),
                  V6ListRow(
                    icon: Icons.help_rounded,
                    title: t.meHelp,
                    subtitle: t.meHelpSub,
                    onTap: () => _open(context, const HelpSupportScreen()),
                  ),
                  V6ListRow(
                    icon: Icons.logout_rounded,
                    title: t.meLogOut,
                    danger: true,
                    trailing: const SizedBox.shrink(),
                    onTap: () => _logout(context, onLogout),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
