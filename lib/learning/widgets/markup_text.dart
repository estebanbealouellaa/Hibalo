import 'package:flutter/material.dart';

import '../theme/v6_colors.dart';

/// Text from lessons.json where words between `*asterisks*` are Hiligaynon
/// or Filipino examples: those are shown italic and violet (or [exampleColor],
/// e.g. Lagoon Text inside the teal tip card). The asterisks are not shown.
class MarkupText extends StatelessWidget {
  const MarkupText(
    this.text, {
    super.key,
    required this.style,
    this.exampleColor = V6Colors.primary,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final Color exampleColor;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: markupSpans(text, style, exampleColor)),
      textAlign: textAlign,
    );
  }
}

/// Splits [text] at the asterisks: odd pieces are the examples. A lone
/// asterisk with no partner is kept as plain text.
List<TextSpan> markupSpans(String text, TextStyle style, Color exampleColor) {
  final pieces = text.split('*');
  if (pieces.length.isEven) return [TextSpan(text: text, style: style)];
  final example = style.copyWith(fontStyle: FontStyle.italic, color: exampleColor);
  return [
    for (var i = 0; i < pieces.length; i++)
      if (pieces[i].isNotEmpty)
        TextSpan(text: pieces[i], style: i.isOdd ? example : style),
  ];
}

/// The text without the asterisks (for screen readers and tests).
String plainMarkup(String text) =>
    text.split('*').length.isEven ? text : text.replaceAll('*', '');
