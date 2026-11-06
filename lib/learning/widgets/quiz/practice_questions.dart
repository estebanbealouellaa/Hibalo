import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../models/questions.dart';
import '../../services/lesson_audio.dart';
import '../../services/voice_recorder.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../parts/part_common.dart' show AudioButton;
import 'question_contract.dart';
import 'quiz_common.dart';

/// The unscored questions: Q09 Speaking and Q10 Open answer (§4).

/// Q09: Continue is enabled after one recording, or at once when the mic is refused or missing.
class SpeakingQuestion extends StatefulWidget {
  const SpeakingQuestion({
    super.key,
    required this.data,
    required this.recorder,
    required this.onChanged,
  });

  final SpeakingData data;

  /// Keeps the recording in memory only; the quiz clears it when it ends.
  final VoiceRecorder recorder;
  final AnswerChanged onChanged;

  @override
  State<SpeakingQuestion> createState() => _SpeakingQuestionState();
}

enum _MicState { ready, recording, unavailable }

class _SpeakingQuestionState extends State<SpeakingQuestion> {
  _MicState _mic = _MicState.ready;
  bool _busy = false;

  bool get _recorded => widget.recorder.hasRecording;

  void _report() {
    widget.onChanged(AnswerState(
      ready: _mic != _MicState.recording && (_recorded || _mic == _MicState.unavailable),
    ));
  }

  Future<void> _tapMic() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_mic == _MicState.recording) {
        await widget.recorder.stop();
        if (mounted) setState(() => _mic = _MicState.ready);
      } else {
        await LessonAudio.instance.stop();
        final started = await widget.recorder.start();
        if (!mounted) return;
        setState(() => _mic = started ? _MicState.recording : _MicState.unavailable);
      }
    } finally {
      _busy = false;
    }
    if (mounted) _report();
  }

  @override
  void dispose() {
    if (_mic == _MicState.recording) widget.recorder.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final recording = _mic == _MicState.recording;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: t.q09Hint),
        const SizedBox(height: 10),
        PromptCard(
          label: t.hiligaynonLabel,
          text: widget.data.text,
          sub: widget.data.meaning,
          child: Row(
            children: [
              AudioButton(clip: widget.data.audio, label: t.nativeSpeaker, size: 64, iconSize: 28),
              const SizedBox(width: 8),
              Text(t.nativeSpeaker, style: V6Text.labelLargeBold.copyWith(color: V6Colors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _mic == _MicState.unavailable
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    t.micUnavailable,
                    textAlign: TextAlign.center,
                    style: V6Text.bodyLargeSemiBold.copyWith(color: V6Colors.coralText),
                  ),
                )
              : _MicButton(recording: recording, onTap: _tapMic),
        ),
        const SizedBox(height: 10),
        // Figma "Compare": Native speaker and You, side by side.
        Row(
          children: [
            Expanded(
              child: _CompareButton(
                label: t.nativeSpeaker,
                background: V6Colors.primaryContainer,
                foreground: V6Colors.primary,
                onTap: () => LessonAudio.instance.play(widget.data.audio),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CompareButton(
                label: t.youLabel,
                background: V6Colors.glowContainerSoft,
                foreground: V6Colors.glowText,
                onTap: _recorded && !recording ? widget.recorder.play : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "Mic Button": Ready = an 88 violet circle with the mic (160 box); while
/// recording, an 88 plum circle with Stop inside two lilac rings (144).
class _MicButton extends StatelessWidget {
  const _MicButton({required this.recording, required this.onTap});

  final bool recording;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: recording ? t.stopRecordingTooltip : t.recordTooltip,
      child: GestureDetector(
        onTap: onTap,
        // One 160 box for both states, so nothing below jumps when
        // recording starts (the rings are 144 inside it).
        child: SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (recording) ...[
                _circle(144, V6Colors.primaryContainer.withValues(alpha: 0.35)),
                _circle(116, V6Colors.primaryContainer.withValues(alpha: 0.6)),
              ],
              _circle(88, recording ? V6Colors.primaryStrong : V6Colors.primary),
              Icon(
                recording ? Icons.stop_rounded : Icons.mic_rounded,
                color: V6Colors.onPrimary,
                size: recording ? 30 : 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

/// "Play · Native speaker" / "Play · You": padding 16/14, radius 14.
/// Disabled ("You" before a recording) = 38% opacity.
class _CompareButton extends StatelessWidget {
  const _CompareButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.38 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            // One line, as in Figma: shrinks a little on narrow phones
            // rather than wrapping "Native speaker".
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 24, color: foreground),
                  const SizedBox(width: 8),
                  Text(label, maxLines: 1, style: V6Text.labelLargeBold.copyWith(color: foreground)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `prompt`, `hint` and a text field with an "N / maxChars characters"
/// counter. Submit (enabled when the field isn't empty) opens F04.
class OpenAnswerQuestion extends StatefulWidget {
  const OpenAnswerQuestion({
    super.key,
    required this.data,
    required this.phase,
    required this.onChanged,
  });

  final OpenAnswerData data;
  final QuestionPhase phase;
  final AnswerChanged onChanged;

  @override
  State<OpenAnswerQuestion> createState() => _OpenAnswerQuestionState();
}

class _OpenAnswerQuestionState extends State<OpenAnswerQuestion> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: widget.data.hint),
        const SizedBox(height: 12),
        // Figma "Answer box": at least 160 high, padding 16/14, radius 14.
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 160),
          child: TextField(
            controller: _controller,
            enabled: widget.phase == QuestionPhase.answering,
            minLines: 6,
            maxLines: 8,
            maxLength: widget.data.maxChars,
            textCapitalization: TextCapitalization.sentences,
            style: V6Text.bodyLarge,
            cursorColor: V6Colors.primary,
            onChanged: (text) {
              setState(() {});
              widget.onChanged(AnswerState(ready: text.trim().isNotEmpty));
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: V6Colors.surface,
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              enabledBorder: border(V6Colors.borderNeutral, 1),
              disabledBorder: border(V6Colors.borderDivider, 1),
              focusedBorder: border(V6Colors.primary, 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.charCount(_controller.text.characters.length, widget.data.maxChars),
          style: V6Text.caption.copyWith(color: V6Colors.textMuted),
        ),
      ],
    );
  }
}
