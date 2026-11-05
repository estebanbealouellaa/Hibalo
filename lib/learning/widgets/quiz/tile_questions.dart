import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../logic/quiz_logic.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import 'question_contract.dart';
import 'quiz_common.dart';

// ── Q05 Build the sentence ──────────────────────────────────────────────────

/// The Filipino `prompt`, then the word tiles (shuffled; one is a
/// distractor). Tap a tile to move it into the answer line; tap it there to
/// send it back. Check compares with `answer` in order.
class BuildSentenceQuestion extends StatefulWidget {
  const BuildSentenceQuestion({
    super.key,
    required this.data,
    required this.order,
    required this.phase,
    required this.onChanged,
  });

  final BuildSentenceData data;

  /// Tile indexes in the order the bank shows them.
  final List<int> order;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<BuildSentenceQuestion> createState() => _BuildSentenceQuestionState();
}

class _BuildSentenceQuestionState extends State<BuildSentenceQuestion> {
  /// Tile indexes in the answer line, in order.
  final List<int> _picked = [];

  void _toggle(int tile) {
    setState(() => _picked.contains(tile) ? _picked.remove(tile) : _picked.add(tile));
    widget.onChanged(AnswerState(
      ready: _picked.isNotEmpty,
      correct: isRightSentence(widget.data, _picked),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final answering = widget.phase == QuestionPhase.answering;
    final tiles = widget.data.tiles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(t.q05Title, hint: t.q05Hint),
        const SizedBox(height: 12),
        PromptCard(label: t.filipinoName, text: widget.data.prompt),
        const SizedBox(height: 12),
        // Figma "Answer line": at least 64 high, 2 px divider under it.
        Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: V6Colors.borderDivider, width: 2)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in _picked)
                WordTile(
                  label: tiles[i],
                  state: TileState.selected,
                  onTap: answering ? () => _toggle(i) : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final i in widget.order)
              WordTile(
                label: tiles[i],
                state: _picked.contains(i) ? TileState.disabled : TileState.idle,
                onTap: answering && !_picked.contains(i) ? () => _toggle(i) : null,
              ),
          ],
        ),
      ],
    );
  }
}

// ── Q07 Match pairs ─────────────────────────────────────────────────────────

/// Hiligaynon on the left, Filipino on the right (right column shuffled).
/// Tap one on each side: a right pair turns green and locks; a wrong pair
/// flashes red and resets. Check is enabled when every pair is matched. The
/// question counts as right only if there were no wrong taps (§4, §7).
class MatchPairsQuestion extends StatefulWidget {
  const MatchPairsQuestion({
    super.key,
    required this.data,
    required this.rightOrder,
    required this.phase,
    required this.onChanged,
    this.flash = const Duration(milliseconds: 600),
  });

  final MatchPairsData data;

  /// Pair indexes in the order the right (Filipino) column shows them.
  final List<int> rightOrder;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  /// How long a wrong pair stays red.
  final Duration flash;

  @override
  State<MatchPairsQuestion> createState() => _MatchPairsQuestionState();
}

class _MatchPairsQuestionState extends State<MatchPairsQuestion> {
  int? _left;
  int? _right;
  final Set<int> _matched = {};
  int _wrongTaps = 0;

  /// The wrong pair being flashed red.
  (int, int)? _flashing;
  Timer? _flashTimer;

  @override
  void dispose() {
    _flashTimer?.cancel();
    super.dispose();
  }

  void _tapLeft(int i) => _select(left: i);
  void _tapRight(int i) => _select(right: i);

  void _select({int? left, int? right}) {
    if (_flashing != null) return;
    setState(() {
      if (left != null) _left = _left == left ? null : left;
      if (right != null) _right = _right == right ? null : right;
    });
    final l = _left, r = _right;
    if (l == null || r == null) return;
    if (l == r) {
      setState(() {
        _matched.add(l);
        _left = _right = null;
      });
    } else {
      _wrongTaps++;
      setState(() => _flashing = (l, r));
      _flashTimer = Timer(widget.flash, () {
        if (!mounted) return;
        setState(() {
          _flashing = null;
          _left = _right = null;
        });
      });
    }
    widget.onChanged(AnswerState(
      ready: _matched.length == widget.data.pairs.length,
      correct: _wrongTaps == 0,
    ));
  }

  TileState _stateOf(int pair, {required bool left}) {
    if (_matched.contains(pair)) return TileState.matched;
    final flash = _flashing;
    if (flash != null && (left ? flash.$1 : flash.$2) == pair) return TileState.wrong;
    final selected = left ? _left : _right;
    return selected == pair ? TileState.selected : TileState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.data.pairs;
    final answering = widget.phase == QuestionPhase.answering;
    Widget column(List<int> order, {required bool left}) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var n = 0; n < order.length; n++) ...[
              if (n > 0) const SizedBox(height: 12),
              WordTile(
                expand: true,
                label: left ? pairs[order[n]].hil : pairs[order[n]].fil,
                state: _stateOf(order[n], left: left),
                onTap: answering && !_matched.contains(order[n])
                    ? () => left ? _tapLeft(order[n]) : _tapRight(order[n])
                    : null,
              ),
            ],
          ],
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: column(List.generate(pairs.length, (i) => i), left: true)),
            const SizedBox(width: 12),
            Expanded(child: column(widget.rightOrder, left: false)),
          ],
        ),
      ],
    );
  }
}
