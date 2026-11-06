// Offline Hiligaynon voice v4 (MMS-TTS / VITS, HIL_0619, hibalo_tts_v4r.onnx): Dart port of generate_tts_v4.py.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import 'hiligaynon_tts_dsp.dart';
import 'hiligaynon_tts_text.dart';

/// Thrown when [HiligaynonTtsEngine.cancel] stops a generation.
class TtsCancelled implements Exception {}

class HiligaynonTtsEngine {
  /// [useXnnpack]: off by default until it is shown to be faster on a phone (falls back to CPU).
  HiligaynonTtsEngine({this.useXnnpack = false, this.threads = kTtsThreads});

  /// CPU threads for one model call. On a Galaxy A03 (8 cores) the 16 s
  /// paragraph took 34 s with 4 threads, 26 s with 6, and 28-30 s with 8.
  static const int kTtsThreads = 6;

  static const String modelDir = 'assets/tts/models';
  static const String modelFile = 'hibalo_tts_v4r.onnx';

  final int threads;

  /// Speaking speed fed to the model (DEFAULT_SPEED: 15% slower than the
  /// voice's natural speed).
  static const double speed = 0.85;

  final bool useXnnpack;

  /// The provider the session ended up with: 'XNNPACK+CPU' or 'CPU'.
  String provider = '';

  /// One tiny run when the voice is loaded, so the first real tap isn't slow.
  static const String _warmUpText = '— aga —';

  final OnnxRuntime _ort = OnnxRuntime();

  late Map<String, int> _vocab;
  late OrtSession _session;

  /// noise_dur, noise_prior, noise_scale, noise_scale_duration, speed:
  /// created once, passed to every run.
  late Map<String, OrtValue> _fixed;

  Future<void>? _loading;
  Future<void>? _warming;

  /// Runs one model job at a time; [cancel] bumps [_epoch] so only the runs
  /// started before it stop.
  Future<void> _busy = Future.value();
  int _epoch = 0;
  int _runEpoch = 0;

  /// True when the voice files were bundled into this build.
  static Future<bool> isBundled() async {
    try {
      final assets = (await AssetManifest.loadFromAssetBundle(
        rootBundle,
      )).listAssets();
      return [
        modelFile,
        'voice_seed7.bin',
        'voice_settings.json',
        'vocab.json',
      ].every((f) => assets.contains('$modelDir/$f'));
    } catch (_) {
      return false;
    }
  }

  Future<void> load() => _loading ??= _load().catchError((Object e) {
    _loading = null; // allow a retry
    throw e;
  });

  Future<void> _load() async {
    final sw = Stopwatch()..start();
    _vocab =
        (jsonDecode(await rootBundle.loadString('$modelDir/vocab.json'))
                as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toInt()));
    final cfg =
        jsonDecode(await rootBundle.loadString('$modelDir/voice_settings.json'))
            as Map<String, dynamic>;

    List<int> shape(String key) =>
        (cfg[key] as List).map((e) => (e as num).toInt()).toList();
    final ndShape = shape('noise_dur_shape');
    final npShape = shape('noise_prior_shape');
    final ndSize = ndShape.fold(1, (a, b) => a * b);
    final npSize = npShape.fold(1, (a, b) => a * b);

    final packed = decodeFloat16(
      await rootBundle.load('$modelDir/${cfg['noise_file']}'),
    );
    if (packed.length != ndSize + npSize) {
      throw StateError(
        '${cfg['noise_file']} has ${packed.length} values, '
        'expected ${ndSize + npSize}',
      );
    }
    Future<OrtValue> scalar(num v) =>
        OrtValue.fromList(Float32List.fromList([v.toDouble()]), [1]);
    final values = await Future.wait([
      OrtValue.fromList(packed.sublist(0, ndSize), ndShape),
      OrtValue.fromList(packed.sublist(ndSize), npShape),
      scalar(cfg['noise_scale'] as num),
      scalar(cfg['noise_scale_duration'] as num),
      scalar(speed),
    ]);
    _fixed = {
      'noise_dur': values[0],
      'noise_prior': values[1],
      'noise_scale': values[2],
      'noise_scale_duration': values[3],
      'speed': values[4],
    };

