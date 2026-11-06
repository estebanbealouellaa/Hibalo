import '../l10n/app_localizations.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/translator_state.dart';
import '../providers/translator_provider.dart';
import '../services/translation/hil_numbers.dart';
import '../services/translation/offline_translator.dart';
import '../services/translation/scan_translator.dart';
import '../services/translation_store.dart';
import '../services/tts/translation_speaker.dart';
import '../widgets/filipino_voice_dialog.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_translate.dart';
import 'translate/history_screen.dart';
import 'translate/scan_pieces.dart';
import 'translate/voice_popup.dart';

/// Where the text in the input came from, for the "From your voice /
/// photo · check for mistakes" row.
enum TextOrigin { typed, voice, photo }

/// The Camera part of Translate: idle, reading a photo, or a message card.
enum ScanStage { idle, scanning, noText, failed }

/// The Translate tab: its own navigator, so History opens inside the tab
/// with the bottom bar showing (Figma 623:6168).
class TranslateTab extends StatefulWidget {
  const TranslateTab({super.key});

  static final GlobalKey<NavigatorState> _navigator = GlobalKey<NavigatorState>();

  /// Back on the Translate tab: close History, else cancel a running scan.
  /// True when handled (the tab bar then stays on Translate).
  static bool handleBack() {
    final nav = _navigator.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return TranslatorScreen.handleBack?.call() ?? false;
  }

  @override
  State<TranslateTab> createState() => _TranslateTabState();
}

class _TranslateTabState extends State<TranslateTab> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: TranslateTab._navigator,
      onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const TranslatorScreen()),
    );
  }
}

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

  /// For History: a translation finished when this goes from true to false.
  bool _wasTranslating = false;

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
      ..addListener(_prepareVoice)
      ..addListener(_recordHistory);
    TranslationStore.instance.load();
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
    _translator?.removeListener(_recordHistory);
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

  /// The current text and translation as a History / Saved entry.
  TranslationEntry _entryOf(TranslatorState s) => TranslationEntry(
    source: s.originalText.trim(),
    translation: s.translatedText.trim(),
    fromHiligaynon: s.sourceLanguage == Languages.hiligaynon,
    input: switch (_origin) {
      TextOrigin.voice => EntryInput.voice,
      TextOrigin.photo => EntryInput.photo,
      TextOrigin.typed => EntryInput.typed,
    },
    time: DateTime.now(),
  );

  /// Adds each finished translation (typed, voice or photo) to History,
  /// on this phone only.
  void _recordHistory() {
    final s = _translator?.state;
    if (s == null) return;
    final finished = _wasTranslating && !s.isTranslating;
    _wasTranslating = s.isTranslating;
    if (!finished || s.originalText.trim().isEmpty || s.translatedText.trim().isEmpty) return;
    if (s.translatedText.startsWith('Translation error')) return;
    TranslationStore.instance.addToHistory(_entryOf(s));
  }

  /// History (and Saved), inside the Translate tab. A tapped item comes
  /// back here with its translation.
  Future<void> _openHistory() async {
    FocusScope.of(context).unfocus();
    final entry = await Navigator.of(
      context,
    ).push<TranslationEntry>(MaterialPageRoute(builder: (_) => const TranslateHistoryScreen()));
    if (!mounted) return;
    // Coming back puts focus on the text box again; keep the keyboard closed.
    _focus.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.unfocus());
    if (entry == null) return;
    _scanRequest++;
    setState(() {
      _scan = ScanStage.idle;
      _origin = TextOrigin.typed;
    });
    context.read<TranslatorProvider>().restore(
      originalText: entry.source,
      translatedText: entry.translation,
      sourceLanguage: entry.fromHiligaynon ? Languages.hiligaynon : Languages.tagalog,
    );
  }

  /// Android's share menu with both texts.
  void _share(TranslatorState s) {
    final e = _entryOf(s);
    SharePlus.instance.share(ShareParams(text: shareText(e)));
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

  /// Clears the text and its translation (the direction stays).
  void _clear() {
    HapticFeedback.selectionClick();
    _inputController.clear();
    setState(() {
      _origin = TextOrigin.typed;
      if (_scan != ScanStage.scanning) _scan = ScanStage.idle;
    });
    context.read<TranslatorProvider>().updateOriginalText('');
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
    final t = AppLocalizations.of(context);
    final choice = await showV6ChoiceDialog(
      context,
      title: t.camAccessOffTitle,
      message: t.camAccessOffBody,
      mascot: 'firefly_phone',
      primaryLabel: t.commonOpenSettings,
      textActions: [t.commonChooseFromGallery, t.commonNotNow],
    );
    if (!mounted) return;
    if (choice == t.commonOpenSettings) {
      await openAppSettings();
    } else if (choice == t.commonChooseFromGallery) {
      await _scanFrom(ImageSource.gallery);
    }
  }

  // ── UI (Figma 03 · Translate) ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                child: Row(
                  children: [
                    Expanded(child: Text(t.trTitle, style: V6Text.headlineLargeTight.copyWith(letterSpacing: -0.28))),
                    V6IconButton(icon: Icons.history_rounded, tooltip: t.trHistory, onPressed: _openHistory),
                  ],
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
                  onClear: _clear,
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
                      hintText: t.trTypeHere,
                      hintStyle: translationInputStyle.copyWith(color: V6Colors.textMuted),
                    ),
                  ),
                ),
              ],
              if (showResult) ...[
                const SizedBox(height: 16),
                ListenableBuilder(
                  listenable: TranslationStore.instance,
                  builder: (context, _) => TranslationResultCard(
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
                    onShare: () => _share(state),
                    saved: TranslationStore.instance.isSaved(_entryOf(state)),
                    onSave: () => TranslationStore.instance.toggleSaved(_entryOf(state)),
                  ),
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
    final t = AppLocalizations.of(context);
    const gap = SizedBox(height: 12);
    switch (_scan) {
      case ScanStage.noText:
        return [
          V6MessageCard(
            icon: Icons.document_scanner_rounded,
            background: V6Colors.glowContainerSoft,
            title: t.camNoTextTitle,
            message: t.camNoTextBody,
            actions: [
              V6Button(
                label: t.commonTakePhoto,
                style: V6ButtonStyle.secondary,
                onPressed: () => _scanFrom(ImageSource.camera),
              ),
              V6Button(
                label: t.commonChooseFromGallery,
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
            title: t.camCouldntReadTitle,
            message: t.camCouldntReadBody,
            actions: [
              V6Button(label: t.tryAgain, style: V6ButtonStyle.secondary, onPressed: () => _scanFrom(_source)),
              V6Button(
                label: t.camChooseAnother,
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
          text: t.trFromVoice,
          actionLabel: t.trSpeakAgain,
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
          text: t.trFromPhoto,
          actionLabel: t.trScanAgain,
          onAction: _openScan,
        ),
        gap,
      ],
      TextOrigin.typed => const [],
    };
  }
}
