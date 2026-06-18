import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'home_feature_card.dart';
import 'home_layout.dart';

class HomeDiscoverSection extends StatelessWidget {
  final VoidCallback onTranslateTap;
  final VoidCallback onCameraTap;
  final VoidCallback onLessonsTap;
  final VoidCallback onVoiceTap;

  const HomeDiscoverSection({
    super.key,
    required this.onTranslateTap,
    required this.onCameraTap,
    required this.onLessonsTap,
    required this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = HomeLayout.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: layout.horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discover', style: AppTheme.displayMedium.copyWith(fontSize: 20)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - layout.gridGap) / 2;
              final cardHeight = cardWidth / layout.cardAspectRatio;

              return Wrap(
                spacing: layout.gridGap,
                runSpacing: layout.gridGap,
                children: [
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: HomeFeatureCard(
                      title: 'Translate',
                      subtitle: 'Hil ↔ Filipino',
                      icon: Icons.translate_rounded,
                      backgroundColor: qaTranslate,
                      imageAsset: 'assets/Translate.png',
                      imageSize: 138,
                      imageRight: -8,
                      imageTop: 32,
                      imageScale: 1.12,
                      onTap: onTranslateTap,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: HomeFeatureCard(
                      title: 'Camera',
                      subtitle: 'Scan & Translate',
                      icon: Icons.camera_alt_rounded,
                      backgroundColor: qaCamera,
                      imageAsset: 'assets/Picture.png',
                      imageSize: 117,
                      imageRight: -6,
                      imageTop: 50,
                      imageRotation: -0.33,
                      imageScale: 1.12,
                      onTap: onCameraTap,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: HomeFeatureCard(
                      title: 'Lessons',
                      subtitle: 'Browse Topics',
                      icon: Icons.auto_stories_rounded,
                      backgroundColor: qaLessons,
                      imageAsset: 'assets/Book.png',
                      imageSize: 128,
                      imageRight: -12,
                      imageTop: 28,
                      imageScale: 1.12,
                      onTap: onLessonsTap,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: HomeFeatureCard(
                      title: 'Voice',
                      subtitle: 'Speak & Translate',
                      icon: Icons.mic_rounded,
                      backgroundColor: qaVoice,
                      imageAsset: 'assets/Voice.png',
                      imageSize: 119,
                      imageRight: -4,
                      imageTop: 40,
                      imageScale: 1.12,
                      onTap: onVoiceTap,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
