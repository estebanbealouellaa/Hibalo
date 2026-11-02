// Times real playback of the 16 s paragraph through the Listen button's code:
// time to first sound, and time until the speech ends. It plays out loud.
//   flutter test integration_test/tts_playback_test.dart -d <phone id>

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/tts/translation_speaker.dart';
import 'package:integration_test/integration_test.dart';

// ignore: avoid_print
void _log(String s) => print(s);

const _paragraph =
    'Sa Sabado, makadto kami sa tiyanggihan kaupod ang akon iloy. '
    'Mabakal kami sang isda, utan, kag prutas para sa amon panyaga. '
    'Pagkatapos sina, mapuli kami sa balay kag magaluto sang adobo. '
    'Malipayon gid ako kon kaupod ko ang akon pamilya.';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('first sound and total for the paragraph', (tester) async {
    await tester.runAsync(() async {
      TranslationSpeaker.warmUp();
      await Future<void>.delayed(const Duration(seconds: 20));

      final speaker = TranslationSpeaker();
      final speaking = Completer<int>();
      final finished = Completer<int>();
      final sw = Stopwatch()..start();
      speaker.status.addListener(() {
        final status = speaker.status.value;
        if (status == SpeakStatus.speaking && !speaking.isCompleted) {
          speaking.complete(sw.elapsedMilliseconds);
        }
        if (status == SpeakStatus.idle &&
            speaking.isCompleted &&
            !finished.isCompleted) {
          finished.complete(sw.elapsedMilliseconds);
        }
      });

      await speaker.toggle(_paragraph, hiligaynon: true);
      final first = await speaking.future;
      final total = await finished.future;
      _log('PLAYBACK first sound $first ms, speech ended $total ms');
      expect(first, lessThan(total));
    });
  });

  testWidgets('the Filipino voice works on both screens', (tester) async {
    await tester.runAsync(() async {
      Future<void> listen(TranslationSpeaker speaker, String label) async {
        var notReady = false;
        speaker.onFilipinoVoiceNotReady = () => notReady = true;
        speaker.onFilipinoVoiceMissing = () => fail('$label: no voice');
        final finished = Completer<void>();
        void onStatus() {
          if (speaker.status.value == SpeakStatus.idle &&
              !finished.isCompleted) {
            finished.complete();
          }
        }

        final sw = Stopwatch()..start();
        speaker.status.addListener(onStatus);
        await speaker.toggle('Kumusta ka? Salamat sa iyo.', hiligaynon: false);
        await finished.future;
        speaker.status.removeListener(onStatus);
        _log('FILIPINO $label: finished ${sw.elapsedMilliseconds} ms');
        expect(notReady, isFalse, reason: label);
      }

      // Like opening the Translator, then Voice on top of it, then going back.
      final translator = TranslationSpeaker();
      await listen(translator, 'first screen');
      final voice = TranslationSpeaker();
      await listen(voice, 'second screen');
      voice.dispose();
      await listen(translator, 'first screen again');
      translator.dispose();
    });
  });
}