    _session = await _createSession();
    debugPrint(
      '[HiligaynonTTS] voice loaded in ${sw.elapsedMilliseconds} ms '
      '(seed ${cfg['seed']}, noise_scale ${cfg['noise_scale']}, '
      'speed $speed, $threads threads, $provider)',
    );
  }

  Future<OrtSession> _createSession() async {
    Future<OrtSession> create(
      List<OrtProvider> providers, [
      Map<String, String>? configs,
    ]) => _ort.createSessionFromAsset(
      '$modelDir/$modelFile',
      options: OrtSessionOptions(
        intraOpNumThreads: threads,
        interOpNumThreads: 1,
        providers: providers,
        sessionConfigs: configs,
      ),
    );
    if (useXnnpack) {
      try {
        // ONNX Runtime's advice with XNNPACK: don't let ORT's own threads
        // spin, so they don't fight XNNPACK's threads for the cores.
        final session = await create(
          [OrtProvider.XNNPACK, OrtProvider.CPU],
          {'session.intra_op.allow_spinning': '0'},
        );
        provider = 'XNNPACK+CPU';
        return session;
      } catch (e) {
        debugPrint('[HiligaynonTTS] XNNPACK not available, using CPU: $e');
      }
    }
    final session = await create([OrtProvider.CPU]);
    provider = 'CPU';
    return session;
  }

  /// Loads the voice and does one tiny run, like the PC script on start.
  Future<void> warmUp() => _warming ??=
      _queue(() async {
        await load();
        final sw = Stopwatch()..start();
        await _infer(toIds(_warmUpText, _vocab));
        debugPrint('[HiligaynonTTS] warm-up run ${sw.elapsedMilliseconds} ms');
      }).catchError((Object e) {
        _warming = null;
        throw e;
      });

  /// Frees the model session and the noise tensors (after the queued work).
  /// A later [load] loads the voice again.
  Future<void> close() => _queue(() async {
    final loading = _loading;
    if (loading == null) return;
    _loading = null;
    _warming = null;
    try {
      await loading;
    } catch (_) {
      return; // never loaded: nothing to free
    }
    await _session.close();
    await Future.wait(_fixed.values.map((v) => v.dispose()));
  });

  /// Stops the generations in progress or queued (they throw
  /// [TtsCancelled]). A model call that already started still finishes.
  void cancel() => _epoch++;

  /// Text -> 16 kHz mono audio, the same samples as generate_tts_v4.py; [onChunk] gets each part (with its pause) as soon as it is ready.
  Future<Float32List> synthesize(
    String text, {
    void Function(Float32List piece)? onChunk,
  }) {
    final epoch = _epoch;
    return _queue(() => _synthesize(text, epoch, onChunk));
  }

  Future<T> _queue<T>(Future<T> Function() job) {
    final run = _busy.then((_) => job());
    _busy = run.then((_) {}, onError: (_) {});
    return run;
  }

  Future<Float32List> _synthesize(
    String text,
    int epoch,
    void Function(Float32List piece)? onChunk,
  ) async {
    _runEpoch = epoch;
    _checkCancelled();
    await load();
    final sw = Stopwatch()..start();

    final pieces = <Float32List>[];
    final said = <String>[];
    int? firstMs;
    var gapBefore = 0.0;
    final parts = splitSentences(text);
    for (var i = 0; i < parts.length; i++) {
      final (part, gapAfter) = parts[i];
      // "Last" counts every part, also ones that turn out empty (as the PC).
      final vt = voiceText(
        part,
        stretchEnd: endsStatement(part, i == parts.length - 1),
      );
      if (vt.isEmpty) continue;
      _checkCancelled();
      final wav = evenVolume(trimEdges(await _infer(toIds(vt, _vocab))));
      _checkCancelled();
      final pause = pieces.isEmpty ? 0 : (gapBefore * kSampleRate).toInt();
      gapBefore = gapAfter;
      final piece = Float32List(pause + wav.length)..setAll(pause, wav);
      firstMs ??= sw.elapsedMilliseconds;
      pieces.add(piece);
      said.add(vt);
      onChunk?.call(piece);
    }

    final total = pieces.fold<int>(0, (n, p) => n + p.length);
    final out = Float32List(total);
    var off = 0;
    for (final p in pieces) {
      out.setAll(off, p);
      off += p.length;
    }
    debugPrint(
      '[HiligaynonTTS] ${(total / kSampleRate).toStringAsFixed(2)} s audio '
      'in ${(sw.elapsedMilliseconds / 1000).toStringAsFixed(2)} s, '
      'first sound after ${((firstMs ?? 0) / 1000).toStringAsFixed(2)} s '
      '(${said.length} part(s): ${said.join(' | ')})',
    );
    return out;
  }

  void _checkCancelled() {
    if (_runEpoch != _epoch) throw TtsCancelled();
  }

  Future<Float32List> _infer(List<int> ids) async {
    final idsValue = await OrtValue.fromList(Int64List.fromList(ids), [
      1,
      ids.length,
    ]);
    Map<String, OrtValue> out = const {};
    try {
      out = await _session.run({'input_ids': idsValue, ..._fixed});
      final data = await out['waveform']!.asFlattenedList();
      return data is Float32List
          ? Float32List.fromList(data)
          : Float32List.fromList(
              data.map((e) => (e as num).toDouble()).toList(),
            );
    } finally {
      // Only this call's tensors; the fixed noise tensors are kept.
      await Future.wait([idsValue, ...out.values].map((v) => v.dispose()));
    }
  }
}
