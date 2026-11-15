import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../l10n/app_localizations.dart';
import '../../../widgets/v6/v6_button.dart';
import '../../models/catalog.dart' show PronunciationScore, PronunciationSettings;
import '../../models/questions.dart';
import '../../services/lesson_audio.dart';
import '../../services/pronunciation/clip_decoder.dart';
import '../../services/pronunciation/similarity.dart';
import '../../services/voice_recorder.dart';
import '../../theme/v6_colors.dart';
import '../../theme/v6_text.dart';
import '../parts/part_common.dart' show AudioButton;
import 'question_contract.dart';
import 'quiz_common.dart';

/// The unscored questions: Q09 Speaking and Q10 Open answer (§4).

/// Q09: Continue is enabled after one recording, or at once when the mic is refused or missing.
///
/// With pronunciation feedback on (settings.pronunciationFeedback) and a native clip, each
/// recording is compared with the clip (FUTURE_FEATURES #1): Checking → Very close / Almost /
/// Try again, or "We couldn't hear you". Practice only: no score, no XP. Without a clip it
/// shows "Comparison coming soon" (Figma Q09 / No clip).
class SpeakingQuestion extends StatefulWidget {
  const SpeakingQuestion({
    super.key,
    required this.data,
    required this.recorder,
    required this.onChanged,
    this.feedback = PronunciationSettings.off,
    this.comparer,
    this.otherClips = const [],
  });

  final SpeakingData data;

  /// Keeps the recording in memory only; the quiz clears it when it ends.
  final VoiceRecorder recorder;
  final AnswerChanged onChanged;

  final PronunciationSettings feedback;

  /// Compares the recording with the native clip; no feedback when null.
  final PronunciationComparer? comparer;

  /// The other Beginner Q09 clips, for the relative score.
  final List<String> otherClips;

  @override
  State<SpeakingQuestion> createState() => _SpeakingQuestionState();
}

enum _Stage { ready, recording, checking, result, couldntHear, unavailable }

class _SpeakingQuestionState extends State<SpeakingQuestion> {
  _Stage _stage = _Stage.ready;
  PronunciationLevel? _level;
  bool _busy = false;

  /// Bumped by every new recording, so an older check's result is dropped.
  int _take = 0;

  bool get _recorded => widget.recorder.hasRecording;
  bool get _noClip => widget.data.audio == null;

  /// Figma Q09 / No clip: the feedback is switched on but this phrase has no native clip yet.
  bool get _showNoClip => widget.feedback.enabled && _noClip;
  bool get _compare => widget.feedback.active && !_noClip && widget.comparer != null;

  void _report() {
    final busy = _stage == _Stage.recording || _stage == _Stage.checking;
    widget.onChanged(AnswerState(ready: !busy && (_recorded || _stage == _Stage.unavailable)));
  }

  void _go(_Stage stage) {
    if (!mounted) return;
    setState(() => _stage = stage);
    _report();
  }

  Future<void> _tapMic() async {
    if (_busy) return;
    _busy = true;
    try {
      if (_stage == _Stage.recording) {
        await widget.recorder.stop();
        if (_compare && _recorded) {
          _check();
        } else {
          _go(_Stage.ready);
        }
      } else {
        await _startRecording();
      }
    } finally {
      _busy = false;
    }
  }

  Future<void> _startRecording() async {
    await LessonAudio.instance.stop();
    _take++;
    final started = await widget.recorder.start();
    _go(started ? _Stage.recording : _Stage.unavailable);
  }

  /// "Record again": a new recording replaces the old one.
  Future<void> _recordAgain() async {
    if (_busy) return;
    _busy = true;
    try {
      _level = null;
      await _startRecording();
    } finally {
      _busy = false;
    }
  }

