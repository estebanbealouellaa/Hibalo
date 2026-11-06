import '../../l10n/app_localizations.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../providers/translator_provider.dart';
import '../../widgets/v6/v6.dart';

/// Which Voice pop-up state shows (Figma 04 · Voice).
enum VoiceView { ready, speaking, error, micOff }

/// Mic refused → [VoiceView.micOff]; a speech error (from this pop-up) →
/// [VoiceView.error]; otherwise ready or speaking.
VoiceView voiceViewFor({required bool micOff, required bool listening, required String error}) {
  if (micOff || (!listening && error.contains('permission'))) return VoiceView.micOff;
  if (!listening && error.isNotEmpty) return VoiceView.error;
  return listening ? VoiceView.speaking : VoiceView.ready;
}

enum VoiceOutcome {
  /// Speech gave text; it is in the Translate input and being translated.
  spoke,

  /// "Type instead": focus the text box.
  typeInstead,
}

/// Voice pop-up over Translate (Figma 495:2362, 495:2369, 600:5222, 677:7284); null for Cancel.
Future<VoiceOutcome?> showVoicePopup(BuildContext context, {Future<PermissionStatus> Function()? micPermission}) {
  return showDialog<VoiceOutcome>(
    context: context,
    barrierDismissible: false,
    barrierColor: V6Colors.primaryStrong.withValues(alpha: 0.45),
    builder: (_) => VoicePopup(micPermission: micPermission),
  );
}

class VoicePopup extends StatefulWidget {
  const VoicePopup({super.key, this.micPermission});

  /// The microphone permission status; the real one when null (tests pass
  /// a fixed value).
  final Future<PermissionStatus> Function()? micPermission;

  @override
  State<VoicePopup> createState() => _VoicePopupState();
}

class _VoicePopupState extends State<VoicePopup> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final TranslatorProvider _provider;

  /// Speech results already counted when the pop-up opened.
  late final int _results;

  /// Listening was started from this pop-up (errors before it don't show).
  bool _started = false;

  /// The microphone is refused (Figma "Microphone access is off").
  bool _micOff = false;

  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _provider = context.read<TranslatorProvider>()..addListener(_onProvider);
    _results = _provider.speechResults;
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProvider);
    _pulse.dispose();
    super.dispose();
  }

  void _onProvider() {
    if (_provider.speechResults != _results) {
      _close(VoiceOutcome.spoke);
    } else if (mounted) {
      setState(() {});
    }
  }

  void _close([VoiceOutcome? outcome]) {
    if (_closing || !mounted) return;
    _closing = true;
    if (_provider.state.isListening) _provider.stopListening();
    Navigator.of(context).pop(outcome);
  }

  Future<PermissionStatus> _micStatus() => widget.micPermission?.call() ?? Permission.microphone.status;

  /// Starts listening, unless the microphone is refused for good.
  Future<void> _start() async {
    if ((await _micStatus()).isPermanentlyDenied) {
      if (mounted) setState(() => _micOff = true);
      return;
    }
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _micOff = false;
      _started = true;
    });
    await _provider.startListening();
  }

  void _toggleMic(bool listening) {
    if (listening) {
      HapticFeedback.mediumImpact();
      _provider.stopListening();
    } else {
      _start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _provider.state;
    final listening = state.isListening;
    final view = voiceViewFor(micOff: _micOff, listening: listening, error: _started ? state.recognitionError : '');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Dialog(
        backgroundColor: V6Colors.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: switch (view) {
              VoiceView.micOff => _micOffCard(),
              VoiceView.error => _errorCard(),
              VoiceView.ready || VoiceView.speaking => _prompt(state.partialSpeechText, listening),
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _prompt(String partial, bool listening) {
    final t = AppLocalizations.of(context);
    final transcript = listening && partial.isNotEmpty ? '…$partial' : '…';
    return [
      Text(
        listening ? t.voiceListening : t.voiceHoldMic,
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
          label: listening ? t.voiceStopListening : t.voiceStartListening,
          child: GestureDetector(
            onTap: () => _toggleMic(listening),
            onLongPressStart: (_) {
              if (!listening) _start();
            },
            onLongPressEnd: (_) {
              if (_provider.state.isListening) _provider.stopListening();
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
        listening ? t.voiceTapToStop : t.voiceTapToStart,
        textAlign: TextAlign.center,
        style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
      ),
      const SizedBox(height: 12),
      Center(
        child: V6Button(label: t.commonCancel, style: V6ButtonStyle.text, onPressed: _close),
      ),
    ];
  }

  /// Figma 600:5222 "Speech error".
  List<Widget> _errorCard() {
    final t = AppLocalizations.of(context);
    return [
      Text(
        t.voiceDidntCatch,
        textAlign: TextAlign.center,
        style: V6Text.titleLargeBold.copyWith(color: V6Colors.coralText),
      ),
      const SizedBox(height: 12),
      const Center(
        child: V6MascotCircle(mascot: 'firefly_idk', circleColor: V6Colors.coralTonal),
      ),
      const SizedBox(height: 12),
      Text(
        t.voiceDidntCatchBody,
        textAlign: TextAlign.center,
        style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
      ),
      const SizedBox(height: 12),
      V6Button(label: t.tryAgain, style: V6ButtonStyle.coral, expand: true, onPressed: _start),
      const SizedBox(height: 12),
      Center(
        child: V6Button(
          label: t.commonTypeInstead,
          style: V6ButtonStyle.text,
          onPressed: () => _close(VoiceOutcome.typeInstead),
        ),
      ),
    ];
  }

  /// Figma 677:7284 "Microphone access is off".
  List<Widget> _micOffCard() {
    final t = AppLocalizations.of(context);
    return [
      Text(t.voiceMicOffTitle, textAlign: TextAlign.center, style: V6Text.titleLargeBold),
      const SizedBox(height: 12),
      const Center(child: V6MascotCircle(mascot: 'firefly_phone')),
      const SizedBox(height: 12),
      Text(
        t.voiceMicOffBody,
        textAlign: TextAlign.center,
        style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
      ),
      const SizedBox(height: 12),
      V6Button(
        label: t.commonOpenSettings,
        expand: true,
        onPressed: () async {
          await openAppSettings();
          if (mounted) setState(() => _micOff = false);
        },
      ),
      const SizedBox(height: 12),
      Center(
        child: V6Button(
          label: t.commonTypeInstead,
          style: V6ButtonStyle.text,
          onPressed: () => _close(VoiceOutcome.typeInstead),
        ),
      ),
    ];
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
      const inner = 52.0;
      final outer = inner + 10 + 18 * wave;
      final paint = Paint()
        ..color = i.isEven ? V6Colors.primary : V6Colors.glow
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * inner,
        c + Offset(math.cos(a), math.sin(a)) * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => old.t != t;
}
