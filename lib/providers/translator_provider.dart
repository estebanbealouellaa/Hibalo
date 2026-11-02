import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../services/database_service.dart';
import '../services/nlp_service.dart';
import '../services/translation/offline_translator.dart';
import '../models/translator_state.dart';

class TranslatorProvider extends ChangeNotifier {
  TranslatorState _state = const TranslatorState();

  TranslatorState get state => _state;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final NLPService _nlp = NLPService();

  bool _speechAvailable = false;

  // Only the newest translation is shown; older ones are ignored.
  int _translationRequest = 0;

  TranslatorProvider() {
    _initSpeech();
  }

  // ─────────────────────────────────────────────
  // INIT SPEECH
  // ─────────────────────────────────────────────
  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onError: (error) {
        _state = _state.copyWith(
          isListening: false,
          partialSpeechText: '',
          recognitionError: _mapError(error.errorMsg),
        );

        notifyListeners();
      },

      onStatus: (status) {
        if (status == stt.SpeechToText.doneStatus ||
            status == stt.SpeechToText.notListeningStatus) {
          _state = _state.copyWith(isListening: false, partialSpeechText: '');

          notifyListeners();
        }
      },
    );

    if (!_speechAvailable) {
      _state = _state.copyWith(
        recognitionError: 'Speech recognition not available on this device.',
      );

      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // START LISTENING
  // ─────────────────────────────────────────────
  Future<void> startListening() async {
    if (!_speechAvailable) {
      await _initSpeech();

      if (!_speechAvailable) return;
    }

    _state = _state.copyWith(recognitionError: '', partialSpeechText: '');

    notifyListeners();

    await _speech.listen(
      localeId: 'fil_PH',

      listenFor: const Duration(seconds: 30),

      pauseFor: const Duration(seconds: 10),

      partialResults: true,

      onResult: (result) {
        if (result.finalResult) {
          final spoken = result.recognizedWords;

          _state = _state.copyWith(isListening: false, partialSpeechText: '');

          notifyListeners();

          if (spoken.isNotEmpty) {
            updateOriginalText(spoken);
          }
        } else {
          _state = _state.copyWith(
            isListening: true,
            partialSpeechText: result.recognizedWords,
          );

          notifyListeners();
        }
      },
    );

    _state = _state.copyWith(isListening: true);

    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // STOP LISTENING
  // ─────────────────────────────────────────────
  Future<void> stopListening() async {
    await _speech.stop();

    _state = _state.copyWith(isListening: false);

    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // TRANSLATE
  // ─────────────────────────────────────────────
  // The offline model is the main path. Firestore is only the fallback for
  // when the model can't be used.
  Future<(String, bool)> _doTranslate(
    String text,
    String sourceLanguage,
    void Function(String textSoFar) onPartial,
  ) async {
    try {
      final result = await OfflineTranslator.instance.translate(
        text,
        fromHiligaynon: sourceLanguage == Languages.hiligaynon,
        onPartial: onPartial,
      );

      return (result.text, result.isDictionaryMeaning);
    } catch (e) {
      debugPrint('[HibaloTranslate] using Firestore instead: $e');

      return (await _firestoreTranslate(text, sourceLanguage), false);
    }
  }

  Future<String> _firestoreTranslate(
    String text,
    String sourceLanguage,
  ) async {
    final cleaned = _nlp.preprocess(text);

    if (sourceLanguage == 'hiligaynon') {
      final result = await DatabaseService.translateToFilipino(cleaned);

      return result ?? cleaned;
    } else {
      final result = await DatabaseService.translateToHiligaynon(cleaned);

      return result ?? cleaned;
    }
  }

  // ─────────────────────────────────────────────
  // UPDATE ORIGINAL TEXT
  // ─────────────────────────────────────────────
  Future<void> updateOriginalText(String text) async {
    _state = _state.copyWith(originalText: text);

    await _performTranslation(text);
  }

  // ─────────────────────────────────────────────
  // PERFORM TRANSLATION
  // ─────────────────────────────────────────────
  Future<void> _performTranslation(String text) async {
    final request = ++_translationRequest;

    if (text.isEmpty) {
      _state = _state.copyWith(translatedText: '', isTranslating: false);

      notifyListeners();

      return;
    }

    _state = _state.copyWith(translatedText: '', isTranslating: true);

    notifyListeners();

    // Finished sentences are shown while the rest is still being translated.
    final (result, isDictionaryMeaning) = await _doTranslate(
      text,
      _state.sourceLanguage,
      (textSoFar) {
        if (request != _translationRequest) return;

        _state = _state.copyWith(translatedText: textSoFar);

        notifyListeners();
      },
    );

    if (request != _translationRequest) return;

    _state = _state.copyWith(
      translatedText: result,
      isTranslating: false,
      isDictionaryMeaning: isDictionaryMeaning,
    );

    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // SWAP LANGUAGES
  // ─────────────────────────────────────────────
  void swapLanguages() {
    final newSource = _state.sourceLanguage == 'hiligaynon'
        ? 'tagalog'
        : 'hiligaynon';

    final newOriginal = _state.translatedText;

    _state = _state.copyWith(
      sourceLanguage: newSource,
      originalText: newOriginal,
      translatedText: '',
    );

    notifyListeners();

    if (newOriginal.isNotEmpty) {
      _performTranslation(newOriginal);
    }
  }

  // ─────────────────────────────────────────────
  // CLEAR TEXT
  // ─────────────────────────────────────────────
  void clearText() {
    _translationRequest++;

    _state = const TranslatorState();

    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // CLEAR ERROR
  // ─────────────────────────────────────────────
  void clearError() {
    _state = _state.copyWith(recognitionError: '');

    notifyListeners();
  }

  // ─────────────────────────────────────────────
  // MAP ERRORS
  // ─────────────────────────────────────────────
  String _mapError(String raw) {
    if (raw.contains('network')) {
      return 'Network error. Check connection.';
    }

    if (raw.contains('permission')) {
      return 'Microphone permission required.';
    }

    if (raw.contains('no match') || raw.contains('no speech')) {
      return 'No speech detected. Try again.';
    }

    if (raw.contains('busy')) {
      return 'Recognizer busy. Try again.';
    }

    return 'Speech error. Try again.';
  }

  @override
  void dispose() {
    _speech.stop();

    super.dispose();
  }
}
