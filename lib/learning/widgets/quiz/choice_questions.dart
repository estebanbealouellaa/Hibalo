import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../lesson_image.dart';
import '../parts/quick_check_part.dart' show OptionCard, OptionState;
import 'question_contract.dart';
import 'quiz_common.dart';

/// The option-card questions: Q01 Multiple choice, Q02 Listening, Q03 Fill
/// in the blank and Q06 Real situation. Tap selects one card (violet);
/// Check reveals it (green / red, and the right one turns green).

/// The shuffled option cards, shared by the four widgets below.
class _OptionList extends StatelessWidget {
  const _OptionList({
    required this.question,
    required this.order,
    required this.chosen,
    required this.phase,
    required this.onChoose,
  });

  final ChoiceQuestion question;

  /// Option indexes (JSON order) in the order they are shown.
  final List<int> order;
  final int? chosen;
  final QuestionPhase phase;
  final ValueChanged<int> onChoose;

  OptionState _stateOf(int i) {
    switch (phase) {
      case QuestionPhase.answering:
        return i == chosen ? OptionState.selected : OptionState.idle;
      case QuestionPhase.checked:
      case QuestionPhase.timedOut:
        if (i == question.answer) return OptionState.right;
        if (i == chosen) return OptionState.wrong;
        return OptionState.idle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final answering = phase == QuestionPhase.answering;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var n = 0; n < order.length; n++) ...[
          if (n > 0) const SizedBox(height: 12),
          OptionCard(
            text: question.options[order[n]],
            state: _stateOf(order[n]),
            onTap: answering ? () => onChoose(order[n]) : null,
          ),
        ],
      ],
    );
  }
}

/// Keeps the chosen option and reports it to the shell.
mixin _ChoiceState<W extends StatefulWidget> on State<W> {
  int? chosen;

  ChoiceQuestion get choice;
  AnswerChanged get onChanged;

  void choose(int i) {
    setState(() => chosen = i);
    onChanged(AnswerState(ready: true, correct: i == choice.answer));
  }
}

// ── Q01 Multiple choice ─────────────────────────────────────────────────────

class MultipleChoiceQuestion extends StatefulWidget {
  const MultipleChoiceQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
  });

  final MultipleChoiceData data;
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion>
    with _ChoiceState<MultipleChoiceQuestion> {
  @override
  ChoiceQuestion get choice => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: AppLocalizations.of(context).q01Hint),
        const SizedBox(height: 12),
        _OptionList(
          question: widget.data,
          order: widget.order,
          chosen: chosen,
          phase: widget.phase,
          onChoose: choose,
        ),
      ],
    );
  }
}

// ── Q02 Listening ───────────────────────────────────────────────────────────

class ListeningQuestion extends StatefulWidget {
  const ListeningQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
  });

  final ListeningData data;
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<ListeningQuestion> createState() => _ListeningQuestionState();
}

class _ListeningQuestionState extends State<ListeningQuestion>
    with _ChoiceState<ListeningQuestion> {
  @override
  ChoiceQuestion get choice => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: AppLocalizations.of(context).q02Hint),
        const SizedBox(height: 12),
        BigAudioButtons(clip: widget.data.audio),
        const SizedBox(height: 12),
        _OptionList(
          question: widget.data,
          order: widget.order,
          chosen: chosen,
          phase: widget.phase,
          onChoose: choose,
        ),
      ],
    );
  }
}

// ── Q03 Fill in the blank ───────────────────────────────────────────────────

class FillBlankQuestion extends StatefulWidget {
  const FillBlankQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
  });

  final FillBlankData data;
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<FillBlankQuestion> createState() => _FillBlankQuestionState();
}

class _FillBlankQuestionState extends State<FillBlankQuestion>
    with _ChoiceState<FillBlankQuestion> {
  @override
  ChoiceQuestion get choice => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // The chosen word also fills the blank (§4).
    final word = chosen == null ? '___' : widget.data.options[chosen!];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(t.q03Title, hint: t.q03Hint),
        const SizedBox(height: 12),
        PromptCard(
          label: t.hiligaynonLabel,
          text: widget.data.sentence.replaceFirst('___', word),
          sub: widget.data.meaning,
        ),
        const SizedBox(height: 12),
        _OptionList(
          question: widget.data,
          order: widget.order,
          chosen: chosen,
          phase: widget.phase,
          onChoose: choose,
        ),
      ],
    );
  }
}

// ── Q06 Real situation ──────────────────────────────────────────────────────

class RealSituationQuestion extends StatefulWidget {
  const RealSituationQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
    required this.fallbackPicture,
  });

  final RealSituationData data;
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  /// firefly_reading, shown when `image` is null or missing.
  final String fallbackPicture;

  @override
  State<RealSituationQuestion> createState() => _RealSituationQuestionState();
}

class _RealSituationQuestionState extends State<RealSituationQuestion>
    with _ChoiceState<RealSituationQuestion> {
  @override
  ChoiceQuestion get choice => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(AppLocalizations.of(context).q06Title),
        const SizedBox(height: 12),
        // Figma "Situation": glow card, padding 16, a 64 x 64 picture, text.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: V6Colors.glowContainerSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: V6Colors.glow),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: LessonImage(
                    path: widget.data.image,
                    fallback: widget.fallbackPicture,
                    fallbackColor: V6Colors.primaryContainer,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.data.situation, style: V6Text.bodyLargeSemiBold)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _OptionList(
          question: widget.data,
          order: widget.order,
          chosen: chosen,
          phase: widget.phase,
          onChoose: choose,
        ),
      ],
    );
  }
}
