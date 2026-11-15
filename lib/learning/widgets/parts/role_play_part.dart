import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/catalog.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'chat_line.dart';
import 'part_common.dart';
import '../markup_text.dart';

/// P11 Role-play (Figma "P11 · Part · Role-play · Choose / Right choice / Not quite / Done"):
/// the other speaker says a line, the learner picks a reply. Right → Ana's reply bubble and the next
/// turn; wrong → "Not quite: hint", try again (no penalty). Text only, no audio, no XP.
class RolePlayPart extends StatefulWidget {
  const RolePlayPart({
    super.key,
    required this.data,
    required this.avatars,
    required this.answered,
    required this.onAnswered,
    required this.onDone,
    this.shuffle = true,
    this.random,
  });

  final RolePlayPartData data;
  final AvatarRules avatars;

  /// Turns already answered (kept by the player, so going back shows the chat).
  final int answered;

  /// A right reply: the new number of answered turns.
  final ValueChanged<int> onAnswered;

  /// The chat is finished and the last right reply has settled: Next can be enabled.
  final VoidCallback onDone;

  final bool shuffle;
  final Random? random;

  /// How long the right reply stays green before the next choices (Figma "Right choice").
  static const rightPause = Duration(milliseconds: 900);

  @override
  State<RolePlayPart> createState() => _RolePlayPartState();
}

class _RolePlayPartState extends State<RolePlayPart> {
  late int _answered = widget.answered;

  /// The wrong choice just tapped on this turn, or null.
  RolePlayChoice? _wrong;

  /// The right choice shown green for a moment, or null.
  RolePlayChoice? _right;
  Timer? _rightTimer;

  final Map<int, List<RolePlayChoice>> _orders = {};
  final _bottomKey = GlobalKey();
  late final Random _random = widget.random ?? Random();

  List<RolePlayTurn> get _turns => widget.data.turns;

  /// Turns with choices: the chat is done when all of them are answered.
  int get _toAnswer => _turns.where((t) => t.choices.isNotEmpty).length;

  bool get _done => _answered >= _toAnswer;

  @override
  void initState() {
    super.initState();
    if (_done) WidgetsBinding.instance.addPostFrameCallback((_) => widget.onDone());
  }

  @override
  void dispose() {
    _rightTimer?.cancel();
    super.dispose();
  }

  List<RolePlayChoice> _choicesOf(int turn) => _orders.putIfAbsent(turn, () {
        final choices = [..._turns[turn].choices];
        if (widget.shuffle) choices.shuffle(_random);
        return choices;
      });

  void _choose(RolePlayChoice choice) {
    if (_right != null || _done) return;
    if (!choice.correct) {
      setState(() => _wrong = choice);
      return;
    }
    setState(() {
      _wrong = null;
      _right = choice;
      _answered++;
    });
    widget.onAnswered(_answered);
    _scrollToBottom();
    _rightTimer = Timer(RolePlayPart.rightPause, () {
      if (!mounted) return;
      setState(() => _right = null);
      if (_done) widget.onDone();
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _bottomKey.currentContext;
      if (context == null || !context.mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    // Turn i shows once every turn before it is answered.
    final visible = min(_answered + 1, _turns.length);
    final chat = <Widget>[];
    for (var i = 0; i < visible; i++) {
      final turn = _turns[i];
      chat.add(ChatLine(
        speaker: turn.speaker,
        displayName: widget.avatars.nameFor(turn.speaker),
        avatar: widget.avatars.avatarFor(turn.speaker),
        nameTrailing: turn.fast ? SmallChip(t.rolePlayFast) : null,
        bubble: _ChatBubble(hil: turn.hil, fil: turn.fil, mine: isLearnerSpeaker(turn.speaker)),
      ));
      // Figma "Quoted line": what someone else said, under the speaker's bubble (44 in, 232 wide).
      if (turn.quote case final quote?) {
        chat.add(Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 232),
              child: Text(
                quote,
                style: V6Text.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: V6Colors.textSecondary),
              ),
            ),
          ),
        ));
      }
      if (i < _answered && turn.correctChoice != null) {
        final reply = turn.correctChoice!;
        chat.add(ChatLine(
          speaker: 'Ana',
          avatar: widget.avatars.avatarFor('Ana'),
          bubble: _ChatBubble(hil: reply.hil, fil: reply.fil, mine: true),
        ));
      }
    }

    final current = _done ? null : _turns[_answered];
    return PartLayout(
      children: [
        // Figma P11: 12 between blocks, 8 between replies.
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 12),
        Text(data.setting, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
        if (!_done || _right != null) ...[
          const SizedBox(height: 12),
          Text(t.rolePlayInstruction, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < chat.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          chat[i],
        ],
        if (_right != null) ...[
          const SizedBox(height: 12),
          ReplyOption(choice: _right!, state: ReplyState.right),
        ] else if (current != null) ...[
          if (current.cue != null) ...[
            const SizedBox(height: 12),
            _CueLine(current.cue!),
          ],
          const SizedBox(height: 12),
          for (final (n, choice) in _choicesOf(_answered).indexed) ...[
            if (n > 0) const SizedBox(height: 8),
            ReplyOption(
              choice: choice,
              state: identical(choice, _wrong) ? ReplyState.wrong : ReplyState.idle,
              onTap: () => _choose(choice),
            ),
          ],
          if (_wrong != null) ...[
            const SizedBox(height: 12),
            MarkupText(
              t.rolePlayNotQuite(_wrong!.hint ?? ''),
              exampleColor: V6Colors.error,
              style: V6Text.bodyMedium.copyWith(color: V6Colors.error),
            ),
          ],
        ] else if (data.tip != null)
          TipCard(data.tip!, top: 12),
        SizedBox(key: _bottomKey, height: 0),
      ],
    );
  }
}

