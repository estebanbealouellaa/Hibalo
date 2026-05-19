import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CameraTranslateScreen extends StatefulWidget {
  const CameraTranslateScreen({super.key});

  @override
  State<CameraTranslateScreen> createState() => _CameraTranslateScreenState();
}

class _CameraTranslateScreenState extends State<CameraTranslateScreen> {
  File? _image;
  String extractedText = '';
  String translatedText = '';
  bool isLoading = true;
  String errorMessage = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      pickImage();
    });
  }

  Future<void> pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera);

      if (picked == null) {
        if (mounted) Navigator.pop(context);
        return;
      }

      setState(() {
        _image = File(picked.path);
        isLoading = true;
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

  Future<void> translateText(String text) async {
    try {
      final cleaned = text
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .trim();
      List<String> words = cleaned.split(' ');
      List<String> translatedWords = [];

      for (String word in words) {
        if (word.trim().isEmpty) continue;

        final hilSnapshot = await FirebaseFirestore.instance
            .collection('translations')
            .where('hil', isEqualTo: word)
            .limit(1)
            .get();

        if (hilSnapshot.docs.isNotEmpty) {
          translatedWords.add(hilSnapshot.docs.first['fil'] ?? word);
          continue;
        }

        final filSnapshot = await FirebaseFirestore.instance
            .collection('translations')
            .where('fil', isEqualTo: word)
            .limit(1)
            .get();

        if (filSnapshot.docs.isNotEmpty) {
          translatedWords.add(filSnapshot.docs.first['hil'] ?? word);
          continue;
        }

        translatedWords.add(word);
      }

      if (mounted) {
        setState(() {
          translatedText = translatedWords.join(' ');
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          translatedText = 'Translation error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Translate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(_image!, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            if (isLoading) const Center(child: CircularProgressIndicator()),
            if (errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            if (!isLoading && errorMessage.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Scanned Text',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      extractedText.isEmpty
                          ? 'No text detected'
                          : extractedText,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            if (!isLoading && errorMessage.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Translation',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      translatedText.isEmpty
                          ? 'No translation found'
                          : translatedText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            if (!isLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: pickImage,
                  child: const Text('Scan Again'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
