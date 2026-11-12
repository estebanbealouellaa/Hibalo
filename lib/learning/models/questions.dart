import '../data/json_reader.dart';
import 'parts.dart';

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
  'Q11': 'read_answer',
  'Q12': 'spot_mistake',
  'Q13': 'passage_set',
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
  /// none or it isn't recorded yet (no audio button).
  final String? answerAudio;

  /// [parts]: the lesson's parts by id, for Q11's `passagePart`.
  factory QuizQuestion.fromJson(JsonReader r, AssetResolver assets, Map<String, LessonPart> parts) {
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
    // A clip that isn't in the app yet is null.
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
            audioText: q.strOrNull('audioText'),
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
            meaning: q.strOrNull('meaning'),
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
            modelAnswer: q.str('modelAnswer'),
            audio: audio('audio'),
            transcript: q.strOrNull('transcript'));
      case 'Q12':
        final tiles = q.strings('tiles');
        final sentence = q.str('sentence');
        if (tiles.join(' ') != sentence) q.fail('tiles should be the sentence split on spaces');
        final wrongIndex = q.integer('wrongIndex');
        if (wrongIndex < 0 || wrongIndex >= tiles.length) {
          q.fail('wrongIndex $wrongIndex is out of range (0–${tiles.length - 1})');
        }
        return SpotMistakeData(id,
            answerAudio: answerAudio,
            prompt: q.str('prompt'),
            sentence: sentence,
            tiles: tiles,
            meaning: q.str('meaning'),
            wrongIndex: wrongIndex,
            fix: q.str('fix'));
      case 'Q11' || 'Q13':
        final (options, answer) = _options(q);
        final mode = q.str('mode');
        final partId = q.str('passagePart');
        final passage = switch (parts[partId]) {
          ReadingPartData(:final lines) => [for (final l in lines) PassageLine(null, l.hil, null)],
          DialoguePartData(:final lines) => [for (final l in lines) PassageLine(l.speaker, l.hil, l.audio)],
          null => q.fail('passagePart "$partId" is not a part of this lesson'),
          _ => q.fail('passagePart "$partId" should be a reading or a dialogue'),
        };
        final listen = switch (mode) {
          'read' => false,
          'listen' => true,
          _ => q.fail('unknown mode "$mode"'),
        };
        if (listen) {
          // Every line needs a clip in the JSON (it may not be recorded yet).
          final part = parts[partId];
          if (part is! DialoguePartData) q.fail('listen mode needs a dialogue with audio');
          if (part.lines.any((l) => !l.hasClip)) q.fail('listen mode: passage "$partId" has lines without audio');
        }
        final readMode = listen ? ReadAnswerMode.listen : ReadAnswerMode.read;
        if (template == 'Q13') {
          final setSize = q.integer('setSize');
          final setIndex = q.integer('setIndex');
          if (setIndex < 1 || setIndex > setSize) q.fail('setIndex $setIndex is not 1–$setSize');
          return PassageSetData(id,
              answerAudio: answerAudio,
              mode: readMode,
              passagePart: partId,
              passage: passage,
              question: q.str('question'),
              options: options,
              answer: answer,
              setIndex: setIndex,
              setSize: setSize);
        }
        return ReadAnswerData(id,
            answerAudio: answerAudio,
            mode: readMode,
            passagePart: partId,
            passage: passage,
            question: q.str('question'),
            options: options,
            answer: answer);
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
    this.audioText,
    required this.optionKind,
    required this.options,
    required this.answer,
  }) : super(id, 'Q02', type: 'listening', scored: true);

  final String prompt;

  /// The clip to listen to, or null if it isn't recorded yet.
  final String? audio;

  /// The clip's Hiligaynon words, shown in place of the play button while the clip is missing; null if the JSON has none.
  final String? audioText;

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

  /// The Filipino meaning shown under the sentence; null hides it.
  final String? meaning;
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

  /// The clip to write down, or null if it isn't recorded yet.
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

  /// The "Native speaker" clip, or null if it isn't recorded yet.
  final String? audio;
}

class OpenAnswerData extends QuizQuestion {
  OpenAnswerData(
    String id, {
    required this.prompt,
    required this.hint,
    required this.maxChars,
    required this.modelAnswer,
    this.audio,
    this.transcript,
  }) : super(id, 'Q10', type: 'open_answer', scored: false, answerAudio: null);

  final String prompt;
  final String hint;
  final int maxChars;

  /// Shown on the Sample answer sheet (F04).
  final String modelAnswer;

  /// Clip played above the answer box, or null (none, or not recorded yet).
  final String? audio;

  /// The clip's words, shown on the Sample answer sheet; null when there is no clip.
  final String? transcript;
}

enum ReadAnswerMode {
  /// The passage text is shown above the question.
  read,

  /// A play button plays the passage's line clips in order.
  listen,
}

/// One line of a Q11 passage. [speaker] is null for reading lines.
class PassageLine {
  const PassageLine(this.speaker, this.hil, this.audio);

  final String? speaker;
  final String hil;

  /// The line's clip, or null (reading lines, or not recorded yet).
  final String? audio;
}

class ReadAnswerData extends QuizQuestion with ChoiceQuestion {
  ReadAnswerData(
    String id, {
    required super.answerAudio,
    required this.mode,
    required this.passagePart,
    required this.passage,
    required this.question,
    required this.options,
    required this.answer,
    String template = 'Q11',
    String type = 'read_answer',
  }) : super(id, template, type: type, scored: true);

  final ReadAnswerMode mode;

  /// Id of the reading or dialogue part in the same lesson.
  final String passagePart;

  /// That part's lines (Hiligaynon only).
  final List<PassageLine> passage;

  final String question;
  @override
  final List<String> options;
  @override
  final int answer;

  /// The line clips in order, or empty when any of them isn't in the app yet.
  List<String> get clips =>
      passage.every((l) => l.audio != null) ? [for (final l in passage) l.audio!] : const [];
}

/// Q13 Passage set: one of [setSize] questions in a row on the same passage. It works like Q11
/// (a subclass, so every Q11 rule applies); the widget adds "Question n of N" and folds the passage
/// to "Show story" after the first question.
class PassageSetData extends ReadAnswerData {
  PassageSetData(
    super.id, {
    required super.answerAudio,
    required super.mode,
    required super.passagePart,
    required super.passage,
    required super.question,
    required super.options,
    required super.answer,
    required this.setIndex,
    required this.setSize,
  }) : super(template: 'Q13', type: 'passage_set');

  /// 1-based position in the set.
  final int setIndex;
  final int setSize;
}

/// Q12 Spot the mistake: tap the wrong word. No timer.
class SpotMistakeData extends QuizQuestion {
  SpotMistakeData(
    String id, {
    required super.answerAudio,
    required this.prompt,
    required this.sentence,
    required this.tiles,
    required this.meaning,
    required this.wrongIndex,
    required this.fix,
  }) : super(id, 'Q12', type: 'spot_mistake', scored: true);

  final String prompt;
  final String sentence;

  /// The sentence split on spaces; punctuation stays on its tile.
  final List<String> tiles;

  /// The Filipino meaning of the corrected sentence.
  final String meaning;

  /// Index of the wrong tile: tapping it is the right answer.
  final int wrongIndex;

  /// The right word(s), on the fix chip and the Not quite sheet (may be two words).
  final String fix;

  String get wrongWord => tiles[wrongIndex];
}
