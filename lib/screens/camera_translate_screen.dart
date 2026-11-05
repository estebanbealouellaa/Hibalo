import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/translation/offline_translator.dart';
import '../services/translation/text_rules.dart';
import '../widgets/v6/v6.dart';
import '../widgets/v6/v6_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Figma 595:4593 "Scan options": a bottom sheet with Take a photo and
/// Choose from gallery; either opens [CameraTranslateScreen].
Future<void> showScanOptions(BuildContext context) {
  return showV6BottomSheet<void>(
    context,
    title: 'Scan text from a photo',
    description: 'Hibalo reads the words in the photo and translates them.',
    children: (sheet) => [
      _ScanOption(
        icon: Icons.photo_camera_rounded,
        title: 'Take a photo',
        subtitle: 'Use your camera',
        onTap: () => _openScan(sheet, context, ImageSource.camera),
      ),
      const SizedBox(height: 8),
      _ScanOption(
        icon: Icons.photo_library_rounded,
        title: 'Choose from gallery',
        subtitle: 'Pick a photo you already have',
        onTap: () => _openScan(sheet, context, ImageSource.gallery),
      ),
      const SizedBox(height: 8),
      Center(
        child: V6Button(label: 'Cancel', style: V6ButtonStyle.text, onPressed: () => Navigator.pop(sheet)),
      ),
    ],
  );
}

void _openScan(BuildContext sheet, BuildContext context, ImageSource source) {
  Navigator.pop(sheet);
  Navigator.push(context, MaterialPageRoute(builder: (_) => CameraTranslateScreen(source: source)));
}

class _ScanOption extends StatelessWidget {
  const _ScanOption({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: V6Colors.glowContainerSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: V6Colors.borderDivider),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: V6Colors.primaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 22, color: V6Colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: V6Text.titleMediumBold),
                    Text(subtitle, style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: V6Colors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scan text from a photo (Figma 05 · Camera): reading the photo
/// ("Scanning"), then the text with its translation ("Scan result"), or the
/// "No text found" / "Couldn't read" cards. Camera access off shows the
/// "Camera access is off" dialog. The OCR (ML Kit) and the translation are
/// the same as before.
class CameraTranslateScreen extends StatefulWidget {
  const CameraTranslateScreen({super.key, this.source = ImageSource.camera});

  /// Where the first photo comes from.
  final ImageSource source;

  @override
  State<CameraTranslateScreen> createState() => _CameraTranslateScreenState();
}

class _CameraTranslateScreenState extends State<CameraTranslateScreen> {
  File? _image;
  String extractedText = '';
  String translatedText = '';
  bool isLoading = false;
  bool hasScanned = false;
  String errorMessage = '';

  /// Direction of the toggle: true is Hil -> Fil, false is Fil -> Hil.
  bool _fromHiligaynon = true;
  bool _isTranslating = false;
  bool _isDictionaryMeaning = false;

  /// The scan, cut into lines or sentences to translate separately.
  List<String> _segments = [];

  /// Only the newest translation is shown; older ones are ignored.
  int _translationRequest = 0;


  final ImagePicker _picker = ImagePicker();

  /// Camera or gallery, for "Try again" / "Scan again".
  late ImageSource _source;

  bool _copied = false;

  @override
  void initState() {
    super.initState();



    OfflineTranslator.warmUp();
    _source = widget.source;
    Future.delayed(Duration.zero, () => pickImage());
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Picks from [source] (or the last one used) and reads it.
  Future<void> pickImage([ImageSource? source]) async {
    if (source != null) _source = source;
    try {
      final picked = await _picker.pickImage(
        source: _source,
        imageQuality: 90,
      );

      if (picked == null) {
        // Cancelled: leave if nothing was scanned yet.
        if (mounted && _image == null) Navigator.pop(context);
        return;
      }

      setState(() {
        _image = File(picked.path);
        isLoading = true;
        hasScanned = false;
        extractedText = '';
        translatedText = '';
        errorMessage = '';
      });

      await scanText();
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied' && mounted) {
        await _cameraAccessOff();
        return;
      }
      if (!mounted) return;
      setState(() {
        errorMessage = 'Camera error: $e';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Camera error: $e';
        isLoading = false;
      });
    }
  }

  /// Figma 595:4668 "Camera access is off".
  Future<void> _cameraAccessOff() async {
    final choice = await showV6ChoiceDialog(
      context,
      title: 'Camera access is off',
      message: 'To take a photo, allow camera access in your phone settings. '
          'You can still choose a photo from your gallery.',
      mascot: 'firefly_phone',
      primaryLabel: 'Open settings',
      textActions: const ['Choose from gallery', 'Not now'],
    );
    if (!mounted) return;
    switch (choice) {
      case 'Open settings':
        await openAppSettings();
        if (mounted && _image == null) Navigator.pop(context);
      case 'Choose from gallery':
        await pickImage(ImageSource.gallery);
      default:
        if (_image == null) Navigator.pop(context);
    }
  }

  Future<void> scanText() async {
    if (_image == null) return;

    try {
      final inputImage = InputImage.fromFile(_image!);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      extractedText = recognizedText.text;
      _segments = scanSegments([
        for (final block in recognizedText.blocks)
          [for (final line in block.lines) line.text],
      ]);
      await textRecognizer.close();

      if (mounted) {
        setState(() {
          isLoading = false;
          hasScanned = true;
        });
        await _translateScan();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'OCR error: $e';
          isLoading = false;
        });
      }
    }
  }

