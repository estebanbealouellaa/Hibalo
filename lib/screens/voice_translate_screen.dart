import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/translator_state.dart';
import '../providers/translator_provider.dart';
import '../services/translation/hil_numbers.dart';
import '../services/translation/offline_translator.dart';
import '../services/tts/translation_speaker.dart';
import '../widgets/filipino_voice_dialog.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_translate.dart';

/// Which Voice state shows (Figma 04 · Voice).
enum VoiceView { ready, speaking, result, error, micOff }

/// Mic refused → [VoiceView.micOff]; a speech error → [VoiceView.error];
/// something said on this screen → [VoiceView.result]; otherwise ready or
/// speaking.
VoiceView voiceViewFor({
  required bool micOff,
  required bool listening,
  required String error,
  required bool spoke,
  required bool hasText,
}) {
  if (micOff || (!listening && error.contains('permission'))) return VoiceView.micOff;
  if (!listening && error.isNotEmpty) return VoiceView.error;
  if (spoke && !listening && hasText) return VoiceView.result;
  return listening ? VoiceView.speaking : VoiceView.ready;
}

/// Voice (Figma 04 · Voice), a full screen for now: Ready → Speaking →
/// Result ("From your voice" + Speak again), Speech error ("Didn't catch
/// that"), and Microphone access off. Speech-to-text, the translation and the
/// Listen voice are the same as before. Closes with `true` for "Type
/// instead", so Translate can focus its text box.
class VoiceTranslateScreen extends StatefulWidget {
  const VoiceTranslateScreen({super.key, this.micPermission});

  /// The microphone permission status; the real one when null (tests pass
  /// a fixed value).
  final Future<PermissionStatus> Function()? micPermission;

