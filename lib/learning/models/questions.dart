import '../data/json_reader.dart';
import 'parts.dart' show checkOptions;

/// Quiz question templates: template ID → `type` in the JSON.
/// Each ID has exactly one widget (Q01 → MultipleChoiceQuestion, …).
const Map<String, String> kQuestionTemplates = {
  'Q01': 'multiple_choice',
  'Q02': 'listening',
  'Q03': 'fill_blank',
  'Q04': 'type_answer',
  'Q05': 'build_sentence',
  'Q06': 'real_situation',
  'Q07': 'match_pairs',
  'Q08': 'dictation',
  'Q09': 'speaking',
  'Q10': 'open_answer',
};

/// One quiz question. There is one subclass per template ID, and the quiz
/// player picks the widget with an exhaustive `switch` on the subclass.
sealed class QuizQuestion {
  QuizQuestion(
    this.id,
    this.template, {
    required this.type,
    required this.scored,
    required this.answerAudio,
  });

  final String id;

  final String template;

  /// The JSON `type`, e.g. "multiple_choice". Used for the timer rule.
  final String type;

  /// False for speaking and open_answer ("Practice" in the review).
  final bool scored;

  /// Clip played on the Wrong / Time's up sheet, or null when the JSON has
  /// none (no audio button). Kept even if the file isn't in the app yet.
  final String? answerAudio;

  factory QuizQuestion.fromJson(JsonReader r, AssetResolver assets) {
    final id = r.str('id');
    final q = JsonReader(r.map, '${r.path} ($id)');
    final template = q.str('template');
    final type = q.str('type');
    final expected = kQuestionTemplates[template];
    if (expected == null) q.fail('unknown question template "$template"');
    if (expected != type) {
      q.fail('template $template should have type "$expected", not "$type"');
    }

    final scored = q.boolean('scored');
    final shouldBeScored = type != 'speaking' && type != 'open_answer';
    if (scored != shouldBeScored) {
      q.fail('"scored" should be $shouldBeScored for $type');
    }
    String? asset(String key) => assets.resolve(q.strOrNull(key), '${q.path} > $key');
    // Audio paths are kept even before the clip exists (the buttons show).
    String? audio(String key) => assets.resolveAudio(q.strOrNull(key), '${q.path} > $key');
    final answerAudio = audio('answerAudio');

    switch (template) {
      case 'Q01':
        final (options, answer) = _options(q);
        return MultipleChoiceData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            options: options,
            answer: answer);
      case 'Q02':
        final (options, answer) = _options(q);
        return ListeningData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            audio: audio('audio'),
            optionKind: q.str('optionKind'),
            options: options,
            answer: answer);
      case 'Q03':
        final (options, answer) = _options(q);
        final sentence = q.str('sentence');
        if (!sentence.contains('___')) q.fail('sentence has no "___" blank');
        return FillBlankData(id,
            answerAudio: answerAudio,
            sentence: sentence,
            meaning: q.str('meaning'),
            options: options,
            answer: answer);
      case 'Q04':
        final direction = q.str('direction');
        return TypeAnswerData(id,
            answerAudio: answerAudio,
            direction: switch (direction) {
              'fil_to_hil' => TypeDirection.filToHil,
              'hil_to_fil' => TypeDirection.hilToFil,
              _ => q.fail('unknown direction "$direction"'),
            },
            text: q.str('text'),
            accepted: _accepted(q));
      case 'Q05':
        final tiles = q.strings('tiles');
        final answer = q.strings('answer');
        _checkTiles(q, tiles, answer);
        return BuildSentenceData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            tiles: tiles,
            answer: answer);
      case 'Q06':
        final (options, answer) = _options(q);
        return RealSituationData(id,
            answerAudio: answerAudio,
            situation: q.str('situation'),
            image: asset('image'),
            options: options,
            answer: answer);
      case 'Q07':
        return MatchPairsData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            pairs: _pairs(q));
      case 'Q08':
        return DictationData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            audio: audio('audio'),
            accepted: _accepted(q),
            wordBank: q.stringsOrEmpty('wordBank'));
      case 'Q09':
        return SpeakingData(id,
            prompt: q.str('prompt'),
            text: q.str('text'),
            meaning: q.str('meaning'),
            audio: audio('audio'));
      case 'Q10':
        final maxChars = q.integer('maxChars');
        if (maxChars <= 0) q.fail('maxChars should be more than 0');
        return OpenAnswerData(id,
            prompt: q.str('prompt'),
            hint: q.str('hint'),
            maxChars: maxChars,
            modelAnswer: q.str('modelAnswer'));
    }
    q.fail('unknown question template "$template"');
  }

  static (List<String>, int) _options(JsonReader q) {
    final options = q.strings('options');
    final answer = q.integer('answer');
    checkOptions(q, options, answer);
    return (options, answer);
  }

  static List<String> _accepted(JsonReader q) {
    final accepted = q.strings('accepted');
    if (accepted.isEmpty) q.fail('"accepted" is empty');
    return accepted;
  }

  /// Every answer word must be one of the tiles (each tile used once), and
  /// there may be extra tiles (the distractors).
  static void _checkTiles(JsonReader q, List<String> tiles, List<String> answer) {
    if (answer.isEmpty) q.fail('"answer" is empty');
    final left = [...tiles];
    for (final word in answer) {
      if (!left.remove(word)) q.fail('answer word "$word" is not a tile');
    }
  }

  static List<MatchPair> _pairs(JsonReader q) {
    final pairs = <MatchPair>[];
    for (final (i, pair) in q.list('pairs').indexed) {
      if (pair is! List || pair.length != 2 || pair.any((s) => s is! String)) {
        q.fail('pairs[$i] should be [Hiligaynon, Filipino]');
      }
      pairs.add(MatchPair(pair[0] as String, pair[1] as String));
    }
    if (pairs.length < 2) q.fail('needs at least 2 pairs');
    if (pairs.map((p) => p.hil).toSet().length != pairs.length ||
        pairs.map((p) => p.fil).toSet().length != pairs.length) {
      q.fail('pairs repeat a word, so a match would be ambiguous');
    }
    return pairs;
  }
}

