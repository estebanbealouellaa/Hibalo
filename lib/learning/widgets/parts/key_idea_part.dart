import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P01 · Key idea: icon + title, the explanation, and optional term cards
/// (Hiligaynon word, NOTE row, FILIPINO row). No audio.
class KeyIdeaPart extends StatelessWidget {
  const KeyIdeaPart({super.key, required this.data});

  final KeyIdeaPartData data;

  @override
  Widget build(BuildContext context) {
    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 14),
        PartText(data.text),
        if (data.terms.isNotEmpty) const SizedBox(height: 14),
        for (var i = 0; i < data.terms.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _TermCard(data.terms[i]),
        ],
      ],
    );
  }
}

class _TermCard extends StatelessWidget {
  const _TermCard(this.term);

  final Term term;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Figma "Term" card: padding 16/14, radius 18, 8 between rows.
    return PartCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  term.hil,
                  style: V6Text.hilWordBoldItalic.copyWith(color: V6Colors.primary),
                ),
              ),
              const SizedBox(width: 8),
              SmallChip(
                t.hiligaynonLabel,
                background: V6Colors.primaryContainer,
                foreground: V6Colors.onPrimaryContainer,
              ),
            ],
          ),
          if (term.note != null) _row(t.noteLabel, term.note!, bold: false),
          if (term.fil != null) _row(t.filipinoLabel, term.fil!, bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {required bool bold}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 76,
            child: Text(label, style: V6Text.labelMediumBold.copyWith(color: V6Colors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: bold ? V6Text.bodyMediumSemiBold : V6Text.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
