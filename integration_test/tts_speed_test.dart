// How fast the voice generates the 16 s paragraph with each thread count.
//   flutter test integration_test/tts_speed_test.dart -d <phone id>

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_dsp.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_engine.dart';
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

  testWidgets('voice speed by thread count', (tester) async {
    await tester.runAsync(() async {
      for (final threads in const [6, 8, 6, 8]) {
        final engine = HiligaynonTtsEngine(threads: threads);
        await engine.warmUp();
        final sw = Stopwatch()..start();
        int? first;
        final audio = await engine.synthesize(
          _paragraph,
          onChunk: (piece) {
            first ??= sw.elapsedMilliseconds;
            _log(
              'PIECE $threads threads: ready ${sw.elapsedMilliseconds} ms, '
              '${piece.length * 1000 ~/ kSampleRate} ms of audio',
            );
          },
        );
        final seconds = audio.length / kSampleRate;
        final total = sw.elapsedMilliseconds / 1000;
        _log(
          'SPEED $threads threads: first piece $first ms, '
          'total ${total.toStringAsFixed(1)} s for '
          '${seconds.toStringAsFixed(1)} s audio, '
          '${(total / seconds).toStringAsFixed(2)} s work per s speech',
        );
        await engine.close();
      }
    });
  });
}
