import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  Future<void> startListening({
    required String localeId,
    required Function(String) onResult,
  }) async {
    bool available = await _speech.initialize();

    if (!available) return;

    await _speech.listen(
      localeId: localeId,
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }
}
