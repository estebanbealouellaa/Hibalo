import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Lessons screen badge: red streak + green lesson count (Figma 204:3375).
class HibaloLessonStatsBadge extends StatelessWidget {
  final int streak;
  final int lessonsCompleted;

  const HibaloLessonStatsBadge({
    super.key,
    required this.streak,
    required this.lessonsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
      decoration: BoxDecoration(
        color: purplePale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_outlined,
            size: 16,
            color: streakRed,
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: AppTheme.badgeText.copyWith(color: ink, fontSize: 12),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.menu_book_outlined, size: 14, color: lessonGreen),
          const SizedBox(width: 6),
          Text(
            '$lessonsCompleted',
            style: AppTheme.badgeText.copyWith(color: ink, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Figma-aligned screen header row (title + streak/lesson badge).
class LessonsHeader extends StatelessWidget {
  final String title;
  final int streak;
  final int lessonsCompleted;
  final bool showBack;

  const LessonsHeader({
    super.key,
    this.title = 'Lessons',
    required this.streak,
    required this.lessonsCompleted,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && Navigator.canPop(context);

    return Row(
      children: [
        if (canPop)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: ink,
                size: 18,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        Text(title, style: AppTheme.screenTitle),
        const Spacer(),
        HibaloLessonStatsBadge(
          streak: streak,
          lessonsCompleted: lessonsCompleted,
        ),
      ],
    );
  }
}
