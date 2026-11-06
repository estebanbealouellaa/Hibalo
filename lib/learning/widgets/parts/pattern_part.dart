import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P03 Pattern: slot blocks joined by "+", then "= Filipino"; the link word is violet with a glow. No audio.
class PatternPart extends StatelessWidget {
  const PatternPart({super.key, required this.data});

  final PatternPartData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        // Figma "P03 · Part · Pattern": 14 between blocks, cards radius 20.
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 14),
        PartText(data.text),
        const SizedBox(height: 14),
        PartCard(
          radius: 20,
          child: Column(
            children: [
              // Shrinks to fit when four long slots don't fit the width.
              FittedBox(fit: BoxFit.scaleDown, child: _slots()),
              const SizedBox(height: 12),
              Text(
                '= ${data.fil}',
                textAlign: TextAlign.center,
                style: V6Text.bodyLargeSemiBold.copyWith(color: V6Colors.textSecondary),
              ),
            ],
          ),
        ),
        if (data.examples.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(t.moreExamples, style: V6Text.titleMediumBold),
          const SizedBox(height: 14),
          PartCard(
            radius: 20,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.examples.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          data.examples[i].hil,
                          style: V6Text.bodyLargeSemiBoldItalic.copyWith(color: V6Colors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.examples[i].fil,
                          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _slots() {
    var plain = 0; // counts the non-highlighted slots, for the colour swap
    final blocks = <Widget>[];
    for (var i = 0; i < data.slots.length; i++) {
      final slot = data.slots[i];
      if (i > 0) {
        // "+" between blocks, level with the blocks (row is bottom-aligned).
        blocks.add(Padding(
          padding: const EdgeInsets.only(bottom: 11),
          child: Text('+', style: V6Text.titleLarge.copyWith(color: V6Colors.textSecondary)),
        ));
      }
      // Figma "Block": the link word is violet with a 3 px glow border; the others alternate citrus and lagoon.
      final (Color background, Color foreground) = slot.highlight
          ? (V6Colors.primary, V6Colors.onPrimary)
          : (plain++).isEven
              ? (V6Colors.citrus, V6Colors.textPrimary)
              : (V6Colors.lagoon, V6Colors.textPrimary);
      blocks.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (slot.label.isNotEmpty)
            Text(slot.label, style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
          if (slot.label.isNotEmpty) const SizedBox(height: 6),
          Container(
            // Figma's glow stroke sits inside the block, so the highlighted
            // block keeps the same size: its padding loses the 3 px border.
            padding: slot.highlight
                ? const EdgeInsets.symmetric(horizontal: 13, vertical: 9)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: slot.highlight ? Border.all(color: V6Colors.glow, width: 3) : null,
            ),
            child: Text(slot.hil, style: V6Text.hilWordBold.copyWith(color: foreground)),
          ),
        ],
      ));
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          blocks[i],
        ],
      ],
    );
  }
}
