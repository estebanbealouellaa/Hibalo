import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'question_contract.dart';
import 'quiz_common.dart';

/// Q12 Spot the mistake (Figma "Q12 · Quiz · Spot the mistake · Default / Word selected / Correct / Wrong
/// (+ Long sentence, Two-word fix)"): tap the wrong word, then Check. Tiles wrap; punctuation stays on its tile.
/// Right: the tile shows the fix in green. Wrong: the real mistake turns red with the fix chip under it and the
/// tapped tile goes grey. No timer.
class SpotMistakeQuestion extends StatefulWidget {
  const SpotMistakeQuestion({
    super.key,
    required this.data,
    required this.phase,
    required this.onChanged,
  });

  final SpotMistakeData data;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<SpotMistakeQuestion> createState() => _SpotMistakeQuestionState();
}

enum _TileLook { idle, selected, fixed, mistake, tappedWrong }

class _SpotMistakeQuestionState extends State<SpotMistakeQuestion> {
  int? _chosen;

  void _choose(int i) {
    setState(() => _chosen = i);
    final data = widget.data;
    widget.onChanged(AnswerState(ready: true, correct: i == data.wrongIndex, text: data.tiles[i]));
  }

  _TileLook _lookOf(int i) {
    final data = widget.data;
    if (widget.phase == QuestionPhase.answering) {
      return i == _chosen ? _TileLook.selected : _TileLook.idle;
    }
    if (i == data.wrongIndex) return _chosen == i ? _TileLook.fixed : _TileLook.mistake;
    return i == _chosen ? _TileLook.tappedWrong : _TileLook.idle;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    final answering = widget.phase == QuestionPhase.answering;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(data.prompt, hint: t.q12Hint),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            for (final (i, word) in data.tiles.indexed)
              _Tile(
                label: _lookOf(i) == _TileLook.fixed ? data.fix : word,
                look: _lookOf(i),
                fix: _lookOf(i) == _TileLook.mistake ? data.fix : null,
                onTap: answering ? () => _choose(i) : null,
              ),
          ],
        ),
        const SizedBox(height: 12),
        PromptCard(label: t.q12MeaningLabel, text: data.meaning),
      ],
    );
  }
}

/// Figma "Word Tile" (padding 16/12, radius 12, Body/Large · Bold) and its Q12 states; the mistake tile
/// has the Success fix chip 4 px under it.
class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.look, this.fix, this.onTap});

  final String label;
  final _TileLook look;
  final String? fix;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, width, text) = switch (look) {
      _TileLook.idle => (V6Colors.surface, V6Colors.borderDivider, 1.0, V6Colors.textPrimary),
      _TileLook.selected => (V6Colors.primaryContainer, V6Colors.primary, 2.0, V6Colors.primary),
      _TileLook.fixed => (V6Colors.successContainer, V6Colors.success, 2.0, V6Colors.success),
      _TileLook.mistake => (V6Colors.errorContainer, V6Colors.error, 2.0, V6Colors.textPrimary),
      _TileLook.tappedWrong => (V6Colors.neutralBackground, V6Colors.borderNeutral, 2.0, V6Colors.textPrimary),
    };
    final tile = Semantics(
      button: onTap != null,
      selected: look == _TileLook.selected,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: width),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              label,
              style: V6Text.bodyLargeBold.copyWith(
                color: text,
                decoration: look == _TileLook.mistake ? TextDecoration.lineThrough : null,
                decorationColor: V6Colors.error,
              ),
            ),
          ),
        ),
      ),
    );
    final fixLabel = fix;
    if (fixLabel == null) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        const SizedBox(height: 4),
        // Figma Chip · Success, 28 high, as wide as its text.
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const ShapeDecoration(color: V6Colors.successContainer, shape: StadiumBorder()),
          child: Center(
            widthFactor: 1,
            child: Text(fixLabel, style: V6Text.labelMedium.copyWith(color: V6Colors.success)),
          ),
        ),
      ],
    );
  }
}
