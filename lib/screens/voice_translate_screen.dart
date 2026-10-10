import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/translator_provider.dart';
import '../services/tts/translation_speaker.dart';
import '../models/translator_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class VoiceTranslateScreen extends StatefulWidget {
  const VoiceTranslateScreen({super.key});

  @override
  State<VoiceTranslateScreen> createState() => _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends State<VoiceTranslateScreen>
    with TickerProviderStateMixin {
  final TranslationSpeaker _speaker = TranslationSpeaker();
  TranslatorProvider? _translator;

  /// Drives the rings and the waveform while the mic is open.
  late final AnimationController _pulse;

  /// One-shot swap animation for the language pill.
  late final AnimationController _swap;

  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _speaker.status.addListener(_onSpeakStatus);
    TranslationSpeaker.warmUp();
    _translator = context.read<TranslatorProvider>()
      ..addListener(_prepareVoice);
    _prepareVoice();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _swap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    _swap.dispose();
    _translator?.removeListener(_prepareVoice);
    _speaker.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  void _onSpeakStatus() {
    if (mounted) setState(() {});
  }

  /// Starts making the Hiligaynon audio as soon as a translation is shown,
  /// so "Listen" can play right away.
  void _prepareVoice() {
    final s = _translator?.state;
    if (s == null || s.isTranslating || s.translatedText.isEmpty) return;
    if (s.sourceLanguage == Languages.tagalog) {
      TranslationSpeaker.prepare(s.translatedText);
    }
  }

  /// Filipino -> Hiligaynon results use the native Hiligaynon voice.
  Future<void> _speak(String text) {
    final source = context.read<TranslatorProvider>().state.sourceLanguage;
    return _speaker.toggle(text, hiligaynon: source == Languages.tagalog);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _toggleMic(TranslatorProvider provider, bool listening) {
    HapticFeedback.mediumImpact();
    if (listening) {
      provider.stopListening();
    } else {
      provider.startListening();
    }
  }

  // ── UI ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;
    final listening = state.isListening;
    final hasResult = state.translatedText.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),
      body: Column(
        children: [
          // ── Result panel ──
          Expanded(
            flex: 54,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(34),
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [purple, purpleMid],
                  ),
                ),
                child: Stack(
                  children: [
                    // Soft light behind the text.
                    Positioned(
                      right: -70,
                      top: -40,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _appBar(provider, isFilToHil),
                          Expanded(child: _result(state, isFilToHil)),
                          _actions(state),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Mic panel ──
          Expanded(
            flex: 46,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusLine(state, listening),
                  const SizedBox(height: 20),
                  _mic(provider, state, listening),
                  const SizedBox(height: 16),
                  Text(
                    listening
                        ? 'Tap again, or let go, to translate'
                        : 'Tap to start · hold to talk',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: listening ? purple : inkMuted,
                      fontWeight: listening ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (hasResult && !listening)
                    _clearChip(provider)
                  else if (!listening)
                    _hint(isFilToHil),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar with the language switch ────────────────────────────────────
  Widget _appBar(TranslatorProvider provider, bool isFilToHil) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 14, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              'Voice Translate',
              style: AppTheme.displaySmall.copyWith(
                color: Colors.white,
                fontSize: 17,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _swap.forward(from: 0);
              provider.swapLanguages();
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isFilToHil ? 'Filipino' : 'Hiligaynon',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5).animate(
                      CurvedAnimation(parent: _swap, curve: Curves.easeOutBack),
                    ),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.swap_horiz_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFilToHil ? 'Hiligaynon' : 'Filipino',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── The translation itself ──────────────────────────────────────────────
  Widget _result(TranslatorState state, bool isFilToHil) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // What was heard.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topLeft,
            child: state.originalText.isEmpty
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _tag(
                          isFilToHil
                              ? 'You said · Filipino'
                              : 'You said · Hiligaynon',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.originalText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.8),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          _tag(isFilToHil ? 'Hiligaynon' : 'Filipino'),
          const SizedBox(height: 8),

          Expanded(
            child: state.isTranslating
                ? _translating()
                : SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      transitionBuilder: (c, a) => FadeTransition(
                        opacity: a,
                        child: SlideTransition(
                          position: Tween(
                            begin: const Offset(0, 0.12),
                            end: Offset.zero,
                          ).animate(a),
                          child: c,
                        ),
                      ),
                      child: state.translatedText.isEmpty
                          ? Text(
                              'Your translation appears here…',
                              key: const ValueKey('empty'),
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white.withValues(alpha: 0.38),
                                height: 1.45,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Text(
                              state.translatedText,
                              key: ValueKey(state.translatedText),
                              style: AppTheme.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 28,
                                height: 1.35,
                              ),
                            ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String text) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w800,
      color: Colors.white.withValues(alpha: 0.5),
    ),
  );

  /// Three dots that bounce while the translation is on its way.
  Widget _translating() {
    return Align(
      alignment: Alignment.centerLeft,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, _) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final v = math.sin((_pulse.value * 2 + i / 3) * 2 * math.pi);
            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              transform: Matrix4.translationValues(0, -v.clamp(0, 1) * 7, 0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55 + v.clamp(0, 1) * 0.45),
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Speak / copy / share ────────────────────────────────────────────────
  Widget _actions(TranslatorState state) {
    final on = state.translatedText.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 18),
      child: Row(
        children: [
          _actionBtn(
            icon: switch (_speaker.status.value) {
              SpeakStatus.idle => Icons.volume_up_rounded,
              SpeakStatus.preparing => Icons.hourglass_top_rounded,
              SpeakStatus.speaking => Icons.stop_rounded,
            },
            label: switch (_speaker.status.value) {
              SpeakStatus.idle => 'Listen',
              SpeakStatus.preparing => 'Preparing',
              SpeakStatus.speaking => 'Stop',
            },
            enabled: on,
            primary: true,
            onTap: () => _speak(state.translatedText),
          ),
          const SizedBox(width: 10),
          _actionBtn(
            icon: _copied ? Icons.check_rounded : Icons.copy_rounded,
            label: _copied ? 'Copied' : 'Copy',
            enabled: on,
            onTap: () => _copy(state.translatedText),
          ),
          const SizedBox(width: 10),
          _actionBtn(
            icon: Icons.ios_share_rounded,
            label: 'Share',
            enabled: on,
            onTap: () =>
                _copy('${state.originalText}\n→ ${state.translatedText}'),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
    bool primary = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: enabled ? 1 : 0.4,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: primary ? 0.22 : 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 17),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Status line above the mic ───────────────────────────────────────────
  Widget _statusLine(TranslatorState state, bool listening) {
    final error = state.recognitionError.isNotEmpty && !listening;
    final text = listening
        ? (state.partialSpeechText.isNotEmpty
              ? state.partialSpeechText
              : 'Listening…')
        : error
        ? state.recognitionError
        : 'Hold the mic and speak';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: ValueKey('$listening$error$text'),
          padding: error
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 9)
              : EdgeInsets.zero,
          decoration: error
              ? BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade200),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (error) ...[
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: Colors.red.shade400,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: listening ? 16 : 14,
                    color: listening
                        ? purple
                        : error
                        ? Colors.red.shade400
                        : inkSoft,
                    fontWeight: listening ? FontWeight.w700 : FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mic button: rings, waveform, tap or hold ────────────────────────────
  Widget _mic(
    TranslatorProvider provider,
    TranslatorState state,
    bool listening,
  ) {
    return GestureDetector(
      onTap: () => _toggleMic(provider, listening),
      onLongPressStart: (_) {
        if (!listening) {
          HapticFeedback.mediumImpact();
          provider.startListening();
        }
      },
      onLongPressEnd: (_) {
        if (state.isListening) {
          HapticFeedback.lightImpact();
          provider.stopListening();
        }
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          final t = _pulse.value;
          return SizedBox(
            width: 190,
            height: 190,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripples travelling outward.
                if (listening)
                  for (int i = 0; i < 3; i++)
                    Builder(
                      builder: (_) {
                        final p = (t + i / 3) % 1;
                        return Container(
                          width: 96 + p * 92,
                          height: 96 + p * 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: purple.withValues(alpha: (1 - p) * 0.35),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),

                // Live waveform ring.
                if (listening)
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CustomPaint(painter: _WavePainter(t)),
                  ),

                // Core button.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  width: listening ? 92 : 84,
                  height: listening ? 92 : 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: listening
                        ? const LinearGradient(
                            colors: [purple, purpleMid],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: listening ? null : white,
                    border: listening
                        ? null
                        : Border.all(color: borderMid, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: purple.withValues(alpha: listening ? 0.45 : 0.16),
                        blurRadius: listening ? 30 : 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    listening ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                    color: listening ? white : purple,
                    size: 34,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Bottom helpers ──────────────────────────────────────────────────────
  Widget _clearChip(TranslatorProvider provider) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        provider.updateOriginalText('');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, size: 16, color: purpleMid),
            const SizedBox(width: 7),
            Text(
              'New translation',
              style: TextStyle(
                fontSize: 12.5,
                color: inkSoft,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(bool isFilToHil) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline_rounded, size: 15, color: inkMuted),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              isFilToHil
                  ? 'Try: "Magandang umaga, kumusta ka?"'
                  : 'Try: "Maayong aga, kamusta ka?"',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: inkMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WAVEFORM RING
// Bars around the mic that rise and fall while it is listening. They are
// decorative: the speech plugin does not report volume, so this shows that
// the app is awake rather than how loud the speaker is.
// ═════════════════════════════════════════════════════════════════════════════
class _WavePainter extends CustomPainter {
  final double t; // 0..1, loops
  _WavePainter(this.t);

  static const int _bars = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final inner = size.width * 0.33;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    for (int i = 0; i < _bars; i++) {
      final a = i / _bars * 2 * math.pi - math.pi / 2;
      // Two waves at different speeds keep the motion from looking mechanical.
      final w1 = math.sin((i / _bars * 3 + t) * 2 * math.pi);
      final w2 = math.sin((i / _bars * 5 - t * 1.6) * 2 * math.pi);
      final amp = (w1 * 0.6 + w2 * 0.4).abs();
      final len = 5 + amp * 20;

      paint.color = purple.withValues(alpha: 0.25 + amp * 0.5);
      canvas.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * inner,
        center + Offset(math.cos(a), math.sin(a)) * (inner + len),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.t != t;
}
