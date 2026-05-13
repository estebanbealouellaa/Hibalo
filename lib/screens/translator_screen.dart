import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/speech_service.dart';
import '../data/translator_data.dart';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final SpeechService _speechService = SpeechService();

  final TextEditingController _inputController = TextEditingController();

  bool _isListening = false;

  bool _isFilToHil = true;

  String _translatedText = '';

  // ─────────────────────────────────────────────
  // START LISTENING
  // ─────────────────────────────────────────────
  Future<void> _startListening() async {
    setState(() {
      _isListening = true;
    });

    await _speechService.startListening(
      localeId: 'fil_PH',

      onResult: (text) {
        setState(() {
          _inputController.text = text;
        });

        _translate(text);
      },
    );
  }

  // ─────────────────────────────────────────────
  // STOP LISTENING
  // ─────────────────────────────────────────────
  Future<void> _stopListening() async {
    await _speechService.stopListening();

    setState(() {
      _isListening = false;
    });
  }

  // ─────────────────────────────────────────────
  // TRANSLATE
  // ─────────────────────────────────────────────
  void _translate(String value) {
    final input = value.trim().toLowerCase();

    if (input.isEmpty) {
      setState(() {
        _translatedText = '';
      });

      return;
    }

    final dictionary = _isFilToHil
        ? TranslatorData.filToHil
        : TranslatorData.hilWords;

    // EXACT MATCH
    if (dictionary.containsKey(input)) {
      setState(() {
        _translatedText = dictionary[input]!;
      });

      return;
    }

    // WORD BY WORD
    final words = input.split(' ');

    final translatedWords = words.map((word) {
      return dictionary[word] ?? word;
    }).toList();

    setState(() {
      _translatedText = translatedWords.join(' ');
    });
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  void dispose() {
    _inputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF180028),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2B0044),

        elevation: 0,

        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 38, height: 38),

            const SizedBox(width: 10),

            const Text(
              'Hibalo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),

        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: const Center(
        child: Text(
          'Translator Screen Working',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
