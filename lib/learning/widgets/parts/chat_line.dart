import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';

/// The learner's side of a chat (right, violet): Ana, and "You" in the lessons that use it.
bool isLearnerSpeaker(String speaker) => speaker == 'Ana' || speaker == 'You';

/// Bubble shape from Figma "Bubble": 18 radius, 6 on the corner by the avatar.
BorderRadius chatBubbleRadius({required bool mine}) => BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(mine ? 18 : 6),
      bottomRight: Radius.circular(mine ? 6 : 18),
    );

/// 36 × 36 round avatar from settings.avatars (initial if the file is missing).
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({super.key, required this.path, required this.speaker});

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

/// One chat line: name above a 232-wide bubble, the avatar beside it at the bottom.
/// Learner lines sit on the right in violet; everyone else on the left.
class ChatLine extends StatelessWidget {
  const ChatLine({
    super.key,
    required this.speaker,
    required this.avatar,
    required this.bubble,
    this.nameTrailing,
  });

  final String speaker;

  /// SVG asset path, or null if the file is missing.
  final String? avatar;
  final Widget bubble;

  /// A small label after the name (P11 "Talking fast").
  final Widget? nameTrailing;

  @override
  Widget build(BuildContext context) {
    final mine = isLearnerSpeaker(speaker);
    final message = Flexible(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 232),
        child: SizedBox(
          width: 232,
          child: Column(
            crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(speaker, style: V6Text.captionSemiBold.copyWith(color: V6Colors.textSecondary)),
                  if (nameTrailing != null) ...[const SizedBox(width: 6), nameTrailing!],
                ],
              ),
              const SizedBox(height: 4),
              bubble,
            ],
          ),
        ),
      ),
    );
    final face = ChatAvatar(path: avatar, speaker: speaker);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: mine
          ? [message, const SizedBox(width: 8), face]
          : [face, const SizedBox(width: 8), message],
    );
  }
}