/// A role-play bubble: the Hiligaynon, and the Filipino under it when there is one.
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.hil, required this.fil, required this.mine});

  final String hil;
  final String? fil;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    // Figma "Bubble": 232 wide, padding 14/10.
    return Container(
      width: 232,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: mine ? V6Colors.primary : V6Colors.primaryContainer,
        borderRadius: chatBubbleRadius(mine: mine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(hil, style: V6Text.bodyLargeSemiBold.copyWith(color: mine ? V6Colors.onPrimary : V6Colors.textPrimary)),
          if (fil != null) ...[
            const SizedBox(height: 2),
            Text(
              fil!,
              style: V6Text.bodyMedium.copyWith(color: mine ? V6Colors.onPrimaryMuted : V6Colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

/// Figma "Cue line" (P11 compatibility variant): a lagoon strip with an info icon, italic text.
class _CueLine extends StatelessWidget {
  const _CueLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: V6Colors.lagoonContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.info_rounded, size: 18, color: V6Colors.lagoonText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: V6Text.bodyMedium.copyWith(fontStyle: FontStyle.italic, color: V6Colors.lagoonText),
            ),
          ),
        ],
      ),
    );
  }
}

enum ReplyState { idle, right, wrong }

/// Figma "Reply Option" (791:7754): the Hiligaynon reply and its small Filipino meaning.
class ReplyOption extends StatelessWidget {
  const ReplyOption({super.key, required this.choice, required this.state, this.onTap});

  final RolePlayChoice choice;
  final ReplyState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (background, border, icon, iconColor) = switch (state) {
      ReplyState.idle => (V6Colors.surface, V6Colors.borderDivider, Icons.radio_button_unchecked_rounded, V6Colors.textMuted),
      ReplyState.right => (V6Colors.successContainer, V6Colors.success, Icons.check_circle_rounded, V6Colors.success),
      ReplyState.wrong => (V6Colors.errorContainer, V6Colors.error, Icons.close_rounded, V6Colors.error),
    };
    final marked = state != ReplyState.idle;
    return Semantics(
      button: onTap != null,
      selected: marked,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border, width: marked ? 2 : 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          // Figma: min 56 high, padding 16/12, 12 between marker and text.
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small grey label above the reply (Lance, Nov 12), e.g. "Filipino, to your friend".
                      if (choice.note case final note?) ...[
                        Text(note, style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
                        const SizedBox(height: 2),
                      ],
                      Text(choice.hil, style: marked ? V6Text.bodyLargeSemiBold : V6Text.bodyLarge),
                      if (choice.fil != null) ...[
                        const SizedBox(height: 2),
                        Text(choice.fil!, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
