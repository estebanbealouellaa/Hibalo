import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraTranslateScreen extends StatefulWidget {
  const CameraTranslateScreen({super.key});

  @override
  State<CameraTranslateScreen> createState() => _CameraTranslateScreenState();
}

class _CameraTranslateScreenState extends State<CameraTranslateScreen>
    with SingleTickerProviderStateMixin {
  File? _image;
  String extractedText = '';
  String translatedText = '';
  bool isLoading = false;
  bool hasScanned = false;
  String errorMessage = '';

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(Duration.zero, () => pickImage());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (picked == null) {
        if (mounted) Navigator.pop(context);
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
    } catch (e) {
      setState(() {
        errorMessage = 'Camera error: $e';
        isLoading = false;
      });
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
      await translateText(extractedText);
      await textRecognizer.close();

      if (mounted) {
        setState(() {
          isLoading = false;
          hasScanned = true;
        });
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
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        title: const Text(
          'Scan & Translate',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Image Preview ──────────────────────────────────────────
          _ImagePreviewSection(
            image: _image,
            isLoading: isLoading,
            pulseAnimation: _pulseAnimation,
            onRetake: pickImage,
          ),

          // ── Results Panel ──────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: _buildResultsPanel(theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsPanel(ThemeData theme) {
    if (isLoading) {
      return const _LoadingState();
    }

    if (errorMessage.isNotEmpty) {
      return _ErrorState(message: errorMessage, onRetry: pickImage);
    }

    if (!hasScanned) {
      return const _EmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scanned Text Card
          _ResultCard(
            label: 'Scanned Text',
            icon: Icons.document_scanner_outlined,
            iconColor: Colors.blueGrey,
            content: extractedText.isEmpty ? 'No text detected' : extractedText,
            onCopy: extractedText.isNotEmpty
                ? () => _copyToClipboard(extractedText)
                : null,
          ),

          const SizedBox(height: 16),

          // Translation Card
          _ResultCard(
            label: 'Translation',
            icon: Icons.translate_rounded,
            iconColor: purple,
            content: translatedText.isEmpty
                ? 'No translation found'
                : translatedText,
            isHighlighted: true,
            onCopy: translatedText.isNotEmpty
                ? () => _copyToClipboard(translatedText)
                : null,
          ),

          const SizedBox(height: 28),

          // Scan Again Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.camera_alt_rounded, size: 20),
              label: const Text(
                'Scan Again',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Image Preview Section
// ─────────────────────────────────────────────
class _ImagePreviewSection extends StatelessWidget {
  final File? image;
  final bool isLoading;
  final Animation<double> pulseAnimation;
  final VoidCallback onRetake;

  const _ImagePreviewSection({
    required this.image,
    required this.isLoading,
    required this.pulseAnimation,
    required this.onRetake,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      height: 260 + topPadding,
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image or placeholder
          if (image != null)
            Image.file(image!, fit: BoxFit.cover)
          else
            Container(
              color: Colors.grey.shade900,
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white24,
                size: 60,
              ),
            ),

          // Dark gradient overlay
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.45),
                  Colors.transparent,
                  Colors.black.withOpacity(0.5),
                ],
              ),
            ),
          ),

          // Scanning overlay
          if (isLoading) _ScanningOverlay(pulseAnimation: pulseAnimation),

          // Retake button (bottom-right)
          if (!isLoading && image != null)
            Positioned(
              bottom: 16,
              right: 16,
              child: GestureDetector(
                onTap: onRetake,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flip_camera_ios_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Retake',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Scanning Overlay with animated line
// ─────────────────────────────────────────────
class _ScanningOverlay extends StatelessWidget {
  final Animation<double> pulseAnimation;
  const _ScanningOverlay({required this.pulseAnimation});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: pulseAnimation,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: purple.withOpacity(0.8), width: 2),
                ),
                child: Stack(
                  children: [
                    // Corner accents
                    ..._cornerAccents(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Scanning…',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _cornerAccents() {
    const size = 18.0;
    const thickness = 3.0;
    final color = purple;

    Widget corner({
      required AlignmentGeometry alignment,
      required BorderRadius borderRadius,
    }) => Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border.all(color: color, width: thickness),
        ),
      ),
    );

    return [
      corner(
        alignment: Alignment.topLeft,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6)),
      ),
      corner(
        alignment: Alignment.topRight,
        borderRadius: const BorderRadius.only(topRight: Radius.circular(6)),
      ),
      corner(
        alignment: Alignment.bottomLeft,
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6)),
      ),
      corner(
        alignment: Alignment.bottomRight,
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(6)),
      ),
    ];
  }
}

// ─────────────────────────────────────────────
// Result Card
// ─────────────────────────────────────────────
class _ResultCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final String content;
  final bool isHighlighted;
  final VoidCallback? onCopy;

  const _ResultCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.content,
    this.isHighlighted = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isHighlighted ? purplePale : offWhite,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted
            ? Border.all(color: purple.withOpacity(0.25), width: 1.5)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              if (onCopy != null)
                GestureDetector(
                  onTap: onCopy,
                  child: Icon(
                    Icons.copy_rounded,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: isHighlighted ? 18 : 15,
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              height: 1.5,
              color: isHighlighted ? purple : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading State
// ─────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Recognizing text…',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Error State
// ─────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: Colors.red.shade400,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Empty / Initial State
// ─────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.document_scanner_outlined,
            size: 52,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Point your camera at text',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
