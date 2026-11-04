import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/catalog.dart';
import '../../models/parts.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import 'part_common.dart';

/// P07 · Dialogue: chat bubbles, Ana on the right in violet, everyone else
/// on the left in light violet, each with a name and a round avatar. Tap a
/// bubble to show or hide its Filipino; the switch shows or hides all of
/// them. Text only, no audio. The tip card closes the chat.
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = widget.data;
    return PartLayout(
      children: [
        PartHeader(icon: data.icon, title: data.title),
        const SizedBox(height: 12),
        Text(data.setting, style: V6Text.bodyLarge),
        const SizedBox(height: 8),
        ShowAllSwitch(label: t.showAllFilipino, value: _showAll, onChanged: _setAll),
        Text(t.dialogueHint, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
        const SizedBox(height: 12),
        for (var i = 0; i < data.lines.length; i++)
          _Bubble(
            line: data.lines[i],
            avatar: widget.avatars.avatarFor(data.lines[i].speaker),
            shown: _shown.contains(i),
            onTap: () => _toggle(i),
          ),
        if (data.tip != null) TipCard(data.tip!),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.line,
    required this.avatar,
    required this.shown,
    required this.onTap,
  });

  final DialogueLine line;

  /// SVG asset path, or null if the file is missing.
  final String? avatar;
  final bool shown;
  final VoidCallback onTap;

  /// Ana is the learner's side (right, violet); everyone else is on the left.
  bool get _mine => line.speaker == 'Ana';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (background, main, sub) = _mine
        ? (V6Colors.primary, V6Colors.onPrimary, V6Colors.onPrimaryMuted)
        : (V6Colors.primaryContainer, V6Colors.textPrimary, V6Colors.textSecondary);
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(_mine ? 18 : 4),
      bottomRight: Radius.circular(_mine ? 4 : 18),
    );

    final bubble = Flexible(
      child: Semantics(
        button: true,
        child: Material(
          color: background,
          shape: RoundedRectangleBorder(borderRadius: radius),
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(line.hil, style: V6Text.bodyLargeBold.copyWith(color: main)),
                  if (shown)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(line.fil, style: V6Text.bodyMedium.copyWith(color: sub)),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    shown ? t.tapToHideFilipino : t.tapToSeeFilipino,
                    style: V6Text.caption.copyWith(color: sub),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final face = _Avatar(path: avatar, speaker: line.speaker);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: _mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: _mine ? 0 : 44, right: _mine ? 44 : 0, bottom: 4),
            child: Text(line.speaker, style: V6Text.labelMediumBold.copyWith(color: V6Colors.textSecondary)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: _mine ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: _mine
                ? [const SizedBox(width: 40), bubble, const SizedBox(width: 8), face]
                : [face, const SizedBox(width: 8), bubble, const SizedBox(width: 40)],
          ),
        ],
      ),
    );
  }
}

/// 36 × 36 round avatar from settings.avatars (initial if the file is missing).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.path, required this.speaker});

  final String? path;
  final String speaker;

  @override
  Widget build(BuildContext context) {
    final initial = Container(
      color: V6Colors.glowTonal,
      alignment: Alignment.center,
      child: Text(speaker.isEmpty ? '?' : speaker[0], style: V6Text.labelLargeBold),
    );
    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox(
          width: 36,
          height: 36,
          child: path == null
              ? initial
              : SvgPicture.asset(
                  path!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => initial,
                ),
        ),
      ),
    );
  }
}
