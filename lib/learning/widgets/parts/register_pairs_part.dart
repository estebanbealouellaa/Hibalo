import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../markup_text.dart';
import 'part_common.dart';

/// P14 Formal vs casual (Figma "P14 · Part · Formal vs casual" + Wrong on purpose / Long text): one situation
/// per step ([index]; the player shows "n / N" by the caption). Header = the situation title, then the part
/// title (what kind of pair it is), the two cards and the "What changed" chips. No audio.
class RegisterPairsPart extends StatelessWidget {
  const RegisterPairsPart({super.key, required this.data, required this.index});

  final RegisterPairsPartData data;

  /// The situation shown (0-based).
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final situation = data.situations[index.clamp(0, data.situations.length - 1)];
    return PartLayout(
      children: [
        // Figma: 14 between blocks.
        PartHeader(icon: data.icon, title: situation.title),
        const SizedBox(height: 14),
        Text(data.title, style: V6Text.bodyLarge),
        const SizedBox(height: 14),
        data.leftWrongOnPurpose
            ? _WrongCard(label: data.leftLabel, side: situation.left)
            : _SideCard(label: data.leftLabel, side: situation.left),
        const SizedBox(height: 14),
        _SideCard(label: data.rightLabel, side: situation.right),
        if (situation.changes.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(t.registerChanged, style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final change in situation.changes)
                SmallChip(change, background: V6Colors.lagoonContainer, foreground: V6Colors.onPrimaryContainer),
            ],
          ),
        ],
      ],
    );
  }
}

/// Figma "Natural Hiligaynon card": white, radius 20, padding 16/14, a Brand chip, the line in italic violet.
class _SideCard extends StatelessWidget {
  const _SideCard({required this.label, required this.side});

  final String label;
  final RegisterSide side;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallChip(label, background: V6Colors.primaryContainer, foreground: V6Colors.onPrimaryContainer),
          const SizedBox(height: 8),
          Text(side.hil, style: V6Text.bodyLargeSemiBoldItalic.copyWith(color: V6Colors.primary)),
          if (side.fil case final fil?) ...[
            const SizedBox(height: 2),
            Text(fil, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Figma "Wrong on purpose card": grey, Border/Neutral, ✗ + the label, the line in Neutral Strong,
/// and the note (with *markup*) in small text instead of the Filipino.
class _WrongCard extends StatelessWidget {
  const _WrongCard({required this.label, required this.side});

  final String label;
  final RegisterSide side;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: V6Colors.neutralBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.close_rounded, size: 20, color: V6Colors.error),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label, style: V6Text.labelMediumBold.copyWith(color: V6Colors.textNeutralStrong)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(side.hil, style: V6Text.bodyLargeSemiBold.copyWith(color: V6Colors.textNeutralStrong)),
          if (side.note case final note?) ...[
            const SizedBox(height: 2),
            MarkupText(
              note,
              style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
              exampleColor: V6Colors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }
}
