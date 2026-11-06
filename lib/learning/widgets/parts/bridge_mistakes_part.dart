import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/part_icons.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../markup_text.dart';
import 'part_common.dart';

/// P09 Filipino bridge & mistakes (Figma "P09 · Part · Filipino bridge & mistakes"); no audio.
class BridgeMistakesPart extends StatelessWidget {
  const BridgeMistakesPart({super.key, required this.data});

  final BridgeMistakesPartData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        _SectionTitle(icon: partIcon(data.icon), title: data.title),
        const SizedBox(height: 14),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 5, color: V6Colors.tilePink),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < data.bridge.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: V6Colors.tilePink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: MarkupText(data.bridge[i], style: V6Text.bodyMedium)),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (data.mistakes.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle(icon: Icons.error_outline_rounded, title: t.commonMistakes),
          const SizedBox(height: 14),
          PartCard(
            radius: 18,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < data.mistakes.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _MistakeRow(data.mistakes[i]),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// 40 px icon tile + title (Figma "Section title").
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: V6Colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 22, color: V6Colors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: V6Text.titleLargeBold)),
      ],
    );
  }
}

class _MistakeRow extends StatelessWidget {
  const _MistakeRow(this.mistake);

  final Mistake mistake;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.close_rounded, color: V6Colors.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mistake.wrong,
                  style: V6Text.bodyLargeMedium.copyWith(
                    color: V6Colors.error,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: V6Colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: V6Colors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mistake.right,
                  style: V6Text.bodyLargeBold.copyWith(color: V6Colors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(mistake.why, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        ],
      ),
    );
  }
}
