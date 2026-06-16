class Languages {
  static const String hiligaynon = 'hiligaynon';
  static const String tagalog = 'tagalog';
}

class TranslatorState {
  final String originalText;
  final String translatedText;
  final bool isListening;
  final String sourceLanguage;
  final bool isTranslating;
  final String recognitionError;
  final String partialSpeechText;

  const TranslatorState({
    this.originalText = '',
    this.translatedText = '',
    this.isListening = false,
    this.sourceLanguage = Languages.tagalog, // FIX: Filipino ang default
    this.isTranslating = false,
    this.recognitionError = '',
    this.partialSpeechText = '',
  });

  TranslatorState copyWith({
    String? originalText,
    String? translatedText,
    bool? isListening,
    String? sourceLanguage,
    bool? isTranslating,
    String? recognitionError,
    String? partialSpeechText,
  }) {
    return TranslatorState(
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      isListening: isListening ?? this.isListening,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      isTranslating: isTranslating ?? this.isTranslating,
      recognitionError: recognitionError ?? this.recognitionError,
      partialSpeechText: partialSpeechText ?? this.partialSpeechText,
    );
  }
}
