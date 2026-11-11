import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P12 Verb forms (Figma "P12 · Part · Verb forms · kaon / inom"): root chips switch the table,
/// one row per time (the JSON `columns`), one column of forms, or "Who does it" + "What it happens to"
/// when the root has `doerForms`.
class VerbFormsPart extends StatefulWidget {
  const VerbFormsPart({super.key, required this.data});

  final VerbFormsPartData data;

  @override
  State<VerbFormsPart> createState() => _VerbFormsPartState();
}

class _VerbFormsPartState extends State<VerbFormsPart> {
  int _root = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    final root = data.roots[_root];
    return PartLayout(
      children: [
        // Figma P12: 14 between blocks, 8 between chips.
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 14),
        PartText(data.text),
        const SizedBox(height: 14),
        Text(t.verbFormsInstruction, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (i, r) in data.roots.indexed)
              _RootChip(
                root: r.root,
                meaning: r.fil,
                selected: i == _root,
                onTap: () => setState(() => _root = i),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _FormsTable(rowLabels: data.columns, root: root),
        const SizedBox(height: 14),
        _ExampleCard(label: t.exampleLabel, hil: root.example.hil, fil: root.example.fil),
        if (data.note != null) TipCard(data.note!, top: 14),
      ],
    );
  }
}

/// Figma "Root Chip" (791:7764): root + small Filipino meaning; Default / Selected.
class _RootChip extends StatelessWidget {
  const _RootChip({required this.root, required this.meaning, required this.selected, required this.onTap});

  final String root;
  final String meaning;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? V6Colors.primaryContainer : V6Colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? V6Colors.primary : V6Colors.borderDivider,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 72, minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  root,
                  style: V6Text.bodyLargeSemiBold.copyWith(
                    color: selected ? V6Colors.onPrimaryContainer : V6Colors.textPrimary,
                  ),
                ),
                Text(meaning, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma "Table card": radius 20, a Primary Container header row, rows 14/13 with a divider.
class _FormsTable extends StatelessWidget {
  const _FormsTable({required this.rowLabels, required this.root});

  final List<String> rowLabels;
  final VerbRoot root;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final doer = root.doerForms;
    final headers = [
      t.verbFormsWhen,
      if (doer != null) ...[t.verbFormsDoer, t.verbFormsObject] else t.verbFormsForm,
    ];
    final columns = [?doer, root.forms];
    final widths = <int, TableColumnWidth>{
      0: const FlexColumnWidth(1.1),
      for (var c = 1; c < headers.length; c++) c: const FlexColumnWidth(1.4),
    };

    Widget cell(Widget child, {required bool last, required EdgeInsets padding}) => Padding(
          padding: padding.copyWith(right: last ? padding.right : 8),
          child: child,
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Table(
        columnWidths: widths,
        children: [
          TableRow(
            decoration: const BoxDecoration(color: V6Colors.primaryContainer),
            children: [
              for (final (c, h) in headers.indexed)
                cell(
                  Text(h, style: V6Text.labelMediumBold.copyWith(color: V6Colors.onPrimaryContainer)),
                  last: c == headers.length - 1,
                  padding: EdgeInsets.fromLTRB(c == 0 ? 14 : 0, 10, c == headers.length - 1 ? 14 : 0, 10),
                ),
            ],
          ),
          for (final (r, label) in rowLabels.indexed)
            TableRow(
              decoration: BoxDecoration(
                border: r == rowLabels.length - 1
                    ? null
                    : const Border(bottom: BorderSide(color: V6Colors.borderDivider)),
              ),
              children: [
                cell(
                  Text(label, style: V6Text.bodyMediumSemiBold.copyWith(color: V6Colors.textSecondary)),
                  last: false,
                  padding: const EdgeInsets.fromLTRB(14, 13, 0, 13),
                ),
                for (final (c, forms) in columns.indexed)
                  cell(
                    Text.rich(verbFormSpan(forms[r], root.root)),
                    last: c == columns.length - 1,
                    padding: EdgeInsets.fromLTRB(0, 13, c == columns.length - 1 ? 14 : 0, 13),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// A verb form with the part that changes in violet: the start when the form ends with the root
/// (nag-, naga-, mag-, gin-, gina-), otherwise a final "-on" (kaunon, lutuon).
TextSpan verbFormSpan(String form, String root) {
  final base = V6Text.bodyMediumSemiBold.copyWith(color: V6Colors.textPrimary);
  final violet = base.copyWith(color: V6Colors.primary);
  final lower = form.toLowerCase();
  if (lower.length > root.length && lower.endsWith(root.toLowerCase())) {
    final cut = form.length - root.length;
    return TextSpan(style: base, children: [
      TextSpan(text: form.substring(0, cut), style: violet),
      TextSpan(text: form.substring(cut)),
    ]);
  }
  if (lower.length > 2 && lower.endsWith('on')) {
    final cut = form.length - 2;
    return TextSpan(style: base, children: [
      TextSpan(text: form.substring(0, cut)),
      TextSpan(text: form.substring(cut), style: violet),
    ]);
  }
  return TextSpan(text: form, style: base);
}

/// Figma "Example sentence": radius 18, padding 16/14, 4 between lines.
class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.label, required this.hil, required this.fil});

  final String label;
  final String hil;
  final String fil;

  @override
  Widget build(BuildContext context) {
    return PartCard(
      radius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: V6Text.labelMedium.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 4),
          Text(hil, style: V6Text.bodyLargeSemiBoldItalic.copyWith(color: V6Colors.primary)),
          const SizedBox(height: 4),
          Text(fil, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        ],
      ),
    );
  }
}
