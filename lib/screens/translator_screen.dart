import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../models/translator_state.dart';
import '../providers/translator_provider.dart';
import '../services/translation/hil_numbers.dart';
import '../services/translation/offline_translator.dart';
import '../services/translation/scan_translator.dart';
import '../services/tts/translation_speaker.dart';
import '../widgets/filipino_voice_dialog.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_translate.dart';
import 'translate/scan_pieces.dart';
import 'translate/voice_popup.dart';

/// Where the text in the input came from, for the "From your voice /
/// photo · check for mistakes" row.
enum TextOrigin { typed, voice, photo }

/// The Camera part of Translate: idle, reading a photo, or a message card.
enum ScanStage { idle, scanning, noText, failed }

/// Translate (Figma 03 · Translate). Voice opens as a pop-up over it and the
/// photo scan happens inside it (Figma 04 · Voice, 05 · Camera), with the
/// bottom bar showing.
class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key, this.micPermission, this.readPhoto});

  /// For tests: the microphone permission status.
  final Future<PermissionStatus> Function()? micPermission;

  /// For tests: reads a photo's text (ML Kit when null).
  final Future<PhotoText> Function(File photo)? readPhoto;

  /// Set while Translate wants the back button (to cancel a scan); returns
  /// true when it handled it. The tab bar asks it before going Home.
  static bool Function()? handleBack;

  @override
  State<TranslatorScreen> createState() => TranslatorScreenState();
}

