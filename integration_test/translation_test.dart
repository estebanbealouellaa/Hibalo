// Runs the real model on a device (ONNX doesn't work in plain flutter test); greedy must match the reference exactly (summary.md section 11).

import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/translation/offline_translator.dart';
import 'package:hibalo_app/services/translation/text_rules.dart';
import 'package:integration_test/integration_test.dart';

import 'translation_reference_rows.dart';

// ignore: avoid_print
void _log(String s) => print(s);

/// (direction is Hil->Fil, input, expected greedy output)
const _section11 = <(bool, String, String)>[
  (true, 'Patya ang suga.', 'Patayin mo ang ilaw.'),
  (true, 'Kuhaa ang libro.', 'Kunin mo ang libro.'),
  (true, 'Diin ang banyo?', 'Nasaan ang banyo?'),
  (true, 'Masakit ang akon ulo.', 'Masakit ang ulo ko.'),
  (true, 'Pila ini?', 'Magkano ito?'),
  (false, 'Patayin mo ang ilaw.', 'Palonga ang suga.'),
  (false, 'Saan ka pupunta?', 'Diin ka makadto?'),
  (false, 'May 3 na bata sa bahay.', 'May 3 ka kabataan sa balay.'),
  (false, 'Masakit ang tainga ko.', 'Masakit ang akon dalunggan.'),
];

