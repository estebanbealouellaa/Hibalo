import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/questions.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../../services/lesson_audio.dart';
import '../parts/part_common.dart' show AudioButton;

/// Building blocks shared by the Q01–Q10 widgets, sized from the Figma
/// "09 · Quiz" frames.

/// "Question Type Chip": Choose = citrus, Listening = lagoon, Speaking =
/// coral, Writing = orange-yellow (Figma component description).
class QuestionTypeChip extends StatelessWidget {
  const QuestionTypeChip({super.key, required this.question});

  final QuizQuestion question;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (label, icon, background, foreground) = switch (question) {
      MultipleChoiceData() => (t.qtChoose, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      ListeningData() => (t.qtListening, Icons.volume_up_rounded, V6Colors.lagoonContainer, V6Colors.lagoonText),
      FillBlankData() => (t.qtFillBlank, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      TypeAnswerData() => (t.qtTypeAnswer, Icons.content_paste_rounded, V6Colors.glowTonal, V6Colors.glowText),
      BuildSentenceData() => (t.qtBuildSentence, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      RealSituationData() => (t.qtRealSituation, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      MatchPairsData() => (t.qtMatchPairs, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      DictationData() => (t.qtDictation, Icons.volume_up_rounded, V6Colors.lagoonContainer, V6Colors.lagoonText),
      SpeakingData() => (t.qtSpeaking, Icons.mic_rounded, V6Colors.coralContainer, V6Colors.coralText),
      OpenAnswerData() => (t.qtOpenAnswer, Icons.content_paste_rounded, V6Colors.glowTonal, V6Colors.glowText),
      // Figma Q11: "Reading" is citrus; listen mode uses the Listening chip (lagoon).
      ReadAnswerData(mode: ReadAnswerMode.read) =>
        (t.qtReading, Icons.check_circle_rounded, V6Colors.citrusContainer, V6Colors.citrusText),
      ReadAnswerData(mode: ReadAnswerMode.listen) =>
        (t.qtListening, Icons.volume_up_rounded, V6Colors.lagoonContainer, V6Colors.lagoonText),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: ShapeDecoration(color: background, shape: const StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 6),
          // Shrinks with an ellipsis on narrow phones or large text.
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: V6Text.labelMediumBold.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// "XP Chip": "+10 XP" on scored questions.
class QuizXpChip extends StatelessWidget {
  const QuizXpChip({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: const ShapeDecoration(color: V6Colors.citrus, shape: StadiumBorder()),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt_rounded, size: 16, color: V6Colors.onCitrus),
          const SizedBox(width: 4),
          Text(AppLocalizations.of(context).xpGain(xp), style: V6Text.labelXp.copyWith(color: V6Colors.onCitrus)),
        ],
      ),
    );
  }
}

/// The question title (Headline/Medium · ExtraBold) and the grey line under
/// it (Body/Medium, Text/Muted).
class QuizTitle extends StatelessWidget {
  const QuizTitle(this.title, {super.key, this.hint});

  final String title;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: V6Text.headlineMediumExtraBold),
        if (hint != null) ...[
          const SizedBox(height: 12),
          Text(hint!, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
        ],
      ],
    );
  }
}

/// Figma "Prompt" card: a small language label, the big text, an optional line and optional content.
class PromptCard extends StatelessWidget {
  const PromptCard({
    super.key,
    required this.label,
    required this.text,
    this.sub,
    this.child,
    this.textStyle,
  });

  final String label;
  final String text;

  /// Overrides the big Hiligaynon style (a long transcript uses body text).
  final TextStyle? textStyle;
  final String? sub;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: V6Colors.glowContainerSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: V6Colors.glow),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: V6Text.labelMediumBold.copyWith(color: V6Colors.glowText)),
          const SizedBox(height: 6),
          Text(text, style: textStyle ?? V6Text.hilResultExtraBold),
          if (sub != null) ...[
            const SizedBox(height: 6),
            Text(sub!, style: V6Text.bodyMedium.copyWith(color: V6Colors.textMuted)),
          ],
          if (child != null) ...[
            const SizedBox(height: 6),
            child!,
          ],
        ],
      ),
    );
  }
}

enum TileState { idle, selected, disabled, matched, wrong }