class TranslatorScreenState extends State<TranslatorScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _focus = FocusNode();
  final TranslationSpeaker _speaker = TranslationSpeaker();
  final ImagePicker _picker = ImagePicker();
  TranslatorProvider? _translator;

  late final AnimationController _swap;

  bool _copied = false;

  /// The provider's text last copied into the field.
  String _lastOriginal = '';

  TextOrigin _origin = TextOrigin.typed;

  /// The text voice / the photo put in; editing it hides the "From your…"
  /// row.
  String _originText = '';

  ScanStage _scan = ScanStage.idle;
  File? _photo;
  ImageSource _source = ImageSource.camera;

  /// Only the newest scan is used; Cancel makes the running one stale.
  int _scanRequest = 0;

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

    _swap = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _inputController.addListener(_onTextChanged);
    TranslatorScreen.handleBack = _handleBack;
  }

  @override
  void dispose() {
    if (TranslatorScreen.handleBack == _handleBack) TranslatorScreen.handleBack = null;
    _inputController.dispose();
    _focus.dispose();
    _swap.dispose();
    _translator?.removeListener(_prepareVoice);
    _speaker.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      // Editing the text hides the "From your…" row and the message cards.
      if (_origin != TextOrigin.typed && _inputController.text != _originText) _origin = TextOrigin.typed;
      if ((_scan == ScanStage.noText || _scan == ScanStage.failed) && _inputController.text.isNotEmpty) {
        _scan = ScanStage.idle;
      }
    });
  }

  /// Back while reading a photo cancels the scan.
  bool _handleBack() {
    if (_scan != ScanStage.scanning) return false;
    _cancelScan();
    return true;
  }

  // ── Actions ─────────────────────────────────────────────────────────────
  void _translate() {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    context.read<TranslatorProvider>().updateOriginalText(_inputController.text);
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
    return _speaker.toggle(hiligaynon ? numbersToWords(text) : text, hiligaynon: hiligaynon);
  }

  void _copyResult(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _swapLanguages() {
    _swap.forward(from: 0);
    setState(() => _origin = TextOrigin.typed);
    context.read<TranslatorProvider>().swapLanguages();
  }

  // ── Voice (Figma 04 · Voice): a pop-up over Translate ───────────────────
  Future<void> _openVoice() async {
    FocusScope.of(context).unfocus();
    final outcome = await showVoicePopup(context, micPermission: widget.micPermission);
    if (!mounted) return;
    switch (outcome) {
      case VoiceOutcome.spoke:
        setState(() {
          _scan = ScanStage.idle;
          _origin = TextOrigin.voice;
          _originText = context.read<TranslatorProvider>().state.originalText;
        });
      case VoiceOutcome.typeInstead:
        _focus.requestFocus();
      case null:
        break;
    }
  }

  // ── Camera (Figma 05 · Camera): inside Translate ────────────────────────
  Future<void> _openScan() async {
    FocusScope.of(context).unfocus();
    final source = await showScanOptions(context);
    if (source != null && mounted) await _scanFrom(source);
  }

  /// Picks a photo from [source] and reads it. The OCR and its translation
  /// are the same as the old Camera screen's.
  Future<void> _scanFrom(ImageSource source) async {
    _source = source;
    final XFile? picked;
    try {
      picked = await _picker.pickImage(source: source, imageQuality: 90);
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'camera_access_denied') {
        await _cameraAccessOff();
      } else {
        _scanFailed();
      }
      return;
    } catch (_) {
      if (mounted) _scanFailed();
      return;
    }
    if (picked == null || !mounted) return; // Cancelled: nothing changes.
    await scanPhoto(File(picked.path));
  }

  /// Reads [photo] and puts its text in the input (public for tests).
  Future<void> scanPhoto(File photo) async {
    final request = ++_scanRequest;
    final provider = context.read<TranslatorProvider>();
    setState(() {
      _photo = photo;
      _scan = ScanStage.scanning;
      _origin = TextOrigin.typed;
    });
    try {
      final read = await (widget.readPhoto ?? readPhotoText)(photo);
      if (!mounted || request != _scanRequest) return;
      if (read.text.trim().isEmpty) {
        setState(() => _scan = ScanStage.noText);
        provider.updateOriginalText('');
        return;
      }
      setState(() {
        _scan = ScanStage.idle;
        _origin = TextOrigin.photo;
        _originText = read.text;
      });
      await provider.showScan(read);
    } catch (e) {
      debugPrint('[HibaloScan] could not read the photo: $e');
      if (mounted && request == _scanRequest) _scanFailed();
    }
  }

  void _scanFailed() {
    setState(() {
      _scan = ScanStage.failed;
      _origin = TextOrigin.typed;
    });
    context.read<TranslatorProvider>().updateOriginalText('');
  }

  void _cancelScan() {
    _scanRequest++;
    setState(() => _scan = ScanStage.idle);
  }

  /// Figma 595:4668 "Camera access is off".
  Future<void> _cameraAccessOff() async {
    final choice = await showV6ChoiceDialog(
      context,
      title: 'Camera access is off',
      message:
          'To take a photo, allow camera access in your phone settings. '
          'You can still choose a photo from your gallery.',
      mascot: 'firefly_phone',
      primaryLabel: 'Open settings',
      textActions: const ['Choose from gallery', 'Not now'],
    );
    if (!mounted) return;
    switch (choice) {
      case 'Open settings':
        await openAppSettings();
      case 'Choose from gallery':
        await _scanFrom(ImageSource.gallery);
    }
  }

  // ── UI (Figma 03 · Translate) ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TranslatorProvider>();
    final state = provider.state;
    final isFilToHil = state.sourceLanguage == Languages.tagalog;

    // Put the provider's text in the field when it changes (voice, a scan,
    // a swap); what the user is typing stays until they translate.
    if (state.originalText != _lastOriginal) {
      _lastOriginal = state.originalText;
      _inputController.value = TextEditingValue(
        text: state.originalText,
        selection: TextSelection.collapsed(offset: state.originalText.length),
      );
    }

    final from = isFilToHil ? 'Filipino' : 'Hiligaynon';
    final to = isFilToHil ? 'Hiligaynon' : 'Filipino';
    final text = _inputController.text;
    final scanning = _scan == ScanStage.scanning;
    final showResult = !scanning && (state.isTranslating || state.translatedText.isNotEmpty);

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
                onSwap: scanning || state.isListening ? null : _swapLanguages,
              ),
              const SizedBox(height: 16),
              if (scanning)
                ScanningCard(photo: _photo, onCancel: _cancelScan)
              else ...[
                ..._above(),
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
              ],
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
            ],
          ),
        ),
      ),
    );
  }

  /// What sits above the input card: the "From your voice / photo" row
  /// (Figma 600:5120, 597:4863) or a scan message card (597:4962, 597:5049).
  List<Widget> _above() {
    const gap = SizedBox(height: 12);
    switch (_scan) {
      case ScanStage.noText:
        return [
          V6MessageCard(
            icon: Icons.document_scanner_rounded,
            background: V6Colors.glowContainerSoft,
            title: 'No text found',
            message: 'Try a clearer photo with good light, and keep the words straight and close.',
            actions: [
              V6Button(
                label: 'Take a photo',
                style: V6ButtonStyle.secondary,
                onPressed: () => _scanFrom(ImageSource.camera),
              ),
              V6Button(
                label: 'Choose from gallery',
                style: V6ButtonStyle.text,
                onPressed: () => _scanFrom(ImageSource.gallery),
              ),
            ],
          ),
          gap,
        ];
      case ScanStage.failed:
        return [
          V6MessageCard(
            icon: Icons.error_outline_rounded,
            iconColor: V6Colors.error,
            background: V6Colors.coralContainer,
            title: "Couldn't read the photo",
            message: 'Something went wrong. Please try again or choose another photo.',
            actions: [
              V6Button(label: 'Try again', style: V6ButtonStyle.secondary, onPressed: () => _scanFrom(_source)),
              V6Button(
                label: 'Choose another',
                style: V6ButtonStyle.text,
                onPressed: () => _scanFrom(ImageSource.gallery),
              ),
            ],
          ),
          gap,
        ];
      case ScanStage.idle || ScanStage.scanning:
        break;
    }
    return switch (_origin) {
      TextOrigin.voice => [
        FromSourceRow(
          leading: const SourceIconTile(icon: Icons.mic_rounded),
          text: 'From your voice · check for mistakes',
          actionLabel: 'Speak again',
          onAction: _openVoice,
        ),
        gap,
      ],
      TextOrigin.photo => [
        FromSourceRow(
          leading: ClipOval(
            child: _photo == null
                ? const SourceIconTile(icon: Icons.photo_rounded)
                : Image.file(_photo!, fit: BoxFit.cover),
          ),
          text: 'From your photo · check for mistakes',
          actionLabel: 'Scan again',
          onAction: _openScan,
        ),
        gap,
      ],
      TextOrigin.typed => const [],
    };
  }
}
