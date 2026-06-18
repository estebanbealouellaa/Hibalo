import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../models/user_stats.dart';
import '../widgets/home/home_bottom_nav.dart';
import '../widgets/home/home_discover_section.dart';
import '../widgets/home/home_hero_section.dart';
import '../widgets/home/home_layout.dart';
import '../widgets/home/home_search_bar.dart';
import 'camera_translate_screen.dart';
import 'translator_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'voice_translate_screen.dart';

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

  void _openTranslator() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TranslatorScreen()),
    );
  }

  void _openLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LibraryScreen()),
    );
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
          int lessonsCompleted = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['username'] ?? 'User';
            photoUrl = data['photoUrl'] as String?;
            dayStreak = data['dayStreak'] ?? 0;
            lessonsCompleted = data['lessonsCompleted'] ?? 0;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              final userStats = context.read<UserStats>();
              userStats.initializeFromFirestore(
                xp: data['xp'] ?? 0,
                streak: dayStreak,
                wordsLearned: data['wordsLearned'] ?? 0,
                quizzesCompleted: data['quizzesCompleted'] ?? 0,
                lessonsCompleted: lessonsCompleted,
              );
            });
          }

          photoUrl ??= _currentUser?.photoURL;

          return _buildBody(
            userName: userName,
            dayStreak: dayStreak,
            lessonsCompleted: lessonsCompleted,
            photoUrl: photoUrl,
          );
        },
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildBody({
    required String userName,
    required int dayStreak,
    required int lessonsCompleted,
    required String? photoUrl,
  }) {
    switch (_selectedIndex) {
      case 1:
        return ProfileScreen(
          userName: userName,
          dayStreak: dayStreak,
          onLogout: _logout,
        );
      case 0:
      default:
        return _buildHomeTab(
          userName: userName,
          dayStreak: dayStreak,
          lessonsCompleted: lessonsCompleted,
          photoUrl: photoUrl,
        );
    }
  }

  Widget _buildHomeTab({
    required String userName,
    required int dayStreak,
    required int lessonsCompleted,
    required String? photoUrl,
  }) {
    final layout = HomeLayout.of(context);

    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: layout.heroHeight,
            child: Consumer<UserStats>(
              builder: (context, stats, _) {
                return HomeHeroSection(
                  userName: userName,
                  streak: stats.streak > 0 ? stats.streak : dayStreak,
                  lessonsCompleted: stats.lessonsCompleted > 0
                      ? stats.lessonsCompleted
                      : lessonsCompleted,
                  photoUrl: photoUrl,
                );
              },
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(height: layout.heroHeight - layout.sheetOverlap),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(layout.sheetTopRadius),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          layout.horizontalPadding,
                          24,
                          layout.horizontalPadding,
                          0,
                        ),
                        child: HomeSearchBar(onTap: _openLibrary),
                      ),
                      const SizedBox(height: 24),
                      HomeDiscoverSection(
                        onTranslateTap: _openTranslator,
                        onCameraTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CameraTranslateScreen(),
                            ),
                          );
                        },
                        onLessonsTap: _openLibrary,
                        onVoiceTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VoiceTranslateScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: layout.bottomNavClearance),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