/// Questions answered by picking one option card (Q01, Q02, Q03, Q06).
/// The options are in JSON order; shuffle them before showing.
mixin ChoiceQuestion {
  List<String> get options;

  int get answer;

  String get correctOption => options[answer];
}

mixin TypedQuestion {
  /// Every accepted answer. Compare ignoring capitals, spaces at the ends and
  /// . , ! ?
  List<String> get accepted;
}

class MultipleChoiceData extends QuizQuestion with ChoiceQuestion {
  MultipleChoiceData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.options,
    required this.answer,
  }) : super(id, 'Q01', type: 'multiple_choice', scored: true);

  final String prompt;
  @override
  final List<String> options;
  @override
  final int answer;
}

class ListeningData extends QuizQuestion with ChoiceQuestion {
  ListeningData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.audio,
    required this.optionKind,
    required this.options,
    required this.answer,
  }) : super(id, 'Q02', type: 'listening', scored: true);

  final String prompt;

  /// The clip to listen to (kept even if the file isn't in the app yet).
  final String? audio;

  /// "text" (the only kind used so far).
  final String optionKind;
  @override
  final List<String> options;
  @override
  final int answer;
}

class FillBlankData extends QuizQuestion with ChoiceQuestion {
  FillBlankData(
    String id, {
    required super.answerAudio,
    required this.sentence,
    required this.meaning,
    required this.options,
    required this.answer,
  }) : super(id, 'Q03', type: 'fill_blank', scored: true);

  /// Contains "___" where the chosen word goes.
  final String sentence;

  /// The Filipino meaning shown under the sentence.
  final String meaning;
  @override
  final List<String> options;
  @override
  final int answer;
}

enum TypeDirection {
  /// Shown as "Type this in Hiligaynon".
  filToHil,

  /// Shown as "Type this in Filipino".
  hilToFil,
}

class TypeAnswerData extends QuizQuestion with TypedQuestion {
  TypeAnswerData(
    String id, {
    required super.answerAudio,
    required this.direction,
    required this.text,
    required this.accepted,
  }) : super(id, 'Q04', type: 'type_answer', scored: true);

  final TypeDirection direction;

  final String text;
  @override
  final List<String> accepted;
}

class BuildSentenceData extends QuizQuestion {
  BuildSentenceData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.tiles,
    required this.answer,
  }) : super(id, 'Q05', type: 'build_sentence', scored: true);

  /// The Filipino sentence to build in Hiligaynon.
  final String prompt;

  /// In JSON order, including one distractor. Shuffle before showing.
  final List<String> tiles;

  final List<String> answer;
}

class RealSituationData extends QuizQuestion with ChoiceQuestion {
  RealSituationData(
    String id, {
    required super.answerAudio,
    required this.situation,
    required this.image,
    required this.options,
    required this.answer,
  }) : super(id, 'Q06', type: 'real_situation', scored: true);

  final String situation;

  /// Asset path, or null if missing (→ firefly_reading).
  final String? image;
  @override
  final List<String> options;
  @override
  final int answer;
}

class MatchPair {
  const MatchPair(this.hil, this.fil);

  final String hil;
  final String fil;
}

class MatchPairsData extends QuizQuestion {
  MatchPairsData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.pairs,
  }) : super(id, 'Q07', type: 'match_pairs', scored: true);

  final String prompt;

  /// Hiligaynon left, Filipino right. Shuffle the right column before showing.
  final List<MatchPair> pairs;
}

class DictationData extends QuizQuestion with TypedQuestion {
  DictationData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.audio,
    required this.accepted,
    required this.wordBank,
  }) : super(id, 'Q08', type: 'dictation', scored: true);

  final String prompt;

  /// The clip to write down (kept even if the file isn't in the app yet).
  final String? audio;
  @override
  final List<String> accepted;

  /// Optional word chips under the field (may be empty).
  final List<String> wordBank;
}

class SpeakingData extends QuizQuestion {
  SpeakingData(
    String id, {
    required this.prompt,
    required this.text,
    required this.meaning,
    required this.audio,
  }) : super(id, 'Q09', type: 'speaking', scored: false, answerAudio: null);

  final String prompt;

  /// The Hiligaynon to say.
  final String text;

  final String meaning;

  /// The "Native speaker" clip (kept even if the file isn't in the app yet).
  final String? audio;
}

class OpenAnswerData extends QuizQuestion {
  OpenAnswerData(
    String id, {
    required this.prompt,
    required this.hint,
    required this.maxChars,
    required this.modelAnswer,
  }) : super(id, 'Q10', type: 'open_answer', scored: false, answerAudio: null);

  final String prompt;
  final String hint;
  final int maxChars;

  /// Shown on the Sample answer sheet (F04).
  final String modelAnswer;
}
