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
        const SizedBox(height: 16),
        PartText(data.text),
        for (final term in data.terms) ...[
          const SizedBox(height: 12),
          _TermCard(term),
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
    return PartCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
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
              SmallChip(
                t.hiligaynonLabel,
                background: V6Colors.primaryContainer,
                foreground: V6Colors.textSecondary,
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
            child: Text(label, style: V6Text.labelMediumBold),
          ),
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
