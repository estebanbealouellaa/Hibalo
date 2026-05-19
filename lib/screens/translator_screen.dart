import 'package:flutter/material.dart';

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

  // MODERN COLORS
  final Color primary = const Color(0xFF7C3AED);
  final Color secondary = const Color(0xFFA855F7);
  final Color background = const Color(0xFFF5F3FF);
  final Color cardColor = Colors.white;

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

    final Map<String, String> fullDictionary = _isFilToHil
        ? TranslatorData.filToHil
        : TranslatorData.hilWords;

    final Map<String, String> wordDictionary = _isFilToHil
        ? TranslatorData.filWords
        : TranslatorData.hilWords;

    if (fullDictionary.containsKey(input)) {
      setState(() {
        _translatedText = fullDictionary[input]!;
      });

      return;
    }

    final List<String> words = input.split(' ');

    final List<String> translatedWords = words.map((word) {
      return wordDictionary[word] ?? word;
    }).toList();

    setState(() {
      _translatedText = translatedWords.join(' ');
    });
  }

  @override
  void dispose() {
    _inputController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        automaticallyImplyLeading: false,

        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [primary, secondary]),

                borderRadius: BorderRadius.circular(14),
              ),

              child: Image.asset('lib/assets/logo.png', width: 26, height: 26),
            ),

            const SizedBox(width: 12),

            const Text(
              'Hibalo Translator',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              // ─────────────────────────────
              // TOP CARD
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Realtime Voice Translation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Translate Filipino ↔ Hiligaynon instantly using voice and text.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // LANGUAGE SWITCH
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Expanded(
                            child: Text(
                              _isFilToHil ? 'Filipino' : 'Hiligaynon',

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isFilToHil = !_isFilToHil;

                                _inputController.clear();

                                _translatedText = '';
                              });
                            },

                            child: Container(
                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: primary,
                                size: 28,
                              ),
                            ),
                          ),

                          Expanded(
                            child: Text(
                              _isFilToHil ? 'Hiligaynon' : 'Filipino',

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────
              // INPUT CARD
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.05),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note_rounded, color: primary),

                        const SizedBox(width: 8),

                        Text(
                          _isFilToHil ? 'Filipino Input' : 'Hiligaynon Input',

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _inputController,

                      maxLines: 6,

                      style: const TextStyle(fontSize: 18, height: 1.5),

                      decoration: InputDecoration(
                        hintText: 'Type something here...',

                        hintStyle: TextStyle(color: Colors.grey.shade500),

                        filled: true,
                        fillColor: background,

                        contentPadding: const EdgeInsets.all(20),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),

                          borderSide: BorderSide(color: primary, width: 2),
                        ),
                      ),

                      onChanged: (value) {
                        _translate(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────
              // MIC BUTTON
              // ─────────────────────────────
              GestureDetector(
                onLongPressStart: (_) {
                  _startListening();
                },

                onLongPressEnd: (_) {
                  _stopListening();
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  width: _isListening ? 120 : 105,
                  height: _isListening ? 120 : 105,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(colors: [primary, secondary]),

                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(.35),
                        blurRadius: 25,
                        spreadRadius: 4,
                      ),
                    ],
                  ),

                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: Colors.white,
                    size: 46,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                _isListening
                    ? 'Listening... release to stop'
                    : 'Hold microphone to speak',

                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 30),

              // ─────────────────────────────
              // OUTPUT CARD
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade300,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: const [
                        Icon(Icons.translate_rounded, color: Colors.white),

                        SizedBox(width: 8),

                        Text(
                          'Translation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      _translatedText.isEmpty
                          ? 'Your translated text will appear here...'
                          : _translatedText,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
