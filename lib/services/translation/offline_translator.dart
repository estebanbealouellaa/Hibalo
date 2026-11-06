// The offline Hiligaynon <-> Filipino translator: the pipeline from section 10 of docs/translation/summary.md.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'number_tags.dart';
import 'phrase_lookup.dart';
import 'postprocess.dart';
import 'sentencepiece_tokenizer.dart';
import 'text_rules.dart';
import 'translation_engine.dart';

/// Longer sentences use greedy: on a Galaxy A03 beam 4 took 8.9 s vs 2.2 s greedy for 15+ words.
const int kBeamMaxWords = 15;

const String kTranslationNote = 'Maaaring hindi eksakto ang salin.';

/// The note text, with a label for single-word dictionary meanings.
String translationNote({required bool isDictionaryMeaning}) =>
    isDictionaryMeaning ? 'Dictionary meaning. $kTranslationNote' : kTranslationNote;

enum TranslationMethod { phraseList, beam, greedy }

class TranslationResult {
  const TranslationResult(
    this.text, {
    required this.method,
    required this.milliseconds,
    required this.wordCount,
    this.isDictionaryMeaning = false,
  });

  final String text;
  final TranslationMethod method;
  final int milliseconds;
  final int wordCount;

  /// True for a single-word Motus meaning from the phrase list.
  final bool isDictionaryMeaning;
}

class _TextData {
  _TextData(this.tokenizer, this.spelling, this.phrases);

  final SentencePieceTokenizer tokenizer;
  final SpellingMap spelling;
  final PhraseList phrases;
}

/// Runs on a background isolate, so parsing the files doesn't freeze the UI.
_TextData _parseTextData(
  (Uint8List, String, String, bool, bool) files,
) {
  final (spm, spellingTsv, phraseTsv, useEvalRows, useDictionaryWords) = files;
  final spelling = SpellingMap.fromTsv(spellingTsv);
  return _TextData(
    SentencePieceTokenizer.fromBytes(spm),
    spelling,
    PhraseList.fromTsv(
      phraseTsv,
      spelling,
      useEvalRows: useEvalRows,
      useDictionaryWords: useDictionaryWords,
    ),
  );
}

class OfflineTranslator {
  /// [useEvalRows]: keep it true in the app. Use false when scoring the app
  /// on the everyday test, so the scores are fair.
  OfflineTranslator({
    this.useEvalRows = true,
    this.useDictionaryWords = true,
    this.usePhraseList = true,
    this.paragraphBeamSize = kParagraphBeamSize,
    int threads = kTranslationThreads,
  }) : _engine = TranslationEngine(threads: threads);

  /// Shared by every screen so the model is loaded only once.
  static final OfflineTranslator instance = OfflineTranslator();

  static const String _dataDir = 'assets/translation/data';
  static const int _hilTag = 3; // >>hil<< : translate INTO Hiligaynon
  static const int _filTag = 4; // >>fil<< : translate INTO Filipino
  static const int _endToken = 1;
  static const int _maxSourceTokens = 126;

  final bool useEvalRows;
  final bool useDictionaryWords;

  /// False scores the model alone, as in the spec's tables.
  final bool usePhraseList;

  /// Beam size per sentence when the input has 2 or more sentences.
  final int paragraphBeamSize;

  final TranslationEngine _engine;
  late _TextData _text;
  Future<void>? _loading;

  /// Loads everything once and keeps it in memory. Throws if a file is
  /// missing or broken; a later call tries again.
  Future<void> load() => _loading ??= _load().catchError((Object e) {
    _loading = null;
    throw e;
  });

  Future<void> _load() async {
    final sw = Stopwatch()..start();
    final spm = await rootBundle.load('${TranslationEngine.modelDir}/spm.model');
    final spelling = await rootBundle.loadString(
      '$_dataDir/hil_spelling_map_v2.tsv',
      cache: false,
    );
    final phrases = await rootBundle.loadString(
      '$_dataDir/hibalo_phrase_list_v1.tsv',
      cache: false,
    );
    _text = await compute(_parseTextData, (
      spm.buffer.asUint8List(spm.offsetInBytes, spm.lengthInBytes),
      spelling,
      phrases,
      useEvalRows,
      useDictionaryWords,
    ));
    await _engine.load();
    debugPrint(
      '[HibaloTranslate] ready in ${sw.elapsedMilliseconds} ms '
      '(${_text.phrases.length} phrases)',
    );
  }

