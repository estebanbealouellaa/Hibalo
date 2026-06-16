import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../providers/translator_provider.dart';
import '../models/translator_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/user_stats.dart';
import '../widgets/hibalo_ui.dart';
import 'camera_translate_screen.dart';

class _CommonPhrase {
  final String category;
  final String hil;
  final String fil;

  const _CommonPhrase(this.category, this.hil, this.fil);
}

const double _translatorTextAreaHeight = 86;

const _commonPhrases = [
  _CommonPhrase('Greeting', 'Kamusta ka?', 'Kumusta ka?'),
  _CommonPhrase('Thanks', 'Salamat gid', 'Maraming salamat'),
  _CommonPhrase('Ask', 'Diin ka na?', 'Nasaan ka na?'),
  _CommonPhrase('Farewell', 'Palaabuton', 'Paalam'),
];

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('fil-PH');
  }

  void _applyPhrase(_CommonPhrase phrase, String sourceLanguage) {
    final text = sourceLanguage == Languages.hiligaynon
        ? phrase.hil
        : phrase.fil;
    _inputController.text = text;
    context.read<TranslatorProvider>().updateOriginalText(text);
  }

  Future<void> _speakResult(String text) async {
    if (text.isEmpty) return;
    await _tts.speak(text);
  }

  void _copyResult(String text) {
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
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;

    if (_inputController.text != state.originalText) {
      _inputController.text = state.originalText;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    }

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<UserStats>(
                builder: (context, stats, _) => HibaloScreenHeader(
                  title: 'Translate',
                  streak: stats.streak,
                  xp: stats.xp,
                ),
              ),
              const SizedBox(height: 8),

              // ── HERO LANGUAGE CARD ───────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: BoxDecoration(
                  color: purple,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TRANSLATE',
                          style: AppTheme.labelCaps.copyWith(
                            color: purpleLight,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _langPill(
                                isFilToHil ? 'Filipino' : 'Hiligaynon',
                                'Source',
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                context
                                    .read<TranslatorProvider>()
                                    .swapLanguages();
                              },
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: const BoxDecoration(
                                  color: white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.swap_vert_rounded,
                                  color: purple,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _langPill(
                                isFilToHil ? 'Hiligaynon' : 'Filipino',
                                'Target',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── INPUT BOX ────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: offWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderMid),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR TEXT',
                      style: AppTheme.labelCaps.copyWith(fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: _translatorTextAreaHeight,
                      child: TextField(
                        controller: _inputController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w400,
                          color: ink,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Magandang umaga',
                          hintStyle: TextStyle(
                            color: inkMuted.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onChanged: (value) {
                          context.read<TranslatorProvider>().updateOriginalText(
                            value,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _actionChip(
                          icon: Icons.camera_alt_outlined,
                          label: 'Camera',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CameraTranslateScreen(),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            context
                                .read<TranslatorProvider>()
                                .updateOriginalText(_inputController.text);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: purple,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: purple),
                            ),
                            child: Text(
                              'Translate',
                              style: AppTheme.bodyMedium.copyWith(
                                color: white,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── RESULT BOX ───────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: purple,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFilToHil ? 'HILIGAYNON' : 'FILIPINO',
                      style: AppTheme.labelCaps.copyWith(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: _translatorTextAreaHeight,
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: state.isTranslating
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                state.translatedText.isEmpty
                                    ? 'Your translation appears here'
                                    : state.translatedText,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: state.translatedText.isEmpty
                                    ? TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white.withOpacity(0.45),
                                        height: 1.5,
                                      )
                                    : AppTheme.displayMedium.copyWith(
                                        color: Colors.white,
                                        fontSize: 19,
                                        height: 1.5,
                                      ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _resultIcon(
                          Icons.volume_up_outlined,
                          () => _speakResult(state.translatedText),
                          enabled: state.translatedText.isNotEmpty,
                        ),
                        const SizedBox(width: 7),
                        _resultIcon(
                          Icons.copy_outlined,
                          () => _copyResult(state.translatedText),
                          enabled: state.translatedText.isNotEmpty,
                        ),
                        const SizedBox(width: 7),
                        _resultIcon(
                          Icons.share_outlined,
                          () => Clipboard.setData(
                            ClipboardData(text: state.translatedText),
                          ),
                          enabled: state.translatedText.isNotEmpty,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── COMMON PHRASES ───────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Common Phrases',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'See all',
                      style: AppTheme.bodyMedium.copyWith(
                        color: purple,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 85,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _commonPhrases.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final phrase = _commonPhrases[index];
                    final primary = isFilToHil ? phrase.fil : phrase.hil;
                    final secondary = isFilToHil ? phrase.hil : phrase.fil;
                    return GestureDetector(
                      onTap: () => _applyPhrase(phrase, state.sourceLanguage),
                      child: Container(
                        width: 135,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phrase.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: purple,
                                letterSpacing: 0.72,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              primary,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              secondary,
                              style: AppTheme.bodyMedium.copyWith(fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langPill(String name, String sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: AppTheme.displaySmall.copyWith(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.45),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    bool highlighted = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: highlighted ? purplePale : white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: highlighted ? purple : borderMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: purpleMid),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(fontSize: 11, color: inkSoft),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultIcon(IconData icon, VoidCallback onTap, {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.13),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Icon(icon, color: white, size: 14),
        ),
      ),
    );
  }
}
