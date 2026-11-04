import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P03 · Pattern: icon + title, the explanation, the pattern card (3 or 4
/// slot blocks joined by "+", then "= Filipino") and "More examples".
/// The highlighted slot (the link word) is violet with a glow; the others
/// alternate citrus and lagoon. No audio.
class PatternPart extends StatelessWidget {
  const PatternPart({super.key, required this.data});

  final PatternPartData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 16),
        PartText(data.text),
        const SizedBox(height: 16),
        PartCard(
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
          const SizedBox(height: 20),
          Text(t.moreExamples, style: V6Text.titleMediumBold),
          const SizedBox(height: 10),
          PartCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.examples.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          data.examples[i].hil,
                          style: V6Text.bodyLargeSemiBoldItalic.copyWith(color: V6Colors.primary),
                        ),
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
        blocks.add(Padding(
          padding: const EdgeInsets.fromLTRB(6, 18, 6, 0),
          child: Text('+', style: V6Text.titleMediumBold.copyWith(color: V6Colors.textSecondary)),
        ));
      }
      final (Color background, Color foreground) = slot.highlight
          ? (V6Colors.primary, V6Colors.onPrimary)
          : (plain++).isEven
              ? (V6Colors.citrus, V6Colors.onCitrus)
              : (V6Colors.lagoon, V6Colors.primaryStrong);
      blocks.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 18,
            child: Text(slot.label, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
          ),
          const SizedBox(height: 4),
          Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
              border: slot.highlight ? Border.all(color: V6Colors.glow, width: 2) : null,
              boxShadow: slot.highlight
                  ? [BoxShadow(color: V6Colors.glow.withValues(alpha: 0.6), blurRadius: 10)]
                  : null,
            ),
            child: Text(slot.hil, style: V6Text.titleMediumBold.copyWith(color: foreground)),
          ),
        ],
      ));
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }
}