  /// Starts loading in the background, so the first translation doesn't wait.
  static void warmUp() {
    instance.load().catchError((Object e) {
      debugPrint('[HibaloTranslate] load failed: $e');
    });
  }

  /// Translates one sentence at a time; [onPartial] gets the finished sentences so far.
  Future<TranslationResult> translate(
    String text, {
    required bool fromHiligaynon,
    void Function(String textSoFar)? onPartial,
    bool partOfParagraph = false,
  }) async {
    await load();
    final sw = Stopwatch()..start();
    final words = _wordCount(text);

    // The whole input first: the list has some multi-sentence phrases.
    final match = _lookup(text, fromHiligaynon);
    if (match != null) {
      return _finish(
        matchStyle(text, match.output),
        TranslationMethod.phraseList,
        sw,
        words,
        isDictionaryMeaning: match.isDictionaryWord,
      );
    }

    final sentences = splitSentences(text);
    final beamSize = partOfParagraph || sentences.length >= 2
        ? paragraphBeamSize
        : kBeamSize;
    final done = <String>[];
    var greedyCount = 0;
    var modelCount = 0;
    for (var i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      final sentenceSw = Stopwatch()..start();
      final found = _lookup(sentence, fromHiligaynon);
      final sentenceWords = _wordCount(sentence);
      final greedy = sentenceWords > kBeamMaxWords;
      final String output;
      if (found != null) {
        output = found.output;
      } else {
        modelCount++;
        if (greedy) greedyCount++;
        output = await _runModel(
          sentence,
          fromHiligaynon: fromHiligaynon,
          greedy: greedy,
          beamSize: beamSize,
        );
      }
      done.add(matchStyle(sentence, output));
      debugPrint(
        '[HibaloTranslate] sentence ${i + 1}/${sentences.length}: '
        '${sentenceSw.elapsedMilliseconds} ms, '
        '${found != null ? 'phrase list' : (greedy ? 'greedy' : 'beam $beamSize')}, '
        '$sentenceWords words',
      );
      if (i < sentences.length - 1) onPartial?.call(done.join(' '));
    }

    final method = modelCount == 0
        ? TranslationMethod.phraseList
        : (greedyCount == modelCount
              ? TranslationMethod.greedy
              : TranslationMethod.beam);
    return _finish(done.join(' '), method, sw, words, beamSize: beamSize);
  }

  PhraseMatch? _lookup(String text, bool fromHiligaynon) => usePhraseList
      ? _text.phrases.lookup(text, fromHiligaynon: fromHiligaynon)
      : null;

  /// The model alone (steps B to I): no phrase list and no match_style. This
  /// is what the reference CSV and the section 11 table contain.
  @visibleForTesting
  Future<String> translateModelOnly(
    String text, {
    required bool fromHiligaynon,
    required bool greedy,
  }) async {
    await load();
    return _runModel(text, fromHiligaynon: fromHiligaynon, greedy: greedy);
  }

  Future<String> _runModel(
    String text, {
    required bool fromHiligaynon,
    required bool greedy,
    int beamSize = kBeamSize,
  }) async {
    var source = normalizeText(text);
    if (source.isEmpty) return '';
    if (fromHiligaynon) source = _text.spelling.apply(source);
    final (tagged, numbers) = protectNumbers(source);

    final tokenizer = _text.tokenizer;
    final encoded = tokenizer.encode(tagged);
    final ids = [
      fromHiligaynon ? _filTag : _hilTag,
      ...encoded.take(_maxSourceTokens),
      _endToken,
    ];
    final output = greedy
        ? await _engine.greedySearch(ids)
        : await _engine.beamSearch(ids, beamSize: beamSize);
    return restoreNumbers(tokenizer.decode(output), numbers);
  }

  static int _wordCount(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? 0 : trimmed.split(RegExp(r'\s+')).length;
  }

  /// Logs the timing, so speed can be tested on a real phone.
  TranslationResult _finish(
    String text,
    TranslationMethod method,
    Stopwatch sw,
    int words, {
    bool isDictionaryMeaning = false,
    int beamSize = kBeamSize,
  }) {
    final ms = sw.elapsedMilliseconds;
    final how = method == TranslationMethod.beam
        ? 'beam $beamSize'
        : method.name;
    debugPrint('[HibaloTranslate] $ms ms, $how, $words words');
    return TranslationResult(
      text,
      method: method,
      milliseconds: ms,
      wordCount: words,
      isDictionaryMeaning: isDictionaryMeaning,
    );
  }
}
