import 'package:flutter/foundation.dart';

/// Where a question is in its life, set by the quiz shell.
enum QuestionPhase {
  answering,

  /// Check was pressed: the answer is locked and shown right / wrong.
  checked,

  /// The timer reached 0: the input is locked (counts as wrong).
  timedOut,
}

/// What a question widget tells the shell after every change.
@immutable
class AnswerState {
  const AnswerState({
    required this.ready,
    this.correct = false,
    this.text,
    this.pairsRight,
  });

  static const empty = AnswerState(ready: false);

  /// The primary button (Check / Submit / Continue) can be pressed.
  final bool ready;

  /// The current answer is right (scored questions only).
  final bool correct;

  /// The answer as the learner gave it, for Quiz review (S05): the chosen
  /// option, the typed text or the built sentence. Null for Q07 and Q09.
  final String? text;

  /// Q07 Match pairs: pairs matched with no wrong tap, for "N of M pairs".
  final int? pairsRight;

  @override
  bool operator ==(Object other) =>
      other is AnswerState &&
      other.ready == ready &&
      other.correct == correct &&
      other.text == text &&
      other.pairsRight == pairsRight;

  @override
  int get hashCode => Object.hash(ready, correct, text, pairsRight);
}

typedef AnswerChanged = void Function(AnswerState state);
