// Short-phrase lookup, checked BEFORE running the model. Dart port of
// docs/translation/phrase_lookup.py.

import 'text_rules.dart';

/// . , ! ? ; : " ( ) [ ] … — – ' ~ *
final RegExp _punctuation = RegExp(r"""[.,!?;:"()\[\]…—–'~*]""");
final RegExp _spaces = RegExp(r'\s+');

class PhraseMatch {
  const PhraseMatch(this.output, {required this.isDictionaryWord});

  final String output;

  /// True for a single-word Motus meaning, shown as "dictionary meaning".
  final bool isDictionaryWord;
}

class PhraseList {
  /// [useEvalRows]: true in the app; false when scoring on the everyday test, so test sentences don't come from this list.
  factory PhraseList.fromTsv(
    String phraseTsv,
    SpellingMap spelling, {
    bool useEvalRows = true,
    bool useDictionaryWords = true,
  }) {
    final table = <String, PhraseMatch>{};
    for (final row in parseTsv(phraseTsv)) {
      if (!useEvalRows && row['in_eval_set'] == '1') continue;
      final isDictionaryWord = row['kind'] == 'dictionary_word';
      if (!useDictionaryWords && isDictionaryWord) continue;
      table['${row['direction']}\t${row['key']}'] = PhraseMatch(
        row['output']!,
        isDictionaryWord: isDictionaryWord,
      );
    }
    return PhraseList._(table, spelling);
  }

  PhraseList._(this._table, this._spelling);

  final Map<String, PhraseMatch> _table;
  final SpellingMap _spelling;

  int get length => _table.length;

  /// The lookup key: normalized, lowercase, no punctuation, single spaces,
  /// and for Hiligaynon each word in its standard spelling.
  String key(String text, {required bool fromHiligaynon}) {
    final words = normalizeText(text)
        .toLowerCase()
        .replaceAll(_punctuation, ' ')
        .split(_spaces)
        .where((w) => w.isNotEmpty);
    return words
        .map((w) => fromHiligaynon ? (_spelling.standardOf[w] ?? w) : w)
        .join(' ');
  }

  /// The stored translation, or null when the model has to translate.
  PhraseMatch? lookup(String text, {required bool fromHiligaynon}) {
    final direction = fromHiligaynon ? 'hil2fil' : 'fil2hil';
    return _table['$direction\t${key(text, fromHiligaynon: fromHiligaynon)}'];
  }
}
