import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../logic/quiz_logic.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'question_contract.dart';
import 'quiz_common.dart';

/// Q04 Type the answer and Q08 Dictation: the answer is typed and compared
/// with every entry in `accepted` (ignoring capitals, spaces at the ends and
/// . , ! ?). Check is enabled once something is typed. No timer.
mixin _TypedState<W extends StatefulWidget> on State<W> {
  final TextEditingController controller = TextEditingController();

  TypedQuestion get typed;
  AnswerChanged get onChanged;

  void report(String text) {
    onChanged(AnswerState(
      ready: text.trim().isNotEmpty,
      correct: matchesAccepted(text, typed.accepted),
      text: text.trim(),
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// ── Q04 Type the answer ─────────────────────────────────────────────────────

class TypeAnswerQuestion extends StatefulWidget {
  const TypeAnswerQuestion({
    super.key,
    required this.data,
    required this.phase,
    required this.onChanged,
  });

  final TypeAnswerData data;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<TypeAnswerQuestion> createState() => _TypeAnswerQuestionState();
}

class _TypeAnswerQuestionState extends State<TypeAnswerQuestion>
    with _TypedState<TypeAnswerQuestion> {
  @override
  TypedQuestion get typed => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final toHil = widget.data.direction == TypeDirection.filToHil;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(
          toHil ? t.q04TitleToHil : t.q04TitleToFil,
          hint: toHil ? t.q04HintToHil : t.q04HintToFil,
        ),
        const SizedBox(height: 12),
        // The card shows the source language: Filipino when typing Hiligaynon.
        PromptCard(
          label: toHil ? t.filipinoName : t.hiligaynonLabel,
          text: widget.data.text,
        ),
        const SizedBox(height: 12),
        QuizTextField(
          controller: controller,
          enabled: widget.phase == QuestionPhase.answering,
          onChanged: report,
        ),
      ],
    );
  }
}

// ── Q08 Dictation ───────────────────────────────────────────────────────────

class DictationQuestion extends StatefulWidget {
  const DictationQuestion({
    super.key,
    required this.data,
    required this.phase,
    required this.onChanged,
  });

  final DictationData data;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<DictationQuestion> createState() => _DictationQuestionState();
}

class _DictationQuestionState extends State<DictationQuestion>
    with _TypedState<DictationQuestion> {
  @override
  TypedQuestion get typed => widget.data;
  @override
  AnswerChanged get onChanged => widget.onChanged;

  /// Word bank chips already put in the answer (shown as used).
  final Set<int> _used = {};

  void _insert(int i) {
    final word = widget.data.wordBank[i];
    final text = controller.text.trimRight();
    controller.text = text.isEmpty ? word : '$text $word';
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    setState(() => _used.add(i));
    report(controller.text);
  }

  void _onTyped(String text) {
    // Clearing the field gives the chips back.
    if (text.trim().isEmpty && _used.isNotEmpty) setState(_used.clear);
    report(text);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final answering = widget.phase == QuestionPhase.answering;
    final bank = widget.data.wordBank;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: t.q08Hint),
        const SizedBox(height: 12),
        BigAudioButtons(clip: widget.data.audio),
        const SizedBox(height: 12),
        QuizTextField(controller: controller, enabled: answering, onChanged: _onTyped),
        if (bank.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(t.wordBankLabel, style: V6Text.labelMediumBold.copyWith(color: V6Colors.textMuted)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < bank.length; i++)
                WordTile(
                  label: bank[i],
                  state: _used.contains(i) ? TileState.disabled : TileState.idle,
                  onTap: answering && !_used.contains(i) ? () => _insert(i) : null,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
