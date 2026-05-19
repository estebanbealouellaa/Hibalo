import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/app_colors.dart';
import 'camera_translate_screen.dart';
import 'translator_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const HomeScreen({super.key, required this.onLogout});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ── FIX: get the current user once; Firestore stream handles the rest
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      // ── FIX: StreamBuilder listens to Firestore in realtime
      body: StreamBuilder<DocumentSnapshot>(
        stream: _currentUser != null
            ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(_currentUser!.uid)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          // Pull username & streak from the live snapshot
          String userName = 'User';
          int dayStreak = 0;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            userName = data['username'] ?? 'User';
            dayStreak = data['dayStreak'] ?? 0;
          }

          return _buildBody(userName, dayStreak);
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── BODY SWITCHER ────────────────────────────────────────────────
  Widget _buildBody(String userName, int dayStreak) {
    switch (_selectedIndex) {
      case 0:
        return _buildHome(userName, dayStreak);
      case 1:
        return _buildTranslator();
      case 2:
        return _buildLibrary();
      case 3:
        return _buildProfilePage(userName, dayStreak);
      default:
        return _buildHome(userName, dayStreak);
    }
  }

  // ── HOME SCREEN ──────────────────────────────────────────────────
  Widget _buildHome(String userName, int dayStreak) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

                            // ── REALTIME username shown here
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

                      // ── REALTIME avatar initial
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
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

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.local_fire_department,
                          title: '$dayStreak Days',
                          subtitle: 'Current Streak',
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.menu_book,
                          title: '12 Lessons',
                          subtitle: 'Completed',
                        ),
                      ),
                    ],
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
                    onTap: () => setState(() => _selectedIndex = 1),
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
                    onTap: () => setState(() => _selectedIndex = 2),
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

  // ── PROFILE PAGE ─────────────────────────────────────────────────
  Widget _buildProfilePage(String userName, int dayStreak) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [purple600, purple400]),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🌱 Beginner',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildProfileStat(
                            title: '$dayStreak',
                            subtitle: 'DAY STREAK',
                          ),
                        ),

                        Expanded(
                          child: _buildProfileStat(
                            title: '47',
                            subtitle: 'WORDS',
                          ),
                        ),

                        Expanded(
                          child: _buildProfileStat(
                            title: '5',
                            subtitle: 'QUIZZES',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 18),

                  _buildProfileTile(
                    icon: Icons.person,
                    title: 'Edit Profile',
                    subtitle: 'Name, photo, preferences',
                    color: purple600,
                  ),

                  _buildProfileTile(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Daily reminders & streaks',
                    color: Colors.orange,
                  ),

                  _buildProfileTile(
                    icon: Icons.bar_chart,
                    title: 'Progress Report',
                    subtitle: 'View learning statistics',
                    color: Colors.green,
                  ),

                  _buildProfileTile(
                    icon: Icons.help,
                    title: 'Help & Support',
                    subtitle: 'FAQ and support',
                    color: Colors.pink,
                  ),

                  _buildProfileTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    color: Colors.blue,
                  ),

                  _buildProfileTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Sign out account',
                    color: Colors.red,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STAT CARD ────────────────────────────────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.8),
                        fontSize: 12,
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

  // ── ACTION CARD ──────────────────────────────────────────────────
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

  // ── PROFILE STAT ────────────────────────────────────────────────
  Widget _buildProfileStat({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: purple600,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── PROFILE TILE ────────────────────────────────────────────────
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        onTap: onTap,
        leading: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: color.withOpacity(.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  // ── TRANSLATOR ───────────────────────────────────────────────────
  Widget _buildTranslator() {
    return const TranslatorScreen();
  }

  // ── LIBRARY ──────────────────────────────────────────────────────
  Widget _buildLibrary() {
    return const Center(
      child: Text(
        'Library Screen',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ── MAIN BOTTOM NAVIGATION ───────────────────────────────────────
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
          onTap: (index) => setState(() => _selectedIndex = index),
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
