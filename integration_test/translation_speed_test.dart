// Translation speed on a phone; build with --profile -t integration_test/translation_speed_test.dart, read with adb logcat -s flutter:I

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/translation/offline_translator.dart';
import 'package:hibalo_app/services/translation/text_rules.dart';
import 'package:integration_test/integration_test.dart';

import 'translation_reference_rows.dart';

// ignore: avoid_print
void _log(String s) => print(s);

int _words(String text) => text.trim().split(RegExp(r'\s+')).length;

String _stats(String name, List<int> ms) {
  if (ms.isEmpty) return '$name: none';
  final sorted = [...ms]..sort();
  final average = ms.reduce((a, b) => a + b) ~/ ms.length;
  return '$name: ${ms.length} items, average $average ms, '
      'median ${sorted[sorted.length ~/ 2]} ms, slowest ${sorted.last} ms';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('translation speed', (tester) async {
    await tester.runAsync(() async {
      final short = [
        for (var i = 0; i < 150; i += 6) kReferenceRows[i].$1,
      ];
      final bible = [...kReferenceRows.skip(150)]
        ..sort((a, b) => b.$1.length.compareTo(a.$1.length));
      final longRows = bible.take(10).toList();
      final longSample = longRows.take(6).map((r) => r.$1).toList();

      // 1. Thread counts, with the same sentences each time.
      var bestThreads = 2;
      var bestTotal = 1 << 62;
      for (final threads in const [1, 2, 4]) {
        final translator = OfflineTranslator(threads: threads);
        await translator.load();
        Future<List<int>> run(List<String> texts) async {
          final ms = <int>[];
          for (final text in texts) {
            final sw = Stopwatch()..start();
            await translator.translateModelOnly(
              text,
              fromHiligaynon: true,
              greedy: false,
            );
            ms.add(sw.elapsedMilliseconds);
          }
          return ms;
        }

        final shortMs = await run(short);
        final longMs = await run(longSample);
        final total = [...shortMs, ...longMs].reduce((a, b) => a + b);
        _log('THREADS $threads ${_stats('short', shortMs)}');
        _log('THREADS $threads ${_stats('long whole', longMs)}');
        if (total < bestTotal) {
          bestTotal = total;
          bestThreads = threads;
        }
      }
      _log('BEST THREADS $bestThreads');

      // 2. Long inputs split into sentences, with the best thread count.
      final translator = OfflineTranslator(threads: bestThreads);
      await translator.load();
      final beamShort = <int>[];
      final beamLong = <int>[];
      final greedyLong = <int>[];
      final firstResult = <int>[];
      final allResults = <int>[];
      for (final (hil, fil, _, _, _, _) in longRows) {
        for (final (text, fromHil) in [(hil, true), (fil, false)]) {
          var total = 0;
          var first = -1;
          for (final sentence in splitSentences(text)) {
            final sw = Stopwatch()..start();
            await translator.translateModelOnly(
              sentence,
              fromHiligaynon: fromHil,
              greedy: false,
            );
            final ms = sw.elapsedMilliseconds;
            total += ms;
            if (first < 0) first = ms;
            final isLong = _words(sentence) > 15;
            (isLong ? beamLong : beamShort).add(ms);
            if (isLong) {
              final greedySw = Stopwatch()..start();
              await translator.translateModelOnly(
                sentence,
                fromHiligaynon: fromHil,
                greedy: true,
              );
              greedyLong.add(greedySw.elapsedMilliseconds);
            }
          }
          firstResult.add(first);
          allResults.add(total);
        }
        _log('PROGRESS row done');
      }
      _log('SPLIT ${_stats('sentence up to 15 words, beam', beamShort)}');
      _log('SPLIT ${_stats('sentence over 15 words, beam', beamLong)}');
      _log('SPLIT ${_stats('sentence over 15 words, greedy', greedyLong)}');
      _log('SPLIT ${_stats('first sentence shown', firstResult)}');
      _log('SPLIT ${_stats('whole input, all beam', allResults)}');
      _log('FINISHED: speed test');
    });
  });
}
