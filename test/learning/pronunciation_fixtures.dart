// Made-up sounds and a fake clip decoder for the Q09 pronunciation tests.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:hibalo_app/learning/services/pronunciation/clip_decoder.dart';

/// Stands in for MediaCodec: returns made-up PCM per clip path.
class FakeClipDecoder implements ClipDecoder {
  FakeClipDecoder(this.clips, {this.sampleRate = 16000});

  final Map<String, Float64List> clips;
  final int sampleRate;
  final List<String> calls = [];

  @override
  Future<RawPcm> decode(String assetPath) async {
    calls.add(assetPath);
    final x = clips[assetPath];
    if (x == null) throw ClipDecodeException('missing $assetPath');
    return RawPcm(
      samples: Int16List.fromList([for (final v in x) (v * 32767).round().clamp(-32768, 32767)]),
      sampleRate: sampleRate,
      channels: 1,
    );
  }
}

const int rate = 16000;

Float64List tone(double hz, double seconds, {double amp = 0.3, int sampleRate = rate}) => Float64List.fromList([
      for (var i = 0; i < (seconds * sampleRate).round(); i++) amp * math.sin(2 * math.pi * hz * i / sampleRate),
    ]);

Float64List silence(double seconds) => Float64List((seconds * rate).round());

/// A vowel-like sound: harmonics of [f0] shaped by [formants].
Float64List vowel(double f0, List<double> formants, double seconds, {double amp = 0.3}) {
  final n = (seconds * rate).round();
  final out = Float64List(n);
  for (var h = 1; h * f0 < 7000; h++) {
    final f = h * f0;
    var w = 0.0;
    for (final formant in formants) {
      w += math.exp(-math.pow((f - formant) / 120, 2));
    }
    if (w < 1e-3) continue;
    for (var i = 0; i < n; i++) {
      out[i] += w * math.sin(2 * math.pi * f * i / rate);
    }
  }
  final peak = out.fold<double>(0, (m, v) => math.max(m, v.abs()));
  for (var i = 0; i < n; i++) {
    out[i] *= amp / peak;
  }
  return out;
}

Float64List noise(double seconds, {double amp = 0.1, int seed = 1}) {
  final r = math.Random(seed);
  return Float64List.fromList([for (var i = 0; i < (seconds * rate).round(); i++) amp * (r.nextDouble() * 2 - 1)]);
}

Float64List join(List<Float64List> parts) => Float64List.fromList([for (final p in parts) ...p]);

/// Made-up "words" with different vowel/consonant patterns.
Float64List wordA({double f0 = 120, double speed = 1}) => join([
      vowel(f0, [700, 1200], 0.25 / speed),
      noise(0.08 / speed, seed: 2),
      vowel(f0, [300, 2300], 0.25 / speed),
    ]);

Float64List wordB({double f0 = 120}) => join([
      vowel(f0, [300, 800], 0.3),
      vowel(f0, [500, 1800], 0.25),
    ]);

Float64List wordC({double f0 = 120}) => join([
      noise(0.1, seed: 3),
      vowel(f0, [400, 2000], 0.2),
      vowel(f0, [750, 1100], 0.25),
    ]);

/// 16-bit little-endian PCM bytes, as the recorder keeps them.
Uint8List pcmBytes(Float64List x) {
  final out = Int16List(x.length);
  for (var i = 0; i < x.length; i++) {
    out[i] = (x[i] * 32767).round().clamp(-32768, 32767);
  }
  return out.buffer.asUint8List();
}
