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
/// Dialogues with line clips get "Play conversation"; a `listening` one hides its text until the audio has played once
/// (or "Show text"). While the clips aren't recorded, the text shows with "Audio coming soon".
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

  /// Listening mode: the text stays hidden until this is true.
  bool _revealed = false;

  bool get _hidden => widget.data.listening && widget.data.clips.isNotEmpty && !_revealed;

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
    if (finished && mounted) setState(() => _revealed = true);
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
            _ListenBar(onPlay: () => _play(), onPlaySlow: () => _play(slow: true)),
          const SizedBox(height: 12),
        ],
        if (_hidden) ...[
          Text(t.listenFirstHint, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _revealed = true),
              icon: const Icon(Icons.visibility_rounded),
              label: Text(t.showText),
            ),
          ),
        ] else ...[
          ShowAllSwitch(label: t.showAllFilipino, value: _showAll, onChanged: _setAll),
          const SizedBox(height: 12),
          Text(t.dialogueHint, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
          const SizedBox(height: 12),
          for (var i = 0; i < data.lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            ChatLine(
              speaker: data.lines[i].speaker,
              avatar: widget.avatars.avatarFor(data.lines[i].speaker),
              bubble: _Bubble(
                line: data.lines[i],
                shown: _shown.contains(i),
                onTap: () => _toggle(i),
              ),
            ),
          ],
          if (data.tip != null) TipCard(data.tip!),
        ],
      ],
    );
  }
}

/// "Play conversation" (all line clips in order) and the slow button beside it.
class _ListenBar extends StatelessWidget {
  const _ListenBar({required this.onPlay, required this.onPlaySlow});

  final VoidCallback onPlay;
  final VoidCallback onPlaySlow;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onPlay,
              style: FilledButton.styleFrom(
                backgroundColor: V6Colors.primary,
                foregroundColor: V6Colors.onPrimary,
                textStyle: V6Text.button,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.volume_up_rounded),
              label: Text(t.playConversation),
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
