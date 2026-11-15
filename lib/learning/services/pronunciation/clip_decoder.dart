import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

/// Decoded audio as it comes from the decoder: interleaved 16-bit samples.
class RawPcm {
  const RawPcm({required this.samples, required this.sampleRate, required this.channels});

  final Int16List samples;
  final int sampleRate;
  final int channels;
}

/// Turns a bundled lesson clip ("assets/audio/…m4a") into PCM, on the phone, offline.
abstract class ClipDecoder {
  /// Throws [ClipDecodeException] when the clip can't be read or decoded.
  Future<RawPcm> decode(String assetPath);
}

class ClipDecodeException implements Exception {
  ClipDecodeException(this.message);

  final String message;

  @override
  String toString() => 'ClipDecodeException: $message';
}

/// Android's own MediaCodec (MainActivity.kt, channel "hibalo/clip_decoder"): no package.
/// The clip bytes are read from the app bundle here and decoded on a native background thread.
class AndroidClipDecoder implements ClipDecoder {
  const AndroidClipDecoder();

  static const MethodChannel _channel = MethodChannel('hibalo/clip_decoder');

  @override
  Future<RawPcm> decode(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      final result = await _channel.invokeMapMethod<String, dynamic>('decode', {
        'bytes': data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      });
      if (result == null) throw ClipDecodeException('no result for $assetPath');
      final pcm = result['pcm'] as Uint8List;
      return RawPcm(
        samples: int16FromBytes(pcm),
        sampleRate: result['sampleRate'] as int,
        channels: result['channels'] as int,
      );
    } on ClipDecodeException {
      rethrow;
    } catch (e) {
      throw ClipDecodeException('$assetPath: $e');
    }
  }
}

/// Little-endian 16-bit samples from bytes (copies when the start offset is odd).
Int16List int16FromBytes(Uint8List bytes) {
  var b = bytes;
  if (b.offsetInBytes.isOdd) b = Uint8List.fromList(b);
  return b.buffer.asInt16List(b.offsetInBytes, b.lengthInBytes ~/ 2);
}

/// Mono, 16 kHz, -1…1: averages the channels, then resamples with a windowed-sinc
/// low-pass (so 48 kHz clips don't fold high sounds into the speech band).
Float64List toMono16k(RawPcm pcm) {
  final channels = math.max(1, pcm.channels);
  final frames = pcm.samples.length ~/ channels;
  final mono = Float64List(frames);
  for (var i = 0; i < frames; i++) {
    var sum = 0;
    for (var c = 0; c < channels; c++) {
      sum += pcm.samples[i * channels + c];
    }
    mono[i] = sum / (channels * 32768);
  }
  return resample(mono, pcm.sampleRate, 16000);
}

/// Band-limited resampling (Blackman-windowed sinc, 8 zero crossings each side:
/// plenty for speech features, and quick on a slow phone).
Float64List resample(Float64List input, int fromRate, int toRate) {
  if (fromRate == toRate || input.isEmpty) return Float64List.fromList(input);
  final ratio = fromRate / toRate;
  // Cut-off as a share of the input's Nyquist: a bit under the lower of the two rates.
  final cutoff = 0.95 * math.min(1.0, toRate / fromRate);
  const zeroCrossings = 8;
  final halfWidth = zeroCrossings / cutoff;
  final outLength = (input.length / ratio).floor();
  final out = Float64List(outLength);
  for (var i = 0; i < outLength; i++) {
    final centre = i * ratio;
    final first = math.max(0, (centre - halfWidth).ceil());
    final last = math.min(input.length - 1, (centre + halfWidth).floor());
    var sum = 0.0;
    for (var k = first; k <= last; k++) {
      final t = k - centre;
      final x = t * cutoff;
      final sinc = x == 0 ? 1.0 : math.sin(math.pi * x) / (math.pi * x);
      final w = 0.42 + 0.5 * math.cos(math.pi * t / halfWidth) + 0.08 * math.cos(2 * math.pi * t / halfWidth);
      sum += input[k] * sinc * w;
    }
    out[i] = sum * cutoff;
  }
  return out;
}
