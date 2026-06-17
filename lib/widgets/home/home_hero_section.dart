import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../admin_entry_button.dart';
import 'home_stat_card.dart';

class HomeHeroSection extends StatelessWidget {
  final String userName;
  final int streak;
  final int lessonsCompleted;
  final String? photoUrl;

  const HomeHeroSection({
    super.key,
    required this.userName,
    required this.streak,
    required this.lessonsCompleted,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: heroPurple,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                        color: Colors.white.withValues(alpha: 0.8),
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
                  _ProfileAvatar(photoUrl: photoUrl),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: HomeStatCard(
                  icon: Icons.local_fire_department_outlined,
                  iconColor: streakRed,
                  value: '$streak',
                  label: 'Streak',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: HomeStatCard(
                  icon: Icons.menu_book_outlined,
                  iconColor: lessonGreen,
                  value: '$lessonsCompleted',
                  label: 'Lesson',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;

  const _ProfileAvatar({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/Account.png');

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? Image.network(
                photoUrl!,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image(
                  image: fallback,
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              )
            : Image(
                image: fallback,
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