  Future<void> _check() async {
    final take = _take;
    _go(_Stage.checking);
    final settings = widget.feedback;
    try {
      final bytes = widget.recorder.recordingBytes ?? Uint8List(0);
      final learner = toMono16k(RawPcm(samples: int16FromBytes(bytes), sampleRate: 16000, channels: 1));
      final c = await widget.comparer!.compare(
        learner: learner,
        target: widget.data.audio!,
        others: widget.otherClips,
      );
      if (take != _take) return;
      if (!c.heard) {
        _go(_Stage.couldntHear);
        return;
      }
      final score = settings.score == PronunciationScore.relative ? c.relative : c.distance;
      _level = score == null ? null : levelFor(score, veryClose: settings.veryClose, almost: settings.almost);
      _go(_level == null ? _Stage.ready : _Stage.result);
    } catch (e) {
      // The clip couldn't be decoded: Q09 works as before, without feedback.
      debugPrint('[Q09] comparison failed: $e');
      if (take == _take) _go(_Stage.ready);
    }
  }

  @override
  void dispose() {
    _take++;
    if (_stage == _Stage.recording) widget.recorder.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final recording = _stage == _Stage.recording;
    final gap = const SizedBox(height: 10);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuizTitle(widget.data.prompt, hint: t.q09Hint),
        gap,
        PromptCard(
          label: t.hiligaynonLabel,
          text: widget.data.text,
          sub: widget.data.meaning,
          child: _showNoClip
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _NativeAudioRow(enabled: false),
                    const SizedBox(height: 6),
                    Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textSecondary)),
                  ],
                )
              // While the clip isn't recorded: "Audio coming soon" instead of the Native speaker button.
              : widget.data.audio == null
                  ? Text(t.audioComingSoon, style: V6Text.caption.copyWith(color: V6Colors.textMuted))
                  : _NativeAudioRow(enabled: true, clip: widget.data.audio),
        ),
        gap,
        ...switch (_stage) {
          _Stage.checking => [
              V6Button(label: t.q09Checking, onPressed: null, loading: true, expand: true),
            ],
          _Stage.result => [
              _ResultCard.level(_level!, t),
              gap,
              _compareRow(t, after: true),
              gap,
              _recordAgainButton(t),
            ],
          _Stage.couldntHear => [
              _ResultCard.couldntHear(t),
              gap,
              _recordAgainButton(t),
            ],
          _ => [
              Center(
                child: _stage == _Stage.unavailable
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
              if (_showNoClip && _recorded && !recording) ...[
                const SizedBox(height: 8),
                Text(
                  t.q09RecordedAgain,
                  textAlign: TextAlign.center,
                  style: V6Text.caption.copyWith(color: V6Colors.textMuted),
                ),
              ],
              gap,
              if (_showNoClip) ...[
                _CompareButton(
                  label: t.q09PlayMine,
                  background: V6Colors.glowContainerSoft,
                  foreground: V6Colors.glowText,
                  onTap: _recorded && !recording ? widget.recorder.play : null,
                ),
                gap,
                Text(
                  t.q09ComparisonComingSoon,
                  textAlign: TextAlign.center,
                  style: V6Text.caption.copyWith(color: V6Colors.textSecondary),
                ),
              ] else
                _compareRow(t, after: false),
            ],
        },
      ],
    );
  }

  /// Before a check: Figma "Compare" (Native speaker, You). In the result states:
  /// Play mine, then Play native.
  Widget _compareRow(AppLocalizations t, {required bool after}) {
    final recording = _stage == _Stage.recording;
    final native = _CompareButton(
      label: after ? t.q09PlayNative : t.nativeSpeaker,
      background: V6Colors.primaryContainer,
      foreground: V6Colors.primary,
      onTap: widget.data.audio == null ? null : () => LessonAudio.instance.play(widget.data.audio),
    );
    final mine = _CompareButton(
      label: after ? t.q09PlayMine : t.youLabel,
      background: V6Colors.glowContainerSoft,
      foreground: V6Colors.glowText,
      onTap: _recorded && !recording ? widget.recorder.play : null,
    );
    return Row(
      children: [
        Expanded(child: after ? mine : native),
        const SizedBox(width: 12),
        Expanded(child: after ? native : mine),
      ],
    );
  }

  Widget _recordAgainButton(AppLocalizations t) => V6Button(
        label: t.q09RecordAgain,
        onPressed: _recordAgain,
        style: V6ButtonStyle.secondary,
        leadingIcon: Icons.refresh_rounded,
        leadingIconColor: V6Colors.secondaryButtonIcon,
        expand: true,
      );
}

