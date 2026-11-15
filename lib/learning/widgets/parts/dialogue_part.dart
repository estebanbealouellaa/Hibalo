import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/catalog.dart';
import '../../models/parts.dart';
import '../../services/lesson_audio.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'chat_line.dart';
import 'part_common.dart';

/// P07 Dialogue: the learner (Ana / You) on the right in violet, others on the left; tap a bubble (or the switch) for the Filipino.
/// Dialogues with line clips get "Play conversation"; a `listening` one (Figma "P07 · Listening mode" + "After playing")
/// shows grey placeholder bubbles until the audio has played once or "Show text" is tapped, and has no Show all switch.
/// While the clips aren't recorded, the text shows with "Audio coming soon".
class DialoguePart extends StatefulWidget {
  const DialoguePart({super.key, required this.data, required this.avatars});

  final DialoguePartData data;
  final AvatarRules avatars;

  @override
  State<DialoguePart> createState() => _DialoguePartState();
}

class _DialoguePartState extends State<DialoguePart> {
  final Set<int> _shown = {};
  bool _showAll = false;

  /// Listening mode: the text stays hidden until this is true ("Show text" / "Hide text" toggles it).
  bool _revealed = false;

  /// The conversation has played to the end once ("Play again").
  bool _played = false;

  /// Listening mode with its clips in the app.
  bool get _listening => widget.data.listening && widget.data.clips.isNotEmpty;

  bool get _hidden => _listening && !_revealed;

  void _setAll(bool on) {
    setState(() {
      _showAll = on;
      _shown.clear();
      if (on) _shown.addAll(List.generate(widget.data.lines.length, (i) => i));
    });
  }

  void _toggle(int i) {
    setState(() => _shown.contains(i) ? _shown.remove(i) : _shown.add(i));
  }

  Future<void> _play({bool slow = false}) async {
    final finished = await LessonAudio.instance.playAll(widget.data.clips, slow: slow);
    if (finished && mounted) {
      setState(() {
        _played = true;
        _revealed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    return PartLayout(
      children: [
        // Figma P07: 12 between blocks, 10 between chat lines.
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 12),
        if (data.setting case final setting?) ...[
          Text(setting, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 12),
        ],
        if (data.hasClips) ...[
          if (data.clips.isEmpty)
            Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textSecondary))
          else
            _ListenBar(
              label: _played ? t.playAgain : t.playConversation,
              onPlay: () => _play(),
              onPlaySlow: () => _play(slow: true),
            ),
          const SizedBox(height: 12),
        ],
        if (_listening) ...[
          // Figma "Link · Show text": a text button, 48 high.
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              style: TextButton.styleFrom(
                foregroundColor: V6Colors.primary,
                textStyle: V6Text.button,
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: Text(_revealed ? t.hideText : t.showText),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _hidden ? t.listenFirstHint : t.listeningTapHint,
            style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
          ),
        ] else ...[
          ShowAllSwitch(label: t.showAllFilipino, value: _showAll, onChanged: _setAll),
          const SizedBox(height: 12),
          Text(t.dialogueHint, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
        ],
        const SizedBox(height: 12),
        for (var i = 0; i < data.lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          ChatLine(
            speaker: data.lines[i].speaker,
            displayName: widget.avatars.nameFor(data.lines[i].speaker),
            avatar: widget.avatars.avatarFor(data.lines[i].speaker),
            bubble: _hidden
                ? _PlaceholderBubble(mine: isLearnerSpeaker(data.lines[i].speaker))
                : _Bubble(
                    line: data.lines[i],
                    shown: _shown.contains(i),
                    onTap: () => _toggle(i),
                  ),
          ),
        ],
        if (data.tip != null && !_hidden) TipCard(data.tip!),
      ],
    );
  }
}

/// Figma "Listening controls": "Play conversation" with a play arrow (all line clips in order; "Play again" after)
/// and the slow button.
class _ListenBar extends StatelessWidget {
  const _ListenBar({required this.label, required this.onPlay, required this.onPlaySlow});

  final String label;
  final VoidCallback onPlay;
  final VoidCallback onPlaySlow;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onPlay,
              iconAlignment: IconAlignment.end,
              style: FilledButton.styleFrom(
                backgroundColor: V6Colors.primary,
                foregroundColor: V6Colors.onPrimary,
                textStyle: V6Text.button,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(label),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: t.playSlow,
          excludeSemantics: true,
          child: Material(
            color: V6Colors.primaryContainer,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPlaySlow,
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(Icons.hourglass_top_rounded, color: V6Colors.primary, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Figma "Placeholder bar" bubble: the line is hidden until the conversation has played.
class _PlaceholderBubble extends StatelessWidget {
  const _PlaceholderBubble({required this.mine});

  final bool mine;

  @override
  Widget build(BuildContext context) {
    Widget bar(double width) => Container(
          width: width,
          height: 12,
          decoration: BoxDecoration(color: V6Colors.borderNeutral, borderRadius: BorderRadius.circular(6)),
        );
    return ExcludeSemantics(
      child: Container(
        width: 232,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: V6Colors.neutralBackground,
          borderRadius: chatBubbleRadius(mine: mine),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [bar(168), const SizedBox(height: 2), bar(112)],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.line,
    required this.shown,
    required this.onTap,
  });

  final DialogueLine line;
  final bool shown;
  final VoidCallback onTap;

  bool get _mine => isLearnerSpeaker(line.speaker);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (background, main, sub) = _mine
        ? (V6Colors.primary, V6Colors.onPrimary, V6Colors.onPrimary)
        : (V6Colors.primaryContainer, V6Colors.textPrimary, V6Colors.textSecondary);
    // Figma "Bubble": 232 wide, padding 10/14/2, the corner by the avatar is 6.
    final radius = chatBubbleRadius(mine: _mine);

    return Semantics(
      button: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.hil, style: V6Text.bodyLargeSemiBold.copyWith(color: main)),
                if (shown) ...[
                  const SizedBox(height: 2),
                  Text(
                    line.fil,
                    style: V6Text.bodyMedium.copyWith(
                      color: _mine ? V6Colors.onPrimaryMuted : V6Colors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    shown ? t.tapToHideFilipino : t.tapToSeeFilipino,
                    style: V6Text.caption.copyWith(color: sub),
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
