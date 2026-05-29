import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../theme/app_colors.dart';
import '../models/user_stats.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final int dayStreak;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.dayStreak,
    required this.onLogout,
  });

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: purple900,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── TOP HEADER ─────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(40),
                  ),
                  gradient: LinearGradient(
                    colors: [purple600, purple400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // AVATAR
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
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        '🌱 Beginner',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── REAL-TIME STATS ────────────────────────
              Consumer<UserStats>(
                builder: (context, userStats, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            purple800.withOpacity(0.8),
                            purple800.withOpacity(0.4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: purple600.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            title: '${userStats.streak}',
                            subtitle: 'DAY STREAK',
                            icon: '🔥',
                          ),

                          _buildDivider(),

                          _buildStatCard(
                            title: '${userStats.wordsLearned}',
                            subtitle: 'WORDS',
                            icon: '📚',
                          ),

                          _buildDivider(),

                          _buildStatCard(
                            title: '${userStats.quizzesCompleted}',
                            subtitle: 'QUIZZES',
                            icon: '⚡',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // ── ACCOUNT SECTION ──────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _buildMenuCard(
                      icon: Icons.person,
                      title: 'Edit Profile',
                      subtitle: 'Name, photo, preferences',
                      color: pink500,
                    ),

                    _buildMenuCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Daily reminders, streaks',
                      color: teal300,
                    ),

                    _buildMenuCard(
                      icon: Icons.bar_chart,
                      title: 'Progress Report',
                      subtitle: 'View your learning stats',
                      color: purple400,
                    ),

                    _buildMenuCard(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'FAQ, contact us',
                      color: purple600,
                    ),

                    const SizedBox(height: 20),

                    // ── LOGOUT BUTTON ─────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ── STAT CARD ─────────────────────────────────────
  Widget _buildStatCard({
    required String title,
    required String subtitle,
    required String icon,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),

        const SizedBox(height: 8),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // ── DIVIDER ───────────────────────────────────────
  Widget _buildDivider() {
    return Container(width: 1, height: 60, color: purple600.withOpacity(0.2));
  }

  // ── MENU CARD ─────────────────────────────────────
  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: purple800.withOpacity(0.6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 18,
            color: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
