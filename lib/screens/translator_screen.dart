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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

          child: Column(
            children: [
              // ─────────────────────────────
              // TOP CARD - REDUCED PADDING
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(24),

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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Translate Filipino ↔ Hiligaynon instantly.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(.9),
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // LANGUAGE SWITCH - SMALLER
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),

                        borderRadius: BorderRadius.circular(16),
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
                                fontSize: 14,
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
                              padding: const EdgeInsets.all(8),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: primary,
                                size: 22,
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
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────
              // INPUT CARD - SMALLER
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: cardColor,

                  borderRadius: BorderRadius.circular(24),

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
                        Icon(Icons.edit_note_rounded, color: primary, size: 22),

                        const SizedBox(width: 8),

                        Text(
                          _isFilToHil ? 'Filipino Input' : 'Hiligaynon Input',

                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: _inputController,

                      maxLines: 3,

                      style: const TextStyle(fontSize: 15, height: 1.4),

                      decoration: InputDecoration(
                        hintText: 'Type something here...',

                        hintStyle: TextStyle(color: Colors.grey.shade500),

                        filled: true,
                        fillColor: background,

                        contentPadding: const EdgeInsets.all(14),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

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

              const SizedBox(height: 16),

              // ─────────────────────────────
              // MIC BUTTON - SMALLER
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

                  width: _isListening ? 90 : 80,
                  height: _isListening ? 90 : 80,

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
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isListening
                    ? 'Listening... release to stop'
                    : 'Hold microphone to speak',

                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 14),

              // ─────────────────────────────
              // OUTPUT CARD - SMALLER
              // ─────────────────────────────
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade300,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(24),

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
                        Icon(
                          Icons.translate_rounded,
                          color: Colors.white,
                          size: 22,
                        ),

                        SizedBox(width: 8),

                        Text(
                          'Translation',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _translatedText.isEmpty
                          ? 'Your translated text will appear here...'
                          : _translatedText,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
