import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../models/user_stats.dart';
import '../widgets/admin_entry_button.dart';
import 'camera_translate_screen.dart';
import 'translator_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

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
      backgroundColor: const Color(0xFFF6F7FB),

      body: StreamBuilder<DocumentSnapshot>(
        stream: _currentUser != null
            ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .snapshots()
            : null,

        builder: (context, snapshot) {
          String userName = 'User';
          int dayStreak = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;

            userName = data['username'] ?? 'User';
            dayStreak = data['dayStreak'] ?? 0;

            // ── INITIALIZE USER STATS ─────────────────
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

          return _buildBody(userName, dayStreak);
        },
      ),

      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── BODY SWITCHER ──────────────────────────────────
  Widget _buildBody(String userName, int dayStreak) {
    switch (_selectedIndex) {
      case 0:
        return _buildHome(userName, dayStreak);

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
        return _buildHome(userName, dayStreak);
    }
  }

  // ── HOME SCREEN ────────────────────────────────────
  Widget _buildHome(String userName, int dayStreak) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ── HEADER CARD WITH ADMIN BUTTON ──────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),

                gradient: LinearGradient(
                  colors: [purple600, purple400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                boxShadow: [
                  BoxShadow(
                    color: purple600.withOpacity(.3),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              'Welcome back 👋',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Continue learning today!',
                              style: TextStyle(
                                color: Colors.white.withOpacity(.9),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── AVATAR + ADMIN BUTTON COLUMN ───
                      Column(
                        children: [
                          // Admin shield — only visible for admins
                          const AdminEntryButton(),

                          Container(
                            width: 70,
                            height: 70,

                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white70,
                                width: 2,
                              ),
                            ),

                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : 'U',

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ── USER STATS ───────────────────────
                  Consumer<UserStats>(
                    builder: (context, userStats, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.local_fire_department,
                              title: '${userStats.streak} Days',
                              subtitle: 'Current Streak',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.menu_book,
                              title: '${userStats.lessonsCompleted} Lessons',
                              subtitle: 'Completed',
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),

              child: Text(
                'Quick Actions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                shrinkWrap: true,

                physics: const NeverScrollableScrollPhysics(),

                children: [
                  _buildActionCard(
                    title: 'Translate',
                    subtitle: 'Hil ↔ Filipino',
                    icon: Icons.translate_rounded,
                    color: purple600,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                  ),

                  _buildActionCard(
                    title: 'Camera',
                    subtitle: 'Scan & Translate',
                    icon: Icons.camera_alt_rounded,
                    color: teal300,

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
                    icon: Icons.auto_stories,
                    color: pink500,

                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),

                  _buildActionCard(
                    title: 'Daily Quiz',
                    subtitle: 'Practice Today',
                    icon: Icons.bolt,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STAT CARD ──────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: purple600, size: 32),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ── ACTION CARD ────────────────────────────────────
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(.8)]),

          borderRadius: BorderRadius.circular(28),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 55,
              height: 55,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.2),

                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(icon, color: Colors.white, size: 28),
            ),

            const Spacer(),

            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              subtitle,
              style: TextStyle(color: Colors.white.withOpacity(.9)),
            ),
          ],
        ),
      ),
    );
  }

  // ── TRANSLATOR ─────────────────────────────────────
  Widget _buildTranslator() {
    return const TranslatorScreen();
  }

  // ── LIBRARY ────────────────────────────────────────
  Widget _buildLibrary() {
    return const LibraryScreen();
  }

  // ── BOTTOM NAVIGATION ──────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),

        child: BottomNavigationBar(
          currentIndex: _selectedIndex,

          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedItemColor: purple600,
          unselectedItemColor: Colors.grey.shade500,

          items: [
            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 1
                    ? Icons.translate
                    : Icons.g_translate_outlined,
              ),
              label: 'Translate',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 2
                    ? Icons.library_books
                    : Icons.library_books_outlined,
              ),
              label: 'Library',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == 3 ? Icons.person : Icons.person_outline,
              ),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
