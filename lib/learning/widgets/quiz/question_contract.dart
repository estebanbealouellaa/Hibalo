import 'package:flutter/foundation.dart';

/// Where a question is in its life, set by the quiz shell.
enum QuestionPhase {
  /// The learner can answer.
  answering,

  /// Check was pressed: the answer is locked and shown right / wrong.
  checked,

  /// The timer reached 0: the input is locked (counts as wrong).
  timedOut,
}

/// What a question widget tells the shell after every change.
@immutable
class AnswerState {
  const AnswerState({required this.ready, this.correct = false});

  /// Nothing given yet.
  static const empty = AnswerState(ready: false);

  /// The primary button (Check / Submit / Continue) can be pressed.
  final bool ready;

  /// The current answer is right (scored questions only).
  final bool correct;

  @override
  bool operator ==(Object other) =>
      other is AnswerState && other.ready == ready && other.correct == correct;

  @override
  int get hashCode => Object.hash(ready, correct);
}

typedef AnswerChanged = void Function(AnswerState state);
