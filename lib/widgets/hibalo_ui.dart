import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Design-reference hero gradient (~161deg #6E54AD → #A491C9).
const LinearGradient hibaloHeroGradient = LinearGradient(
  begin: Alignment(-0.9, -1),
  end: Alignment(0.9, 1),
  colors: [purple, purpleMid],
);

/// Profile hero gradient (~174deg).
const LinearGradient hibaloProfileHeroGradient = LinearGradient(
  begin: Alignment(-0.2, -1),
  end: Alignment(0.8, 1.2),
  colors: [purple, purpleMid],
);

class HibaloStatsBadge extends StatelessWidget {
  final int streak;
  final int xp;

  const HibaloStatsBadge({
    super.key,
    required this.streak,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: purplePale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMid),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_outlined,
              size: 13, color: streakRed),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: AppTheme.badgeText,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.bolt, size: 13, color: purple),
          const SizedBox(width: 4),
          Text('$xp', style: AppTheme.badgeText),
        ],
      ),
    );
  }
}

class HibaloScreenHeader extends StatelessWidget {
  final String title;
  final int streak;
  final int xp;

  const HibaloScreenHeader({
    super.key,
    required this.title,
    this.streak = 0,
    this.xp = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.screenTitle),
          HibaloStatsBadge(streak: streak, xp: xp),
        ],
      ),
    );
  }
}

class HibaloXpPill extends StatelessWidget {
  const HibaloXpPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: purplePale,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderMid),
      ),
      child: Text(
        '+20 XP',
        style: AppTheme.badgeText.copyWith(fontSize: 10),
      ),
    );
  }
}