/// "Word Tile": padding 16/12, radius 12, Body/Large · Bold. Default /
/// Selected (violet) / Disabled (used) / Matched (green); Wrong flashes red.
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.label,
    this.state = TileState.idle,
    this.onTap,
    this.expand = false,
  });

  final String label;
  final TileState state;
  final VoidCallback? onTap;

  /// Fill the width and centre the text (Q07 columns).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final (background, border, width, foreground) = switch (state) {
      TileState.idle => (V6Colors.surface, V6Colors.borderDivider, 1.0, V6Colors.textPrimary),
      TileState.selected => (V6Colors.primaryContainer, V6Colors.primary, 2.0, V6Colors.primary),
      TileState.disabled => (V6Colors.neutralBackground, V6Colors.borderDivider, 2.0, V6Colors.textDisabled),
      TileState.matched => (V6Colors.successContainer, V6Colors.success, 2.0, V6Colors.success),
      TileState.wrong => (V6Colors.errorContainer, V6Colors.error, 2.0, V6Colors.error),
    };
    final text = Text(
      label,
      textAlign: expand ? TextAlign.center : TextAlign.start,
      style: V6Text.bodyLargeBold.copyWith(color: foreground),
    );
    return Semantics(
      button: onTap != null,
      selected: state == TileState.selected,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border, width: width),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: expand ? Alignment.center : null,
            padding: EdgeInsets.symmetric(horizontal: expand ? 10 : 16, vertical: 12),
            child: expand ? text : Row(mainAxisSize: MainAxisSize.min, children: [text]),
          ),
        ),
      ),
    );
  }
}

/// "Text Field": "Your answer" label above a 52 px white field; border
/// Border/Neutral, 2 px Primary when focused, radius 12.
class QuizTextField extends StatelessWidget {
  const QuizTextField({
    super.key,
    required this.controller,
    required this.enabled,
    this.onChanged,
    this.focusNode,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(V6Spacing.radiusMedium),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(t.yourAnswer, style: V6Text.labelLarge.copyWith(color: V6Colors.textNeutralStrong)),
        const SizedBox(height: 8),
        SizedBox(
          height: 52,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            onChanged: onChanged,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.sentences,
            style: V6Text.bodyLarge,
            cursorColor: V6Colors.primary,
            decoration: InputDecoration(
              filled: true,
              fillColor: V6Colors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: border(V6Colors.borderNeutral, 1),
              disabledBorder: border(V6Colors.borderDivider, 1),
              focusedBorder: border(V6Colors.primary, 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// The 88 px play button and the 48 px slow button side by side. Nothing is
/// shown when [clip] is null (not recorded yet). [clips] plays a whole conversation instead.
class BigAudioButtons extends StatelessWidget {
  const BigAudioButtons({super.key, required this.clip}) : clips = null;

  BigAudioButtons.conversation({super.key, required List<String> this.clips})
      : clip = clips.isEmpty ? null : clips.first;

  final String? clip;
  final List<String>? clips;

  @override
  Widget build(BuildContext context) {
    if (clip == null) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    final all = clips;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AudioButton(
            clip: clip,
            label: t.playAudio,
            size: 88,
            iconSize: 28,
            onPressed: all == null ? null : () => LessonAudio.instance.playAll(all),
          ),
          const SizedBox(width: 16),
          AudioButton(
            clip: clip,
            label: t.playSlow,
            slow: true,
            size: 48,
            iconSize: 24,
            background: V6Colors.primaryContainer,
            foreground: V6Colors.primary,
            onPressed: all == null ? null : () => LessonAudio.instance.playAll(all, slow: true),
          ),
        ],
      ),
    );
  }
}

/// The play buttons, or, while the clip isn't recorded, its Hiligaynon words ([text]) in a prompt card
/// with "Audio coming soon" (Q02, Q08, Q10, Q11 listen). With no [text] only the note shows.
class AudioOrText extends StatelessWidget {
  const AudioOrText({super.key, required this.buttons, required this.missing, required this.text});

  final Widget buttons;

  /// The clip isn't in the app.
  final bool missing;
  final String? text;

  @override
  Widget build(BuildContext context) {
    if (!missing) return buttons;
    final t = AppLocalizations.of(context);
    final words = text;
    if (words == null) {
      return Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textMuted));
    }
    return PromptCard(
      label: t.hiligaynonLabel,
      text: words,
      // A word or short line stays big; a longer passage (e.g. the i10 transcript) is body text.
      textStyle: words.length > 40 ? V6Text.bodyLargeSemiBold : null,
      child: Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
    );
  }
}
