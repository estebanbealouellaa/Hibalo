import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../providers/translator_provider.dart';
import '../models/translator_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class VoiceTranslateScreen extends StatefulWidget {
  const VoiceTranslateScreen({super.key});

  @override
  State<VoiceTranslateScreen> createState() => _VoiceTranslateScreenState();
}

class _VoiceTranslateScreenState extends State<VoiceTranslateScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  late AnimationController _pulseController;
  late Animation<double> _pulseOuter;
  late Animation<double> _pulseInner;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('fil-PH');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseOuter = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseInner = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  void _copy(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;

    return Scaffold(
      backgroundColor: white,
      body: Column(
        children: [
          // ── TOP RESULT PANEL (gradient bg) ──────────────
          Expanded(
            flex: 55,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [purple, purpleMid],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── APP BAR ─────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
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
                          // Language swap pill
                          GestureDetector(
                            onTap: () => provider.swapLanguages(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isFilToHil ? 'Fil' : 'Hil',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  Text(
                                    isFilToHil ? 'Hil' : 'Fil',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── TRANSLATION RESULT ──────────────────
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Source text (dim)
                            if (state.originalText.isNotEmpty) ...[
                              Text(
                                isFilToHil ? 'FILIPINO' : 'HILIGAYNON',
                                style: TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.45),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.originalText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.65),
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Translation result (prominent)
                            Text(
                              isFilToHil ? 'HILIGAYNON' : 'FILIPINO',
                              style: TextStyle(
                                fontSize: 10,
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: state.isTranslating
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      child: Text(
                                        state.translatedText.isEmpty
                                            ? 'Your translation appears here…'
                                            : state.translatedText,
                                        style: state.translatedText.isEmpty
                                            ? TextStyle(
                                                fontSize: 22,
                                                color: Colors.white.withOpacity(
                                                  0.35,
                                                ),
                                                height: 1.45,
                                                fontWeight: FontWeight.w300,
                                              )
                                            : AppTheme.displayMedium.copyWith(
                                                color: Colors.white,
                                                fontSize: 26,
                                                height: 1.4,
                                              ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── ACTION ICONS ROW ────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Row(
                        children: [
                          _iconBtn(
                            Icons.volume_up_outlined,
                            onTap: () => _speak(state.translatedText),
                            enabled: state.translatedText.isNotEmpty,
                          ),
                          const SizedBox(width: 8),
                          _iconBtn(
                            Icons.copy_outlined,
                            onTap: () => _copy(state.translatedText),
                            enabled: state.translatedText.isNotEmpty,
                          ),
                          const SizedBox(width: 8),
                          _iconBtn(
                            Icons.share_outlined,
                            onTap: () => Clipboard.setData(
                              ClipboardData(text: state.translatedText),
                            ),
                            enabled: state.translatedText.isNotEmpty,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BOTTOM MIC PANEL ────────────────────────────
          Expanded(
            flex: 45,
            child: Container(
              width: double.infinity,
              color: offWhite,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Partial / status text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.isListening
                          ? state.partialSpeechText.isNotEmpty
                                ? state.partialSpeechText
                                : 'Listening…'
                          : state.recognitionError.isNotEmpty
                          ? state.recognitionError
                          : 'Hold to speak',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: state.isListening
                            ? purple
                            : state.recognitionError.isNotEmpty
                            ? Colors.red.shade400
                            : inkSoft,
                        fontWeight: state.isListening
                            ? FontWeight.w600
                            : FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── MIC BUTTON WITH PULSE ──────────────
                  GestureDetector(
                    onLongPressStart: (_) {
                      HapticFeedback.mediumImpact();
                      provider.startListening();
                    },
                    onLongPressEnd: (_) {
                      HapticFeedback.lightImpact();
                      provider.stopListening();
                    },
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final listening = state.isListening;
                        return SizedBox(
                          width: 140,
                          height: 140,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outermost ring
                              if (listening)
                                Transform.scale(
                                  scale: _pulseOuter.value,
                                  child: Container(
                                    width: 128,
                                    height: 128,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: purple.withOpacity(0.10),
                                    ),
                                  ),
                                ),
                              // Middle ring
                              if (listening)
                                Transform.scale(
                                  scale: _pulseInner.value,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: purple.withOpacity(0.18),
                                    ),
                                  ),
                                ),
                              // Core button
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: listening ? purple : white,
                                  border: Border.all(
                                    color: listening ? purple : borderMid,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: purple.withOpacity(
                                        listening ? 0.40 : 0.12,
                                      ),
                                      blurRadius: listening ? 24 : 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  listening
                                      ? Icons.mic_rounded
                                      : Icons.mic_none_rounded,
                                  color: listening ? white : purpleMid,
                                  size: 32,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    state.isListening ? 'Release to translate' : 'Speak now',
                    style: TextStyle(
                      fontSize: 13,
                      color: state.isListening ? purple : inkMuted,
                      fontWeight: state.isListening
                          ? FontWeight.w600
                          : FontWeight.w400,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── PAUSE / STOP CHIPS ─────────────────
                  if (state.isListening)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _controlChip(
                          icon: Icons.pause_rounded,
                          label: 'Pause',
                          onTap: () => provider.stopListening(),
                        ),
                        const SizedBox(width: 10),
                        _controlChip(
                          icon: Icons.stop_rounded,
                          label: 'Stop',
                          filled: true,
                          onTap: () {
                            provider.stopListening();
                            provider.updateOriginalText('');
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData icon, {
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.35,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }

  Widget _controlChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? purple : white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: filled ? purple : borderMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: filled ? white : purpleMid),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: filled ? white : inkSoft,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
