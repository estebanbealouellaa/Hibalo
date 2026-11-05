import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/translator_provider.dart';
import '../services/translation/hil_numbers.dart';
import '../services/translation/offline_translator.dart';
import '../services/tts/translation_speaker.dart';
import '../models/translator_state.dart';
import '../widgets/filipino_voice_dialog.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_translate.dart';
import 'camera_translate_screen.dart';
import 'voice_translate_screen.dart';

class _CommonPhrase {
  final String category;
  final String emoji;
  final String hil;
  final String fil;

  const _CommonPhrase(this.category, this.emoji, this.hil, this.fil);
}

const _commonPhrases = [
  _CommonPhrase('Greeting', '👋', 'Maayong aga', 'Magandang umaga'),
  _CommonPhrase('Ask', '💬', 'Kamusta ka?', 'Kumusta ka?'),
  _CommonPhrase('Thanks', '🙏', 'Salamat gid', 'Maraming salamat'),
  _CommonPhrase('Polite', '🤲', 'Palihog', 'Pakiusap'),
  _CommonPhrase('Where', '📍', 'Diin ka na?', 'Nasaan ka na?'),
  _CommonPhrase('Farewell', '👋', 'Palaabuton', 'Paalam'),
];

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focus = FocusNode();
  final TranslationSpeaker _speaker = TranslationSpeaker();
  TranslatorProvider? _translator;

  late final AnimationController _swap;

  bool _copied = false;

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
    _translator = context.read<TranslatorProvider>()
      ..addListener(_prepareVoice);
    _prepareVoice();

    _swap = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _inputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _focus.dispose();
    _swap.dispose();
    _translator?.removeListener(_prepareVoice);
    _speaker.dispose();
    super.dispose();
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  void _translate() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    context.read<TranslatorProvider>().updateOriginalText(
      _inputController.text,
    );
  }

  void _applyPhrase(_CommonPhrase phrase, String sourceLanguage) {
    HapticFeedback.selectionClick();
    final text = sourceLanguage == Languages.hiligaynon
        ? phrase.hil
        : phrase.fil;
    _inputController.text = text;
    context.read<TranslatorProvider>().updateOriginalText(text);
  }

  void _onSpeakStatus() {
    if (mounted) setState(() {});
  }

  /// Starts making the Hiligaynon audio as soon as a translation is shown,
  /// so "Listen" can play right away.
  void _prepareVoice() {
    final s = _translator?.state;
    if (s == null || s.isTranslating || s.translatedText.isEmpty) return;
    if (s.sourceLanguage == Languages.tagalog) {
      TranslationSpeaker.prepare(numbersToWords(s.translatedText));
    }
  }

  /// Filipino -> Hiligaynon results use the native Hiligaynon voice, which
  /// needs numbers as words. The screen keeps showing the digits.
  Future<void> _speakResult(String text) {
    final source = context.read<TranslatorProvider>().state.sourceLanguage;
    final hiligaynon = source == Languages.tagalog;
    return _speaker.toggle(
      hiligaynon ? numbersToWords(text) : text,
      hiligaynon: hiligaynon,
    );
  }

  void _copyResult(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  // ── Voice and Camera (inside Translate, as in Figma) ─────────────────────
  /// Voice is its own screen for now; "Type instead" comes back here with
  /// the text box focused.
  Future<void> _openVoice() async {
    FocusScope.of(context).unfocus();
    final typeInstead = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VoiceTranslateScreen()),
    );
    if (typeInstead == true && mounted) _focus.requestFocus();
  }

  void _openScan() {
    FocusScope.of(context).unfocus();
    showScanOptions(context);
  }

  // ── UI (Figma 03 · Translate) ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;

    // Keep the field in step when the text changes from somewhere else
    // (a phrase chip, or the voice screen).
    if (_inputController.text != state.originalText && !_focus.hasFocus) {
      _inputController.text = state.originalText;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    }

    final from = isFilToHil ? 'Filipino' : 'Hiligaynon';
    final to = isFilToHil ? 'Hiligaynon' : 'Filipino';
    final text = _inputController.text;
    final showResult = state.isTranslating || state.translatedText.isNotEmpty;

    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              SizedBox(
                height: 64,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Translate', style: V6Text.headlineLargeTight.copyWith(letterSpacing: -0.28)),
                ),
              ),
              const SizedBox(height: 8),
              LanguageSwitchCard(
                from: from,
                to: to,
                swapTurns: CurvedAnimation(parent: _swap, curve: Curves.easeOutBack),
                onSwap: () {
                  _swap.forward(from: 0);
                  context.read<TranslatorProvider>().swapLanguages();
                },
              ),
              const SizedBox(height: 16),
              TranslationInputCard(
                language: from,
                filled: text.trim().isNotEmpty,
                characters: text.characters.length,
                onSpeak: _openVoice,
                onScan: _openScan,
                onTranslate: text.trim().isEmpty ? null : _translate,
                translating: state.isTranslating,
                textArea: TextField(
                  controller: _inputController,
                  focusNode: _focus,
                  minLines: 3,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  style: translationInputStyle,
                  cursorColor: V6Colors.primary,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type or paste text here',
                    hintStyle: translationInputStyle.copyWith(color: V6Colors.textMuted),
                  ),
                ),
              ),
              if (showResult) ...[
                const SizedBox(height: 16),
                TranslationResultCard(
                  language: to,
                  text: state.translatedText,
                  translating: state.isTranslating,
                  note: translationNote(isDictionaryMeaning: state.isDictionaryMeaning),
                  copied: _copied,
                  listen: switch (_speaker.status.value) {
                    SpeakStatus.idle => ListenState.idle,
                    SpeakStatus.preparing => ListenState.preparing,
                    SpeakStatus.speaking => ListenState.speaking,
                  },
                  onListen: () => _speakResult(state.translatedText),
                  onCopy: () => _copyResult(state.translatedText),
                ),
              ],
              const SizedBox(height: 24),
              _phrases(state),
            ],
          ),
        ),
      ),
    );
  }

  /// Common phrases (not in Figma; kept from before, in V6 chips).
  Widget _phrases(TranslatorState state) {
    final fromHil = state.sourceLanguage == Languages.hiligaynon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Common phrases', style: V6Text.titleMedium),
            const SizedBox(width: 8),
            Text('tap to translate', style: V6Text.caption.copyWith(color: V6Colors.textMuted)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final phrase in _commonPhrases)
              ActionChip(
                onPressed: () => _applyPhrase(phrase, state.sourceLanguage),
                avatar: Text(phrase.emoji),
                label: Text(fromHil ? phrase.hil : phrase.fil),
                labelStyle: V6Text.labelLarge.copyWith(color: V6Colors.textPrimary),
                backgroundColor: V6Colors.surface,
                side: const BorderSide(color: V6Colors.borderDivider),
                shape: const StadiumBorder(),
              ),
          ],
        ),
      ],
    );
  }
}