  /// Flips the direction and translates the scanned text again.
  void _toggleDirection() {
    HapticFeedback.selectionClick();
    setState(() => _fromHiligaynon = !_fromHiligaynon);
    _translateScan();
  }

  /// Translates the scanned text with the offline translator. Firestore is
  /// only the fallback for when the model can't be used.
  Future<void> _translateScan() async {
    final request = ++_translationRequest;
    final segments = _segments;
    if (segments.isEmpty) {
      setState(() {
        translatedText = '';
        _isTranslating = false;
      });
      return;
    }

    setState(() {
      translatedText = '';
      _isDictionaryMeaning = false;
      _isTranslating = true;
    });

    bool isStale() => !mounted || request != _translationRequest;
    try {
      // One line of the result for each piece of the scan.
      final done = <String>[];
      for (final segment in segments) {
        final result = await OfflineTranslator.instance.translate(
          segment,
          fromHiligaynon: _fromHiligaynon,
          partOfParagraph: segments.length >= 2,
          onPartial: (textSoFar) {
            if (isStale()) return;
            setState(() => translatedText = [...done, textSoFar].join('\n'));
          },
        );
        if (isStale()) return;
        done.add(result.text);
        setState(() {
          translatedText = done.join('\n');
          _isDictionaryMeaning =
              segments.length == 1 && result.isDictionaryMeaning;
        });
      }
    } catch (e) {
      debugPrint('[HibaloTranslate] using Firestore instead: $e');
      await translateText(extractedText);
    }
    if (!isStale()) setState(() => _isTranslating = false);
  }

  /// Cleans text: lowercase, remove punctuation EXCEPT hyphens, apostrophes,
  /// and question marks (needed to match Firestore entries like "sud-an", "gab-i",
  /// "diin kita makadto?"), trim extra spaces.
  String _clean(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s\-?']"), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Low-level Firestore lookup: checks hil→fil then fil→hil for an exact phrase.
  Future<String?> _firestoreLookup(String phrase) async {
    // Try Hiligaynon → Filipino
    final hilSnap = await FirebaseFirestore.instance
        .collection('translations')
        .where('hil', isEqualTo: phrase)
        .limit(1)
        .get();
    if (hilSnap.docs.isNotEmpty) {
      return hilSnap.docs.first['fil'] as String?;
    }

    // Try Filipino → Hiligaynon
    final filSnap = await FirebaseFirestore.instance
        .collection('translations')
        .where('fil', isEqualTo: phrase)
        .limit(1)
        .get();
    if (filSnap.docs.isNotEmpty) {
      return filSnap.docs.first['hil'] as String?;
    }

    return null;
  }

  /// Try to find a Firestore match for a phrase, with punctuation-tolerant fallbacks:
  /// 1. Exact match
  /// 2. Without trailing punctuation (OCR may capture "?" but Firestore entry may not have it)
  /// 3. With trailing "?" added (OCR may have dropped it)
  Future<String?> _lookupPhrase(String phrase) async {
    // 1. Try as-is
    String? result = await _firestoreLookup(phrase);
    if (result != null) return result;

    // 2. Try without trailing punctuation
    final stripped = phrase.replaceAll(RegExp(r'[?!.,]+$'), '').trim();
    if (stripped != phrase) {
      result = await _firestoreLookup(stripped);
      if (result != null) return result;
    }

    // 3. Try with a trailing "?" added (OCR may have dropped it)
    result = await _firestoreLookup('$phrase?');
    return result;
  }

  Future<void> translateText(String text) async {
    try {
      final cleaned = _clean(text);

      // ── Step 1: Try full sentence match first ──────────────────────
      final fullMatch = await _lookupPhrase(cleaned);
      if (fullMatch != null) {
        if (mounted) setState(() => translatedText = fullMatch);
        return;
      }

      // ── Step 2: Try line by line (multi-line scans) ────────────────
      final lines = cleaned
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.length > 1) {
        List<String> translatedLines = [];
        for (final line in lines) {
          final lineMatch = await _lookupPhrase(line);
          if (lineMatch != null) {
            translatedLines.add(lineMatch);
          } else {
            // Fall back to word-by-word for this line
            translatedLines.add(await _translateWordByWord(line));
          }
        }
        if (mounted) {
          setState(() => translatedText = translatedLines.join('\n'));
        }
        return;
      }

      // ── Step 3: Word-by-word fallback ──────────────────────────────
      final wordResult = await _translateWordByWord(cleaned);
      if (mounted) setState(() => translatedText = wordResult);
    } catch (e) {
      if (mounted) {
        setState(() => translatedText = 'Translation error: $e');
      }
    }
  }