  @override
  State<VoiceTranslateScreen> createState() => _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends State<VoiceTranslateScreen> with TickerProviderStateMixin {
  final TranslationSpeaker _speaker = TranslationSpeaker();
  TranslatorProvider? _translator;

  late final AnimationController _pulse;
  late final AnimationController _swap;

  bool _copied = false;

  /// Something was said on this screen (the result shows after it).
  bool _spoke = false;

  /// The microphone is refused (Figma "Microphone access is off").
  bool _micOff = false;

  @override
  void initState() {
    super.initState();
    _speaker.status.addListener(_onSpeakStatus);
    _speaker.onFilipinoVoiceMissing = () {
      if (mounted) showFilipinoVoiceHelp(context);
    };
    _speaker.onFilipinoVoiceNotReady = () {
      if (mounted) showFilipinoVoiceNotReady(context);
    };
    TranslationSpeaker.warmUp();
    OfflineTranslator.warmUp();
    _translator = context.read<TranslatorProvider>()..addListener(_prepareVoice);
    _prepareVoice();

    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void dispose() {
    _pulse.dispose();
    _swap.dispose();
    _translator?.removeListener(_prepareVoice);
    _speaker.dispose();
    super.dispose();
  }

  void _onSpeakStatus() {
    if (mounted) setState(() {});
  }

  /// Starts making the Hiligaynon audio as soon as a translation is shown.
  void _prepareVoice() {
    final s = _translator?.state;
    if (s == null || s.isTranslating || s.translatedText.isEmpty) return;
    if (s.sourceLanguage == Languages.tagalog) {
      TranslationSpeaker.prepare(numbersToWords(s.translatedText));
    }
  }

  Future<void> _speak(String text) {
    final source = context.read<TranslatorProvider>().state.sourceLanguage;
    final hiligaynon = source == Languages.tagalog;
    return _speaker.toggle(hiligaynon ? numbersToWords(text) : text, hiligaynon: hiligaynon);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<PermissionStatus> _micStatus() => widget.micPermission?.call() ?? Permission.microphone.status;

  /// Starts listening, unless the microphone is refused for good.
  Future<void> _start(TranslatorProvider provider) async {
    if ((await _micStatus()).isPermanentlyDenied) {
      if (mounted) setState(() => _micOff = true);
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _micOff = false;
      _spoke = true;
    });
    await provider.startListening();
  }

  void _toggleMic(TranslatorProvider provider, bool listening) {
    if (listening) {
      HapticFeedback.mediumImpact();
      provider.stopListening();
    } else {
      _start(provider);
    }
  }

  void _close({bool typeInstead = false}) {
    final provider = context.read<TranslatorProvider>();
    if (provider.state.isListening) provider.stopListening();
    Navigator.of(context).pop(typeInstead);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;
    final listening = state.isListening;
    final body = switch (voiceViewFor(
      micOff: _micOff,
      listening: listening,
      error: state.recognitionError,
      spoke: _spoke,
      hasText: state.originalText.isNotEmpty,
    )) {
      VoiceView.micOff => _micOffCard(),
      VoiceView.error => _errorCard(provider),
      VoiceView.result => _result(provider, state, isFilToHil),
      VoiceView.ready || VoiceView.speaking => _prompt(provider, state, listening),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: V6Colors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              V6TopAppBar(title: 'Voice', onBack: _close),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  children: [
                    LanguageSwitchCard(
                      from: isFilToHil ? 'Filipino' : 'Hiligaynon',
                      to: isFilToHil ? 'Hiligaynon' : 'Filipino',
                      swapTurns: CurvedAnimation(parent: _swap, curve: Curves.easeOutBack),
                      onSwap: listening
                          ? null
                          : () {
                              _swap.forward(from: 0);
                              provider.swapLanguages();
                            },
                    ),
                    const SizedBox(height: 16),
                    body,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The white card that holds the prompt, the error and mic-off states.
  Widget _card({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      decoration: BoxDecoration(color: V6Colors.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }

  /// Figma 495:2362 "Voice ready" and 495:2369 "Speaking".
  Widget _prompt(TranslatorProvider provider, TranslatorState state, bool listening) {
    final transcript = listening && state.partialSpeechText.isNotEmpty ? state.partialSpeechText : '…';
    return _card(
      children: [
        Text(
          listening ? 'Listening…' : 'Hold the mic and speak',
          textAlign: TextAlign.center,
          style: V6Text.titleLargeBold,
        ),
        const SizedBox(height: 12),
        Text(
          transcript,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          textAlign: TextAlign.center,
          style: V6Text.bodyLarge.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Center(
          child: Semantics(
            button: true,
            label: listening ? 'Stop listening' : 'Start listening',
            child: GestureDetector(
              onTap: () => _toggleMic(provider, listening),
              onLongPressStart: (_) {
                if (!listening) _start(provider);
              },
              onLongPressEnd: (_) {
                if (provider.state.isListening) provider.stopListening();
              },
              child: SizedBox(
                width: 160,
                height: 160,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, _) => CustomPaint(
                    painter: listening ? _RaysPainter(_pulse.value) : null,
                    child: Center(
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(color: V6Colors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.mic_rounded, size: 32, color: V6Colors.onPrimary),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          listening ? 'Tap again to stop' : 'Tap to start',
          textAlign: TextAlign.center,
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 12),
        Center(child: V6Button(label: 'Cancel', style: V6ButtonStyle.text, onPressed: _close)),
      ],
    );
  }

  /// Figma 600:5222 "Speech error".
  Widget _errorCard(TranslatorProvider provider) {
    return _card(
      children: [
        Text("Didn't catch that", textAlign: TextAlign.center, style: V6Text.titleLargeBold.copyWith(color: V6Colors.coralText)),
        const SizedBox(height: 12),
        const Center(child: V6MascotCircle(mascot: 'firefly_idk', circleColor: V6Colors.coralTonal)),
        const SizedBox(height: 12),
        Text(
          'Speak a little louder and closer to the phone, then try again.',
          textAlign: TextAlign.center,
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 12),
        V6Button(label: 'Try again', style: V6ButtonStyle.coral, expand: true, onPressed: () => _start(provider)),
        const SizedBox(height: 12),
        Center(
          child: V6Button(
            label: 'Type instead',
            style: V6ButtonStyle.text,
            onPressed: () => _close(typeInstead: true),
          ),
        ),
      ],
    );
  }

  /// Figma 677:7284 "Microphone access is off".
  Widget _micOffCard() {
    return _card(
      children: [
        Text('Microphone access is off', textAlign: TextAlign.center, style: V6Text.titleLargeBold),
        const SizedBox(height: 12),
        const Center(child: V6MascotCircle(mascot: 'firefly_phone')),
        const SizedBox(height: 12),
        Text(
          'To translate by voice, allow microphone access in your phone settings. You can still type instead.',
          textAlign: TextAlign.center,
          style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
        ),
        const SizedBox(height: 12),
        V6Button(
          label: 'Open settings',
          expand: true,
          onPressed: () async {
            await openAppSettings();
            if (mounted) setState(() => _micOff = false);
          },
        ),
        const SizedBox(height: 12),
        Center(
          child: V6Button(
            label: 'Type instead',
            style: V6ButtonStyle.text,
            onPressed: () => _close(typeInstead: true),
          ),
        ),
      ],
    );
  }

  /// Figma 600:5120 "Voice · Result".
  Widget _result(TranslatorProvider provider, TranslatorState state, bool isFilToHil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FromSourceRow(
          leading: const SourceIconTile(icon: Icons.mic_rounded),
          text: 'From your voice · check for mistakes',
          actionLabel: 'Speak again',
          onAction: () => _start(provider),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: V6Colors.borderInput),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(isFilToHil ? 'Filipino' : 'Hiligaynon', style: V6Text.labelLarge.copyWith(color: V6Colors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 96),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: V6Colors.surfaceTint, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(state.originalText, style: translationInputStyle),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.originalText.characters.length} characters',
                textAlign: TextAlign.right,
                style: V6Text.caption.copyWith(color: V6Colors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TranslationResultCard(
          language: isFilToHil ? 'Hiligaynon' : 'Filipino',
          text: state.translatedText,
          translating: state.isTranslating,
          note: translationNote(isDictionaryMeaning: state.isDictionaryMeaning),
          copied: _copied,
          listen: switch (_speaker.status.value) {
            SpeakStatus.idle => ListenState.idle,
            SpeakStatus.preparing => ListenState.preparing,
            SpeakStatus.speaking => ListenState.speaking,
          },
          onListen: () => _speak(state.translatedText),
          onCopy: () => _copy(state.translatedText),
        ),
      ],
    );
  }
}

/// "Mic (speaking)": short violet and glow rays around the mic, pulsing.
class _RaysPainter extends CustomPainter {
  _RaysPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    const rays = 36;
    for (var i = 0; i < rays; i++) {
      final a = i * 2 * math.pi / rays;
      final wave = 0.5 + 0.5 * math.sin(t * 2 * math.pi + i * 0.9);
      final inner = 52.0;
      final outer = inner + 10 + 18 * wave;
      final paint = Paint()
        ..color = i.isEven ? V6Colors.primary : V6Colors.glow
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(c + Offset(math.cos(a), math.sin(a)) * inner, c + Offset(math.cos(a), math.sin(a)) * outer, paint);
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.t != t;
}
