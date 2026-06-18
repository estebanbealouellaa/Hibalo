import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

class LessonsSectionBanner extends StatelessWidget {
  final int topicCount;

  const LessonsSectionBanner({super.key, required this.topicCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: heroPurple,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SECTION 1',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Basic Filipino & Hiligaynon',
            style: AppTheme.displayMedium.copyWith(
              color: Colors.white,
              fontSize: 22,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$topicCount topics · Start learning',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
