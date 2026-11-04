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
        return V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary);
      }
      return V6Text.bodyMedium;
    }

    // Figma "Table card": radius 20; header row padding 14/10, rows 14/13,
    // 8 between columns; columns share the width and wrap.
    Widget row(List<Widget> cells, EdgeInsets padding, {Color? color, bool divider = false}) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          border: divider
              ? const Border(bottom: BorderSide(color: V6Colors.borderDivider))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var c = 0; c < cells.length; c++) ...[
              if (c > 0) const SizedBox(width: 8),
              Expanded(child: cells[c]),
            ],
          ],
        ),
      );
    }

    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 14),
        PartText(data.text),
        const SizedBox(height: 14),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: V6Colors.borderDivider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row(
                [
                  for (final name in data.columns)
                    Text(name, style: V6Text.labelMediumBold.copyWith(color: V6Colors.onPrimaryContainer)),
                ],
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                color: V6Colors.primaryContainer,
              ),
              for (var r = 0; r < data.rows.length; r++)
                row(
                  [
                    for (var c = 0; c < data.rows[r].length; c++)
                      Text(data.rows[r][c], style: cellStyle(c)),
                  ],
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  divider: r < data.rows.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
