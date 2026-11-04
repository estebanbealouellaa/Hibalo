import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../markup_text.dart';
import 'part_common.dart';

/// P09 · Filipino bridge & mistakes: a bullet card with a pink left bar,
/// then "Common mistakes" (wrong struck through in red, right in green, why
/// in grey). No audio.
class BridgeMistakesPart extends StatelessWidget {
  const BridgeMistakesPart({super.key, required this.data});

  final BridgeMistakesPartData data;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 12),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: V6Colors.coral),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final point in data.bridge)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(top: 8, right: 10),
                                  decoration: const BoxDecoration(
                                    color: V6Colors.coral,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(child: MarkupText(point, style: V6Text.bodyMedium)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (data.mistakes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              const IconTile(icon: Icons.error_outline_rounded),
              const SizedBox(width: 12),
              Expanded(child: Text(t.commonMistakes, style: V6Text.titleLargeBold)),
            ],
          ),
          const SizedBox(height: 12),
          PartCard(
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

class _MistakeRow extends StatelessWidget {
  const _MistakeRow(this.mistake);

  final Mistake mistake;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.close_rounded, color: V6Colors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mistake.wrong,
                  style: V6Text.bodyLarge.copyWith(
                    color: V6Colors.error,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: V6Colors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: V6Colors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  mistake.right,
                  style: V6Text.bodyLargeBold.copyWith(color: V6Colors.success),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(mistake.why, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        ],
      ),
    );
  }
}
