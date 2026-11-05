import 'dart:math';

import '../models/questions.dart';

/// Pure quiz rules (§1.8, §4), kept apart from the widgets so they can be
/// tested without a screen.

// ── Typed answers (Q04, Q08) ────────────────────────────────────────────────

final _ignoredPunctuation = RegExp(r'[.,!?]');

/// A typed answer as it is compared: capital letters, spaces at the ends and
/// . , ! ? don't count (`_meta.fieldGuide.accepted`).
String normalizeTyped(String text) =>
    text.replaceAll(_ignoredPunctuation, '').trim().toLowerCase();

/// True if [typed] matches any entry of [accepted].
bool matchesAccepted(String typed, List<String> accepted) {
  final answer = normalizeTyped(typed);
  if (answer.isEmpty) return false;
  return accepted.any((a) => normalizeTyped(a) == answer);
}

// ── Shuffling ───────────────────────────────────────────────────────────────

/// The order to show [count] items in: a shuffle of 0..count-1, or the JSON
/// order when shuffling is off. Item `order[i]` is shown in position i.
List<int> shuffledOrder(int count, Random random, {bool shuffle = true}) {
  final order = List<int>.generate(count, (i) => i);
  if (shuffle) order.shuffle(random);
  return order;
}

/// Where the right option lands after shuffling (its position on screen).
int positionOf(int jsonIndex, List<int> order) => order.indexOf(jsonIndex);

/// Build tiles (Q05) in the order to show. Tiles can repeat ("Maayong" may
/// appear twice), so they are tracked by index, not by text.
List<int> tileOrder(BuildSentenceData q, Random random, {bool shuffle = true}) =>
    shuffledOrder(q.tiles.length, random, shuffle: shuffle);

/// True if the tiles picked (indexes into `q.tiles`, in answer order) spell
/// the answer word for word.
bool isRightSentence(BuildSentenceData q, List<int> picked) {
  if (picked.length != q.answer.length) return false;
  for (var i = 0; i < picked.length; i++) {
    if (q.tiles[picked[i]] != q.answer[i]) return false;
  }
  return true;
}

// ── Outcomes and score ──────────────────────────────────────────────────────

/// How one question ended.
enum QuestionOutcome {
  right,
  wrong,

  /// The timer reached 0 (counts as wrong).
  timeout,

  /// Speaking and open answer: not scored.
  practice,
}

/// The score of a finished attempt (§1.8): correct scored questions over
/// scored questions. Unscored questions are left out of both.
class QuizScore {
  const QuizScore({required this.correct, required this.total});

  /// Right answers among the scored questions.
  final int correct;

  /// Scored questions in the quiz.
  final int total;

  double get ratio => total == 0 ? 0 : correct / total;

  /// Whole percent, for "Accuracy".
  int get percent => (ratio * 100).round();

  bool passes(double passMark) => total > 0 && ratio >= passMark - 1e-9;

  static QuizScore of(List<QuizQuestion> questions, Map<String, QuestionOutcome> outcomes) {
    var correct = 0;
    var total = 0;
    for (final q in questions) {
      if (!q.scored) continue;
      total++;
      if (outcomes[q.id] == QuestionOutcome.right) correct++;
    }
    return QuizScore(correct: correct, total: total);
  }
}

/// The text of the right answer, for the Wrong / Time's up sheets.
/// Q07 has no single answer: its sheet lists the pairs instead.
String? correctAnswerText(QuizQuestion q) => switch (q) {
      MultipleChoiceData q => q.correctOption,
      ListeningData q => q.correctOption,
      FillBlankData q => q.correctOption,
      RealSituationData q => q.correctOption,
      TypeAnswerData q => q.accepted.first,
      DictationData q => q.accepted.first,
      BuildSentenceData q => q.answer.join(' '),
      MatchPairsData() => null,
      SpeakingData() => null,
      OpenAnswerData() => null,
    };
