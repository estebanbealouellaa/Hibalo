// Runs the real Hiligaynon voice (v4, hibalo_tts_v4r.onnx) end to end.
//   flutter test integration_test/hiligaynon_tts_test.dart -d <phone id>
// (also works with -d windows). Needs the 4 voice files in
// assets/tts/models. The WAVs are written to the app's temp folder; the path
// is printed. Compare them with C:\Hibalo-TTS-Mobile\generate_tts_v4.py.
//
// Every text is made twice: with the normal CPU provider and with XNNPACK
// (HiligaynonTtsEngine(useXnnpack: true)), and the times are printed side by
// side. Listen to <name>_cpu.wav and <name>_xnnpack.wav to check the audio.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_dsp.dart';
import 'package:hibalo_app/services/tts/hiligaynon_tts_engine.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

// ignore: avoid_print
void _log(String s) => print(s);

String _s(int ms) => (ms / 1000).toStringAsFixed(2);

const _samples = {
  'short': 'Salamat gid sa imo',
  'paragraph':
      'Sa Sabado, makadto kami sa tiyanggihan kaupod ang akon iloy. '
      'Mabakal kami sang isda, utan, kag prutas para sa amon panyaga. '
      'Pagkatapos sina, mapuli kami sa balay kag magaluto sang adobo. '
      'Malipayon gid ako kon kaupod ko ang akon pamilya.',
  'question': 'Kumusta ka?',
};

class _Run {
  _Run(this.firstMs, this.totalMs, this.audio);
  final int firstMs;
  final int totalMs;
  final Float32List audio;
  double get seconds => audio.length / kSampleRate;
}

class _Result {
  _Result(this.provider, this.loadMs, this.warmMs, this.runs);
  final String provider;
  final int loadMs;
  final int warmMs;
  final Map<String, _Run> runs;
}

/// Loads a fresh engine, makes every sample once and saves the WAVs.
Future<_Result> _measure(
  HiligaynonTtsEngine engine,
  String tag,
  Directory outDir,
) async {
  final load = Stopwatch()..start();
  await engine.load();
  final loadMs = load.elapsedMilliseconds;
  final warm = Stopwatch()..start();
  await engine.warmUp();
  final warmMs = warm.elapsedMilliseconds;
  _log(
    '[$tag] provider ${engine.provider}: load ${_s(loadMs)} s, '
    'warm-up run ${_s(warmMs)} s',
  );

  final runs = <String, _Run>{};
  for (final MapEntry(key: name, value: text) in _samples.entries) {
    final sw = Stopwatch()..start();
    int? firstMs;
    var chunks = 0;
    final audio = await engine.synthesize(
      text,
      onChunk: (_) {
        firstMs ??= sw.elapsedMilliseconds;
        chunks++;
      },
    );
    final run = _Run(firstMs!, sw.elapsedMilliseconds, audio);
    runs[name] = run;
    final file = File('${outDir.path}/${name}_$tag.wav')
      ..writeAsBytesSync(encodeWav(audio));
    _log(
      '[$tag] TTS $name: ${run.seconds.toStringAsFixed(2)} s audio, '
      'first sound ${_s(run.firstMs)} s, total ${_s(run.totalMs)} s, '
      '$chunks part(s) -> ${file.path}',
    );
    expect(run.seconds, greaterThan(0.2));
    expect(run.seconds, lessThan(text.length * 0.3));
  }
  return _Result(engine.provider, loadMs, warmMs, runs);
}

/// Largest sample difference, or null when the lengths differ.
double? _maxDiff(Float32List a, Float32List b) {
  if (a.length != b.length) return null;
  var m = 0.0;
  for (var i = 0; i < a.length; i++) {
    m = math.max(m, (a[i] - b[i]).abs());
  }
  return m;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('generates Hiligaynon speech (CPU vs XNNPACK)', (tester) async {
    await tester.runAsync(() async {
      expect(
        await HiligaynonTtsEngine.isBundled(),
        isTrue,
        reason: 'copy the 4 voice files into assets/tts/models',
      );
      _log(
        'ORT providers on this device: '
        '${(await OnnxRuntime().getAvailableProviders()).map((p) => p.name).join(', ')}',
      );

      final outDir = Directory(
        '${(await getTemporaryDirectory()).path}/hibalo_tts_check',
      )..createSync(recursive: true);

      // CPU first (the app's default). Its load time may include copying the
      // model out of the app the very first time after install.
      final cpuEngine = HiligaynonTtsEngine();
      final cpu = await _measure(cpuEngine, 'cpu', outDir);

      // Fixed seed: the same text gives exactly the same samples.
      for (final MapEntry(key: name, value: text) in _samples.entries) {
        final again = await cpuEngine.synthesize(text);
        expect(
          again,
          orderedEquals(cpu.runs[name]!.audio),
          reason: '$name: second run differs',
        );
      }
      _log('REPEAT: identical samples for all ${_samples.length} texts');

      // Cancelling stops a generation that is in progress (between parts).
      final pending = cpuEngine.synthesize(_samples['paragraph']!);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      cpuEngine.cancel();
      await expectLater(pending, throwsA(isA<TtsCancelled>()));
      await cpuEngine.close();

      final xnnEngine = HiligaynonTtsEngine(useXnnpack: true);
      final xnn = await _measure(xnnEngine, 'xnnpack', outDir);
      await xnnEngine.close();

      // Side-by-side table.
      String row(List<String> c) =>
          '${c[0].padRight(14)}${c[1].padLeft(12)}${c[2].padLeft(12)}'
          '${c[3].padLeft(14)}';
      _log('');
      _log('==== CPU vs ${xnn.provider} (seconds) ====');
      _log(row(['', 'CPU', xnn.provider, 'max diff']));
      _log(row(['load', _s(cpu.loadMs), _s(xnn.loadMs), '']));
      _log(row(['warm-up run', _s(cpu.warmMs), _s(xnn.warmMs), '']));
      for (final name in _samples.keys) {
        final a = cpu.runs[name]!;
        final b = xnn.runs[name]!;
        final diff = _maxDiff(a.audio, b.audio);
        final diffText = diff == null
            ? 'len ${a.audio.length}/${b.audio.length}'
            : diff.toStringAsExponential(1);
        _log(row(['$name first', _s(a.firstMs), _s(b.firstMs), diffText]));
        _log(row(['$name total', _s(a.totalMs), _s(b.totalMs), '']));
        _log(
          row([
            '$name audio',
            a.seconds.toStringAsFixed(2),
            b.seconds.toStringAsFixed(2),
            '',
          ]),
        );
      }
      _log('WAVs: ${outDir.path} (<name>_cpu.wav / <name>_xnnpack.wav)');
    });
  });
}
