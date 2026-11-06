// Input cleanup for the offline translator. Dart port of
// docs/translation/text_rules.py, plus the spelling map (summary.md, step C).

import 'package:unorm_dart/unorm_dart.dart' as unorm;

final RegExp _accentMark = RegExp(r'\p{Mn}', unicode: true);
final RegExp _spaces = RegExp(r'\s+');

/// One "word" for the spelling map: letters, with ' or - allowed inside
/// (the map has entries like "g'wa" and "buas-damlag").
final RegExp _word = RegExp(r"\p{L}+(?:['-]\p{L}+)*", unicode: true);

/// Removes accent marks, makes quotes straight, leaves one space between
/// words, and trims.
String normalizeText(String text) {
  final noAccents = unorm.nfd(text).replaceAll(_accentMark, '');
  final straight = noAccents
      .replaceAll('’', "'")
      .replaceAll('‘', "'")
      .replaceAll('“', '"')
      .replaceAll('”', '"');
  return unorm.nfc(straight).replaceAll(_spaces, ' ').trim();
}

/// One sentence: up to . ? ! (and any closing quote) followed by a space or
/// the end, so "1.5" and "a.m" stay in one piece.
final RegExp _sentence = RegExp(
  r'''.+?(?:[.?!]+["')\]]*(?=\s|$)|$)''',
  dotAll: true,
);

List<String> splitSentences(String text) => _sentence
    .allMatches(text)
    .map((m) => m.group(0)!.trim())
    .where((s) => s.isNotEmpty)
    .toList();

final RegExp _lineEnd = RegExp(r'''[.?!:]["')\]]*$''');
final RegExp _startsLowercase = RegExp(r'^\p{Ll}', unicode: true);

/// Splits scanned text into pieces so a menu isn't one long sentence; a line joins the previous one only when it wraps mid-sentence.
List<String> scanSegments(List<List<String>> blocks) {
  final segments = <String>[];
  for (final block in blocks) {
    String? current;
    for (final raw in block) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final wrapped =
          current != null &&
          !_lineEnd.hasMatch(current) &&
          _startsLowercase.hasMatch(line);
      if (wrapped) {
        current = '$current $line';
      } else {
        if (current != null) segments.add(current);
        current = line;
      }
    }
    if (current != null) segments.add(current);
  }
  return segments;
}

/// Reads a tab-separated file into one map per row, using the first line as
/// the column names. There is no quoting in our files (like csv.QUOTE_NONE).
List<Map<String, String>> parseTsv(String content) {
  final lines = content.split('\n');
  final header = lines.first.replaceAll('\r', '').split('\t');
  final rows = <Map<String, String>>[];
  for (final raw in lines.skip(1)) {
    final line = raw.replaceAll('\r', '');
    if (line.isEmpty) continue;
    final cells = line.split('\t');
    rows.add({
      for (var i = 0; i < header.length; i++)
        header[i]: i < cells.length ? cells[i] : '',
    });
  }
  return rows;
}

/// Old spelling -> one standard spelling (sia -> siya). Hiligaynon input only.
class SpellingMap {
  SpellingMap(this.standardOf);

  /// Builds the map from hil_spelling_map_v2.tsv (columns: variant, standard).
  factory SpellingMap.fromTsv(String content) => SpellingMap({
    for (final row in parseTsv(content)) row['variant']!: row['standard']!,
  });

  final Map<String, String> standardOf;

  /// Replaces whole words only. Matches on lowercase and keeps the capital
  /// of the first letter ("Sia" -> "Siya").
  String apply(String text) => text.replaceAllMapped(_word, (m) {
    final word = m.group(0)!;
    final standard = standardOf[word.toLowerCase()];
    if (standard == null) return word;
    final firstIsCapital = word[0] != word[0].toLowerCase();
    return firstIsCapital
        ? standard[0].toUpperCase() + standard.substring(1)
        : standard;
  });
}