  /// Word-by-word translation fallback
  Future<String> _translateWordByWord(String cleaned) async {
    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();
    final List<String> result = [];

    for (final word in words) {
      final match = await _lookupPhrase(word);
      result.add(match ?? word);
    }

    return result.join(' ');
  }

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: text));
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final from = _fromHiligaynon ? 'Hiligaynon' : 'Filipino';
    final to = _fromHiligaynon ? 'Filipino' : 'Hiligaynon';
    final noText = hasScanned && extractedText.trim().isEmpty;

    final Widget body;
    if (errorMessage.isNotEmpty) {
      // Figma 597:5049 "Couldn't read".
      body = V6MessageCard(
        icon: Icons.error_outline_rounded,
        iconColor: V6Colors.error,
        background: V6Colors.coralContainer,
        title: "Couldn't read the photo",
        message: 'Something went wrong. Please try again or choose another photo.',
        actions: [
          V6Button(label: 'Try again', style: V6ButtonStyle.secondary, onPressed: () => pickImage()),
          V6Button(
            label: 'Choose another',
            style: V6ButtonStyle.text,
            onPressed: () => pickImage(ImageSource.gallery),
          ),
        ],
      );
    } else if (noText) {
      // Figma 597:4962 "No text found".
      body = V6MessageCard(
        icon: Icons.document_scanner_rounded,
        background: V6Colors.glowContainerSoft,
        title: 'No text found',
        message: 'Try a clearer photo with good light, and keep the words straight and close.',
        actions: [
          V6Button(
            label: 'Take a photo',
            style: V6ButtonStyle.secondary,
            onPressed: () => pickImage(ImageSource.camera),
          ),
          V6Button(
            label: 'Choose from gallery',
            style: V6ButtonStyle.text,
            onPressed: () => pickImage(ImageSource.gallery),
          ),
        ],
      );
    } else if (hasScanned) {
      body = _result(from, to);
    } else {
      body = _scanning();
    }

    return Scaffold(
      backgroundColor: V6Colors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            V6TopAppBar(title: 'Scan text', onBack: () => Navigator.pop(context)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  LanguageSwitchCard(from: from, to: to, onSwap: _toggleDirection),
                  const SizedBox(height: 16),
                  body,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Figma 597:4775 "Scanning": the photo, "Reading the text…", a bar and
  /// Cancel.
  Widget _scanning() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: V6Colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: V6Colors.borderDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 300,
              child: _image == null
                  ? const ColoredBox(color: V6Colors.surfaceTint)
                  : Image.file(_image!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.document_scanner_rounded, size: 22, color: V6Colors.primary),
                    const SizedBox(width: 10),
                    Text('Reading the text…', style: V6Text.titleMediumBold),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: const LinearProgressIndicator(
                    minHeight: 8,
                    color: V6Colors.primary,
                    backgroundColor: V6Colors.primaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This takes a few seconds and works offline.',
                  style: V6Text.bodyMedium.copyWith(color: V6Colors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: V6Button(label: 'Cancel', style: V6ButtonStyle.text, onPressed: () => Navigator.pop(context)),
          ),
        ],
      ),
    );
  }

  /// Figma 597:4863 "Scan result": "From your photo" + Scan again, the
  /// photo's text, and the translation.
  Widget _result(String from, String to) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FromSourceRow(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: _image == null
                ? const SourceIconTile(icon: Icons.photo_rounded)
                : Image.file(_image!, fit: BoxFit.cover),
          ),
          text: 'From your photo · check for mistakes',
          actionLabel: 'Scan again',
          onAction: () => pickImage(),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            color: V6Colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: V6Colors.borderFocus, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(from, style: V6Text.labelLarge.copyWith(color: V6Colors.textSecondary)),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(minHeight: 120),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: V6Colors.surfaceTint, borderRadius: BorderRadius.circular(12)),
                child: SelectableText(extractedText, style: translationInputStyle),
              ),
              const SizedBox(height: 8),
              Text(
                '${extractedText.characters.length} characters',
                textAlign: TextAlign.right,
                style: V6Text.caption.copyWith(color: V6Colors.textMuted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TranslationResultCard(
          language: to,
          text: translatedText,
          translating: _isTranslating,
          note: translationNote(isDictionaryMeaning: _isDictionaryMeaning),
          copied: _copied,
          onListen: null,
          onCopy: () => _copyToClipboard(translatedText),
        ),
      ],
    );
  }
}
