import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P13 Idiom cards (Figma "P13 · Part · Idiom card · Default / Careful / Long card"): one card at a time,
/// "n / N" in the card, Back/Next move [index] like P04 (the segmented bar doesn't move). No title.
class IdiomCardsPart extends StatelessWidget {
  const IdiomCardsPart({super.key, required this.data, required this.index});

  final IdiomCardsPartData data;

  /// The card shown (0-based).
  final int index;

  @override
  Widget build(BuildContext context) {
    final card = data.cards[index.clamp(0, data.cards.length - 1)];
    return PartLayout(
      children: [
        _Card(key: ValueKey(card.id), card: card, position: index + 1, count: data.cards.length),
        const SizedBox(height: 10),
        _Example(card: card),
      ],
    );
  }
}

/// Figma "Word card": white, radius 24, padding 20, 12 between rows.
class _Card extends StatelessWidget {
  const _Card({super.key, required this.card, required this.position, required this.count});

  final IdiomCard card;
  final int position;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget field(String label, Widget value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
            const SizedBox(height: 2),
            value,
          ],
        );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Text('$position / $count', style: V6Text.labelMediumBold.copyWith(color: V6Colors.textSecondary)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(card.hil, style: V6Text.hilResultExtraBoldItalic.copyWith(color: V6Colors.primary)),
              ),
              // Hidden until the clip is recorded.
              if (card.audio != null) ...[
                const SizedBox(width: 12),
                AudioButton(clip: card.audio, label: t.playAudio, size: 48, iconSize: 24),
              ],
            ],
          ),
          const SizedBox(height: 12),
          field(t.idiomLiteral, Text(card.literal, style: V6Text.bodyLarge)),
          const SizedBox(height: 12),
          field(t.idiomMeans, Text(card.means, style: V6Text.bodyLargeSemiBold)),
          const SizedBox(height: 12),
          field(
            t.idiomTone,
            // Figma "Chip · Warning" for idioms that need care; lagoon otherwise.
            card.careful
                ? SmallChip(card.tone, background: V6Colors.warningContainer, foreground: V6Colors.warning)
                : SmallChip(card.tone, background: V6Colors.lagoonContainer, foreground: V6Colors.lagoonText),
          ),
          const SizedBox(height: 12),
          field(t.idiomSayTo, Text(card.sayTo, style: V6Text.bodyLarge)),
          if (card.warning case final warning?) ...[
            const SizedBox(height: 12),
            // Figma "Feedback Banner" · Warning: 20 px icon + one sentence.
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: V6Colors.warningContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 20, color: V6Colors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(warning, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Figma "Example": lagoon, radius 16, padding 16/12; Hiligaynon lines, then the Filipino lines.
class _Example extends StatelessWidget {
  const _Example({required this.card});

  final IdiomCard card;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: V6Colors.lagoonContainer, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.exampleLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.lagoonText)),
          const SizedBox(height: 2),
          for (final line in card.exampleHil) Text(line, style: V6Text.bodyLargeSemiBold),
          const SizedBox(height: 2),
          for (final line in card.exampleFil)
            Text(line, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
        ],
      ),
    );
  }
}
