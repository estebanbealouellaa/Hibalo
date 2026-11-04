import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/catalog.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../lesson_image.dart';
import 'part_common.dart';

/// P04 · Words (learn cards). One card per item; the player passes the card
/// [index] and moves it with Back/Next (the segmented bar doesn't move).
/// The picture rule and the Example rule are independent (§3 P04).
class WordsPart extends StatelessWidget {
  const WordsPart({
    super.key,
    required this.data,
    required this.index,
    required this.fallbackPicture,
  });

  final WordsPartData data;

  /// The card shown (0-based).
  final int index;
  final String fallbackPicture;

  @override
  Widget build(BuildContext context) {
    final item = data.items[index.clamp(0, data.items.length - 1)];
    return PartLayout(
      children: [
        _LearnCard(
          // A new key per card, so the picture swaps cleanly.
          key: ValueKey(item.id),
          item: item,
          position: index + 1,
          count: data.items.length,
          fallbackPicture: fallbackPicture,
        ),
        if (item.example != null) ...[
          const SizedBox(height: 10),
          _ExampleBox(item.example!),
        ],
      ],
    );
  }
}

class _LearnCard extends StatelessWidget {
  const _LearnCard({
    super.key,
    required this.item,
    required this.position,
    required this.count,
    required this.fallbackPicture,
  });

  final LessonItem item;
  final int position;
  final int count;
  final String fallbackPicture;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Figma "Word card": padding 20, radius 24, 12 between items, centred.
    return PartCard(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SmallChip(t.newWordChip),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$position / $count',
                  style: V6Text.labelMediumBold.copyWith(color: V6Colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 295 / 140,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: LessonImage(
                path: item.image,
                fallback: fallbackPicture,
                fallbackColor: V6Colors.primaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(t.hiligaynonLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.glowText)),
          const SizedBox(height: 12),
          Text(item.hil, textAlign: TextAlign.center, style: V6Text.headlineXl),
          const SizedBox(height: 12),
          Text(
            item.fil,
            textAlign: TextAlign.center,
            style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
          ),
          if (item.alt != null) ...[
            const SizedBox(height: 12),
            Text(
              t.alsoSaid(item.alt!),
              textAlign: TextAlign.center,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
            ),
          ],
          // Both buttons play the same clip (slow = 0.75×). Always shown;
          // a clip that isn't recorded yet plays nothing.
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AudioButton(clip: item.audio, label: t.playAudio),
              const SizedBox(width: 16),
              AudioButton(
                clip: item.audio,
                label: t.playSlow,
                slow: true,
                size: 48,
                background: V6Colors.primaryContainer,
                foreground: V6Colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The green Example box: text only, no audio.
class _ExampleBox extends StatelessWidget {
  const _ExampleBox(this.example);

  final HilFil example;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: V6Colors.lagoonContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.exampleLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.lagoonText)),
          const SizedBox(height: 2),
          Text(example.hil, style: V6Text.bodyLargeSemiBold),
          const SizedBox(height: 2),
          Text(example.fil, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
        ],
      ),
    );
  }
}
