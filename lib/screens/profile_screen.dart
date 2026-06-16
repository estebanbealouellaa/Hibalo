import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/hibalo_ui.dart';
import '../models/user_stats.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final int dayStreak;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.dayStreak,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _displayName;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _displayName = user?.displayName ?? widget.userName;
    _photoUrl = user?.photoURL;
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
  }

  void _openEditProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentUsername: _displayName,
          currentPhotoUrl: _photoUrl,
          onSaved: (newUsername, newPhotoUrl) {
            setState(() {
              _displayName = newUsername;
              _photoUrl = newPhotoUrl;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // ── HERO ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                decoration: const BoxDecoration(
                  gradient: hibaloProfileHeroGradient,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(child: _avatarWidget()),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName,
                            style: AppTheme.displayMedium.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Beginner',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── STATS ROW (overlapping) ──────────────────
              Transform.translate(
                offset: const Offset(0, -16),
                child: Consumer<UserStats>(
                  builder: (context, userStats, _) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 18),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: purple.withOpacity(0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildStatItem(
                            Icons.local_fire_department_outlined,
                            '${userStats.streak}',
                            'Day Streak',
                          ),
                          _buildStatDivider(),
                          _buildStatItem(
                            Icons.menu_book_outlined,
                            '${userStats.wordsLearned}',
                            'Words',
                          ),
                          _buildStatDivider(),
                          _buildStatItem(
                            Icons.quiz_outlined,
                            '${userStats.quizzesCompleted}',
                            'Quizzes',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ── MENU ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, bottom: 10),
                      child: Text('MY ACCOUNT', style: AppTheme.labelCaps),
                    ),
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      subtitle: 'Name, photo, preferences',
                      onTap: _openEditProfile,
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQ, contact us',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: logoutRed, width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: logoutRed,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: AppTheme.bodyLarge.copyWith(
                                color: logoutRed,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarWidget() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(
        _photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialAvatar(),
      );
    }
    return _initialAvatar();
  }

  Widget _initialAvatar() {
    return Image.asset(
      'assets/Account.png',
      width: 58,
      height: 58,
      fit: BoxFit.cover,
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: purple),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTheme.displaySmall.copyWith(fontSize: 19, color: ink),
          ),
          Text(
            label.toUpperCase(),
            style: AppTheme.labelCaps.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: borderLight);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: purplePale,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: purple, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.bodyMedium.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: purpleMid, size: 18),
          ],
        ),
      ),
    );
  }
}