/// 5 short paragraphs of 3 sentences each: (text, from Hiligaynon).
const _paragraphs = <(String, bool)>[
  ('Patya ang suga. Kuhaa ang libro. Diin ang banyo?', true),
  ('Masakit ang akon ulo. Pila ini? Salamat gid sa imo.', true),
  (
    'Sa Sabado, makadto kami sa tiyanggihan kaupod ang akon iloy. '
        'Mabakal kami sang isda, utan, kag prutas para sa amon panyaga. '
        'Malipayon gid ako kon kaupod ko ang akon pamilya.',
    true,
  ),
  ('Patayin mo ang ilaw. Saan ka pupunta? Masakit ang tainga ko.', false),
  ('May 3 na bata sa bahay. Kumain na ako. Hindi ko nakita.', false),
];

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final translator = OfflineTranslator(useEvalRows: false);

  testWidgets('section 11 and the reference outputs', (tester) async {
    await tester.runAsync(() async {
      final load = Stopwatch()..start();
      await translator.load();
      _log('LOAD ${load.elapsedMilliseconds} ms');

      var bad = 0;
      void check(String what, String got, String want) {
        if (got == want) return;
        bad++;
        if (bad <= 60) _log('MISMATCH $what\n  got  $got\n  want $want');
      }

      for (final (fromHil, input, want) in _section11) {
        final got = await translator.translateModelOnly(
          input,
          fromHiligaynon: fromHil,
          greedy: true,
        );
        check('section 11: $input', got, want);
      }
      _log('SECTION 11: ${_section11.length} cases, $bad wrong');
      expect(bad, 0);

      final greedySw = Stopwatch()..start();
      var rowsDone = 0;
      // --dart-define=QUICK_ROWS=150 runs only the first rows, greedy only.
      const quickRows = int.fromEnvironment('QUICK_ROWS');
      final greedyRows = quickRows > 0
          ? kReferenceRows.take(quickRows)
          : kReferenceRows;
      for (final (hil, fil, hilToFil, filToHil, _, _) in greedyRows) {
        check(
          'greedy hil: $hil',
          await translator.translateModelOnly(
            hil,
            fromHiligaynon: true,
            greedy: true,
          ),
          hilToFil,
        );
        check(
          'greedy fil: $fil',
          await translator.translateModelOnly(
            fil,
            fromHiligaynon: false,
            greedy: true,
          ),
          filToHil,
        );
        rowsDone += 2;
        if (rowsDone % 50 == 0) _log('PROGRESS greedy $rowsDone/600, $bad wrong');
      }
      if (quickRows > 0) {
        // Runs the app's own path with no phrase list and prints the outputs,
        // so they can be scored on the PC. Then times the longest inputs.
        final modelOnly = OfflineTranslator(
          useEvalRows: false,
          usePhraseList: false,
        );
        final shortMs = <int>[];
        var i = 0;
        for (final (hil, fil, _, _, _, _) in greedyRows) {
          for (final fromHil in const [true, false]) {
            final result = await modelOnly.translate(
              fromHil ? hil : fil,
              fromHiligaynon: fromHil,
            );
            shortMs.add(result.milliseconds);
            _log('OUT\t$i\t${fromHil ? 'hf' : 'fh'}\t${result.text}');
          }
          i++;
        }
        final longest = [...kReferenceRows.skip(150)]
          ..sort((a, b) => b.$1.length.compareTo(a.$1.length));
        final firstMs = <int>[];
        final totalMs = <int>[];
        for (final (hil, fil, _, _, _, _) in longest.take(10)) {
          for (final (text, fromHil) in [(hil, true), (fil, false)]) {
            final sw = Stopwatch()..start();
            int? first;
            final result = await modelOnly.translate(
              text,
              fromHiligaynon: fromHil,
              onPartial: (_) => first ??= sw.elapsedMilliseconds,
            );
            firstMs.add(first ?? result.milliseconds);
            totalMs.add(result.milliseconds);
          }
        }
        String stats(String name, List<int> ms) {
          final sorted = [...ms]..sort();
          final average = ms.reduce((a, b) => a + b) ~/ ms.length;
          return '$name: ${ms.length} inputs, average $average ms, '
              'median ${sorted[sorted.length ~/ 2]} ms, '
              'slowest ${sorted.last} ms';
        }

        _log('FINAL ${stats('everyday', shortMs)}');
        _log('FINAL ${stats('long, first sentence shown', firstMs)}');
        _log('FINAL ${stats('long, finished', totalMs)}');

        // Short paragraphs: the same 5 inputs with each paragraph beam size.
        final multiSentence = <int>[
          for (final (hil, fil, _, _, _, _) in greedyRows) ...[
            splitSentences(hil).length,
            splitSentences(fil).length,
          ],
        ].where((n) => n >= 2).length;
        _log('PARAGRAPH everyday inputs with 2+ sentences: $multiSentence');
        for (final size in const [4, 2]) {
          final paragraphs = OfflineTranslator(
            usePhraseList: false,
            paragraphBeamSize: size,
          );
          await paragraphs.load();
          final firstParts = <int>[];
          final totals = <int>[];
          // The first model call after loading is slower, so warm up first.
          await paragraphs.translate('Salamat.', fromHiligaynon: true);
          for (final (text, fromHil) in _paragraphs) {
            final sw = Stopwatch()..start();
            int? first;
            final result = await paragraphs.translate(
              text,
              fromHiligaynon: fromHil,
              onPartial: (_) => first ??= sw.elapsedMilliseconds,
            );
            firstParts.add(first ?? result.milliseconds);
            totals.add(result.milliseconds);
            _log(
              'PARAGRAPH beam $size ${result.milliseconds} ms | $text '
              '=> ${result.text}',
            );
          }
          _log('PARAGRAPH ${stats('beam $size, first sentence', firstParts)}');
          _log('PARAGRAPH ${stats('beam $size, finished', totals)}');
        }
        _log('FINISHED: quick run, $bad wrong of $rowsDone');
        return;
      }
      final count = kReferenceRows.length * 2;
      final greedyBad = bad;
      _log(
        'GREEDY: ${count - greedyBad}/$count exact, '
        '${greedySw.elapsedMilliseconds ~/ count} ms each',
      );

      // Beam against the Python reference, timing each sentence. Short means
      // 15 words or fewer. Bad results don't stop the run, so the timing and
      // the samples always get printed.
      final shortMs = <int>[];
      final longMs = <int>[];
      final samples = <String>[];
      Future<void> beamOne(
        String input,
        String want,
        String greedyOutput, {
        required bool fromHil,
      }) async {
        final sw = Stopwatch()..start();
        final got = await translator.translateModelOnly(
          input,
          fromHiligaynon: fromHil,
          greedy: false,
        );
        final words = input.trim().split(RegExp(r'\s+')).length;
        (words <= 15 ? shortMs : longMs).add(sw.elapsedMilliseconds);
        check('beam: $input', got, want);
        if (got != greedyOutput && words <= 25) {
          samples.add(
            'SAMPLE ${fromHil ? 'Hil->Fil' : 'Fil->Hil'} | $input'
            ' | greedy: $greedyOutput | beam: $got',
          );
        }
      }

      var beamDone = 0;
      for (final (hil, fil, hilToFil, filToHil, hilBeam, filBeam)
          in kReferenceRows) {
        if (hilBeam == null || filBeam == null) continue;
        await beamOne(hil, hilBeam, hilToFil, fromHil: true);
        await beamOne(fil, filBeam, filToHil, fromHil: false);
        beamDone += 2;
        if (beamDone % 40 == 0) _log('PROGRESS beam $beamDone/320, $bad wrong');
      }
      final beamBad = bad - greedyBad;

      String stats(String name, List<int> ms) {
        if (ms.isEmpty) return '$name: none';
        final sorted = [...ms]..sort();
        final average = ms.reduce((a, b) => a + b) ~/ ms.length;
        final median = sorted[sorted.length ~/ 2];
        return '$name: ${ms.length} sentences, average $average ms, '
            'median $median ms, slowest ${sorted.last} ms';
      }

      _log('BEAM: ${beamDone - beamBad}/$beamDone exact');
      _log('TIMING ${stats('short', shortMs)}');
      _log('TIMING ${stats('long', longMs)}');

      // Ten samples spread over the rows where beam and greedy differ.
      final step = samples.length <= 10 ? 1 : samples.length ~/ 10;
      for (var i = 0, shown = 0; i < samples.length && shown < 10; i += step) {
        _log(samples[i]);
        shown++;
      }

      // The full app pipeline: list hit, style copied, timing filled in.
      final app = OfflineTranslator();
      final hit = await app.translate(
        'Patayin ang ilaw.',
        fromHiligaynon: false,
      );
      expect(hit.text, 'Patya ang suga.');
      expect(hit.method, TranslationMethod.phraseList);

      final model = await app.translate(
        'Masakit ang akon ulo at may 3 ka bata',
        fromHiligaynon: true,
      );
      expect(model.method, TranslationMethod.beam);
      expect(model.wordCount, 9);
      expect(model.text, contains('3'));
      _log('APP: "${model.text}" in ${model.milliseconds} ms');

      final longest = kReferenceRows
          .map((r) => r.$1)
          .reduce((a, b) => a.length >= b.length ? a : b);
      final slow = await app.translate(longest, fromHiligaynon: true);
      _log('LONGEST: ${slow.wordCount} words, ${slow.milliseconds} ms');

      _log('FINISHED: $bad wrong in total');
      expect(bad, 0);
    });
  });
}