/// Figma "Native audio": the 64 Audio Button + "Native speaker"; disabled = 40% opacity, not tappable.
class _NativeAudioRow extends StatelessWidget {
  const _NativeAudioRow({required this.enabled, this.clip});

  final bool enabled;
  final String? clip;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (enabled)
          AudioButton(clip: clip, label: t.nativeSpeaker, size: 64, iconSize: 28)
        else
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(color: V6Colors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.volume_up_rounded, color: V6Colors.onPrimary, size: 28),
          ),
        const SizedBox(width: 8),
        Flexible(child: Text(t.nativeSpeaker, style: V6Text.labelLargeBold.copyWith(color: V6Colors.primary))),
      ],
    );
    return enabled ? row : ExcludeSemantics(child: Opacity(opacity: 0.4, child: row));
  }
}

/// Figma Q09 "Result card": padding 16/14, radius 20, 1.5 border, 24 icon + Title/Medium · Bold,
/// then one Body/Medium sentence.
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.background,
    required this.accent,
    required this.icon,
    required this.title,
    required this.text,
    this.borderColor,
  });

  factory _ResultCard.level(PronunciationLevel level, AppLocalizations t) => switch (level) {
        PronunciationLevel.veryClose => _ResultCard(
            background: V6Colors.successContainer,
            accent: V6Colors.success,
            icon: const Icon(Icons.check_circle_rounded, size: 24, color: V6Colors.success),
            title: t.q09VeryClose,
            text: t.q09VeryCloseText,
          ),
        PronunciationLevel.almost => _ResultCard(
            background: V6Colors.warningContainer,
            accent: V6Colors.warning,
            icon: const Icon(Icons.error_outline_rounded, size: 24, color: V6Colors.warning),
            title: t.q09Almost,
            text: t.q09AlmostText,
          ),
        PronunciationLevel.tryAgain => _ResultCard(
            background: V6Colors.coralContainerSoft,
            accent: V6Colors.coralText,
            icon: const Icon(Icons.hearing_rounded, size: 24, color: V6Colors.coralText),
            title: t.q09TryAgain,
            text: t.q09TryAgainText,
          ),
      };

  /// Figma Q09 / Couldn't hear: neutral card, Icon/mic_off (838:9607).
  factory _ResultCard.couldntHear(AppLocalizations t) => _ResultCard(
        background: V6Colors.neutralBackground,
        accent: V6Colors.textNeutralStrong,
        borderColor: V6Colors.textSecondary,
        icon: SvgPicture.asset(
          'assets/images/icons/mic_off.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(V6Colors.textNeutralStrong, BlendMode.srcIn),
        ),
        title: t.q09CouldntHear,
        text: t.q09CouldntHearText,
      );

  final Color background;
  final Color accent;
  final Widget icon;
  final String title;
  final String text;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? accent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 24, height: 24, child: icon),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: V6Text.titleMediumBold.copyWith(color: accent))),
              ],
            ),
            const SizedBox(height: 6),
            Text(text, style: V6Text.bodyMedium.copyWith(color: V6Colors.textPrimary)),
          ],
        ),
      ),
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
        // A clip to answer about (i10): the play buttons, or its transcript while it isn't recorded.
        if (widget.data.transcript != null) ...[
          AudioOrText(
            buttons: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(child: AudioButton(clip: widget.data.audio, label: t.playAudio, size: 88, iconSize: 28)),
                const SizedBox(height: 12),
                Text(
                  t.q10ListenLabel,
                  textAlign: TextAlign.center,
                  style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                ),
              ],
            ),
            missing: widget.data.audio == null,
            text: widget.data.transcript,
          ),
          const SizedBox(height: 12),
        ],
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
