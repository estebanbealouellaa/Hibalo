import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/user_stats.dart';
import '../widgets/admin_entry_button.dart';
import '../widgets/hibalo_ui.dart';
import 'camera_translate_screen.dart';
import 'translator_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'voice_translate_screen.dart'; // ← new

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _currentUser != null
            ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          String userName = 'User';
          String? photoUrl;
          int dayStreak = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['username'] ?? 'User';
            photoUrl = data['photoUrl'] as String?;
            dayStreak = data['dayStreak'] ?? 0;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final userStats = context.read<UserStats>();
              userStats.initializeFromFirestore(
                xp: data['xp'] ?? 0,
                streak: dayStreak,
                wordsLearned: data['wordsLearned'] ?? 0,
                quizzesCompleted: data['quizzesCompleted'] ?? 0,
                lessonsCompleted: data['lessonsCompleted'] ?? 0,
              );
            });
          }

          photoUrl ??= _currentUser?.photoURL;
          return _buildBody(userName, dayStreak, photoUrl);
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody(String userName, int dayStreak, String? photoUrl) {
    switch (_selectedIndex) {
      case 0:
        return _buildHome(userName, dayStreak, photoUrl);
      case 1:
        return _buildTranslator();
      case 2:
        return _buildLibrary();
      case 3:
        return ProfileScreen(
          userName: userName,
          dayStreak: dayStreak,
          onLogout: _logout,
        );
      default:
        return _buildHome(userName, dayStreak, photoUrl);
    }
  }

  Widget _buildHome(String userName, int dayStreak, String? photoUrl) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HERO ─────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
                    decoration: const BoxDecoration(
                      gradient: hibaloHeroGradient,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: AppTheme.displayLarge.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Continue learning today!',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const AdminEntryButton(),
                                const SizedBox(height: 6),
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
                                  child: ClipOval(
                                    child: _buildProfileAvatar(photoUrl),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Consumer<UserStats>(
                          builder: (context, userStats, _) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildHeroStatCard(
                                    icon: Icons.local_fire_department_outlined,
                                    value: '${userStats.streak}',
                                    label: 'CURRENT STREAK',
                                  ),
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: _buildHeroStatCard(
                                    icon: Icons.menu_book_outlined,
                                    value: '${userStats.lessonsCompleted}',
                                    label: 'LESSONS DONE',
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: -50,
                    top: -50,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 20,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── QUICK ACTIONS ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 164.5 / 150,
                children: [
                  _buildActionCard(
                    title: 'Translate',
                    subtitle: 'Hil ↔ Filipino',
                    icon: Icons.translate_rounded,
                    imageAsset: 'assets/Translate.png',
                    gradient: const [purple, purple],
                    imageSize: 138,
                    imageRight: -8,
                    imageTop: 8,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _buildActionCard(
                    title: 'Camera',
                    subtitle: 'Scan & Translate',
                    icon: Icons.camera_alt_rounded,
                    imageAsset: 'assets/Picture.png',
                    gradient: const [qaCameraStart, purpleMid],
                    imageSize: 117,
                    imageRight: -6,
                    imageTop: 28,
                    imageRotation: -0.33,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CameraTranslateScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Library',
                    subtitle: 'Browse Topics',
                    icon: Icons.auto_stories_rounded,
                    imageAsset: 'assets/Book.png',
                    gradient: const [qaLibraryStart, qaLibraryEnd],
                    imageSize: 128,
                    imageRight: -12,
                    imageTop: 6,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  // ── DAILY QUIZ → Voice Translate ──────────
                  _buildActionCard(
                    title: 'Voice',
                    subtitle: 'Speak & Translate',
                    icon: Icons.mic_rounded,
                    imageAsset: 'assets/Voice.png',
                    gradient: const [qaQuizStart, qaQuizEnd],
                    imageSize: 119,
                    imageRight: -4,
                    imageTop: 18,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VoiceTranslateScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? photoUrl) {
    const fallback = AssetImage('assets/Account.png');
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        width: 58,
        height: 58,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image(image: fallback, width: 58, height: 58, fit: BoxFit.cover),
      );
    }
    return Image(image: fallback, width: 58, height: 58, fit: BoxFit.cover);
  }

  Widget _buildHeroStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      height: 57,
      padding: const EdgeInsets.only(left: 8, right: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 51,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: purple, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.displaySmall.copyWith(
                    color: ink,
                    fontSize: 19,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: inkMuted,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String imageAsset,
    required List<Color> gradient,
    required VoidCallback onTap,
    double imageSize = 120,
    double imageRight = 0,
    double imageTop = 12,
    double imageRotation = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.5, -1),
                  end: const Alignment(1, 1),
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            Positioned(
              right: -24,
              top: -18,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: imageRight,
              top: imageTop,
              child: Transform.rotate(
                angle: imageRotation,
                child: Opacity(
                  opacity: 0.45,
                  child: Image.asset(
                    imageAsset,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslator() => const TranslatorScreen();

  Widget _buildLibrary() => const LibraryScreen();

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, Icons.home_outlined, 'Home'),
      (Icons.translate_rounded, Icons.g_translate_rounded, 'Translate'),
      (Icons.menu_book_rounded, Icons.menu_book_outlined, 'Library'),
      (Icons.person_rounded, Icons.person_outline_rounded, 'Me'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: white,
        border: Border(top: BorderSide(color: borderLight)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (index) {
            final active = _selectedIndex == index;
            final item = items[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? purplePale : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? item.$1 : item.$2,
                        size: 20,
                        color: active ? purple : inkMuted,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? purple : inkMuted,
                          fontWeight: active
                              ? FontWeight.w500
                              : FontWeight.w400,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
