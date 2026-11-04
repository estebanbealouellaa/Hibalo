import 'package:flutter/material.dart';

import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P02 · Table: icon + title, the explanation, then a 2–4 column table.
/// Columns share the width and the text wraps, so it never scrolls sideways.
/// Hiligaynon columns (`hilColumns`) are italic violet; a column named
/// "Filipino" is grey. No audio.
class TablePart extends StatelessWidget {
  const TablePart({super.key, required this.data});

  final TablePartData data;

  @override
  Widget build(BuildContext context) {
    final filipinoColumn = data.columns.indexWhere((c) => c.toLowerCase() == 'filipino');

    TextStyle cellStyle(int column) {
      if (data.hilColumns.contains(column)) {
        return V6Text.bodyMediumSemiBoldItalic.copyWith(color: V6Colors.primary);
      }
      if (column == filipinoColumn) {
        return V6Text.bodyMedium.copyWith(color: V6Colors.textNeutral);
      }
      return V6Text.bodyMedium;
    }

    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 16),
        PartText(data.text),
        const SizedBox(height: 16),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: V6Colors.borderDivider),
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            border: const TableBorder(
              horizontalInside: BorderSide(color: V6Colors.borderDivider),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: V6Colors.primaryContainer),
                children: [
                  for (final name in data.columns)
                    _cell(Text(name, style: V6Text.labelMediumBold)),
                ],
              ),
              for (final row in data.rows)
                TableRow(
                  children: [
                    for (var c = 0; c < row.length; c++)
                      _cell(Text(row[c], style: cellStyle(c))),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(Widget child) =>
      Padding(padding: const EdgeInsets.fromLTRB(12, 12, 8, 12), child: child);
}
