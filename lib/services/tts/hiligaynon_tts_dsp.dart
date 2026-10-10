// Audio post-processing for the Hiligaynon voice (v4). Same math as
// trim_edges() and even_volume() in C:\Hibalo-TTS-Mobile\generate_tts_v4.py.
// Checked against numpy in test/tts/v4_reference.json.

import 'dart:math' as math;
import 'dart:typed_data';

const int kSampleRate = 16000;

/// 10 ms frames.
const int _frame = kSampleRate ~/ 100;

/// A frame louder than this (RMS) counts as speech.
const double _speechRms = 0.01;

/// RMS per 10 ms frame (the leftover samples at the end are ignored).
Float64List _energy(Float32List wav) {
  final n = wav.length ~/ _frame;
  final e = Float64List(n);
  for (var f = 0; f < n; f++) {
    var sum = 0.0;
    for (var i = f * _frame; i < (f + 1) * _frame; i++) {
      sum += wav[i] * wav[i];
    }
    e[f] = math.sqrt(sum / _frame);
  }
  return e;
}

/// Cuts only the long silence before the first word and after the last
/// word (keeping [margin] seconds). Pauses inside the sentence are left
/// exactly as the voice made them.
Float32List trimEdges(Float32List wav, {double margin = 0.05}) {
  final e = _energy(wav);
  var first = -1;
  var last = -1;
  for (var f = 0; f < e.length; f++) {
    if (e[f] > _speechRms) {
      if (first < 0) first = f;
      last = f;
    }
  }
  if (first < 0) return wav;
  final keep = (margin * kSampleRate).toInt();
  return Float32List.sublistView(
    wav,
    math.max(0, first * _frame - keep),
    math.min(wav.length, (last + 1) * _frame + keep),
  );
}

/// np.median: the middle value, or the mean of the two middle values.
double _median(List<double> xs) {
  final s = [...xs]..sort();
  final m = s.length ~/ 2;
  return s.length.isOdd ? s[m] : (s[m - 1] + s[m]) / 2;
}

/// Smooth volume boost: loud words are brought down toward the rest, then
/// everything is raised to a steady level (no single word shouts).
Float32List evenVolume(
  Float32List wav, {
  double target = 0.12,
  double ratio = 2.5,
  double peak = 0.95,
}) {
  final e = _energy(wav);
  final speech = [for (final x in e) if (x > _speechRms) x];
  if (speech.isEmpty) return wav;
  final level = _median(speech);

  // Per-frame gain: parts louder than the usual level are pulled down.
  final n = e.length;
  final gain = Float64List(n)..fillRange(0, n, 1.0);
  for (var f = 0; f < n; f++) {
    if (e[f] > level) {
      gain[f] = (level * math.pow(e[f] / level, 1 / ratio)) / e[f];
    }
  }
  // Smooth the gain over ~50 ms so it doesn't pump (5-tap mean, edges
  // padded with the end values: np.pad(mode="edge") + convolve "valid").
  final smooth = Float64List(n);
  for (var f = 0; f < n; f++) {
    var sum = 0.0;
    for (var k = f - 2; k <= f + 2; k++) {
      sum += gain[k.clamp(0, n - 1)];
    }
    smooth[f] = sum / 5;
  }

  final out = Float64List(wav.length);
  final tail = n > 0 ? smooth[n - 1] : 1.0;
  final scale = target / level;
  var top = 0.0;
  for (var i = 0; i < wav.length; i++) {
    final f = i ~/ _frame;
    final v = wav[i] * (f < n ? smooth[f] : tail) * scale;
    out[i] = v;
    if (v.abs() > top) top = v.abs();
  }
  final cap = top > peak ? peak / top : 1.0;
  final result = Float32List(wav.length);
  for (var i = 0; i < wav.length; i++) {
    result[i] = out[i] * cap;
  }
  return result;
}

/// Little-endian float16 values -> float32 (exact, like numpy's
/// np.fromfile(dtype=float16).astype(float32)).
Float32List decodeFloat16(ByteData bytes) {
  final n = bytes.lengthInBytes ~/ 2;
  final bits = Uint32List(n);
  for (var i = 0; i < n; i++) {
    final h = bytes.getUint16(i * 2, Endian.little);
    final sign = (h & 0x8000) << 16;
    final exp = (h >> 10) & 0x1f;
    var man = h & 0x3ff;
    if (exp == 0) {
      if (man == 0) {
        bits[i] = sign; // +-0
      } else {
        // Subnormal: shift until the leading 1 is in place.
        var shift = 0;
        while ((man & 0x400) == 0) {
          man <<= 1;
          shift++;
        }
        bits[i] = sign | ((113 - shift) << 23) | ((man & 0x3ff) << 13);
      }
    } else if (exp == 31) {
      bits[i] = sign | 0x7f800000 | (man << 13); // inf / nan
    } else {
      bits[i] = sign | ((exp + 112) << 23) | (man << 13);
    }
  }
  return bits.buffer.asFloat32List();
}

/// 16-bit mono PCM WAV bytes.
Uint8List encodeWav(Float32List audio, {int sampleRate = kSampleRate}) {
  final dataLen = audio.length * 2;
  final b = ByteData(44 + dataLen);
  void ascii(int off, String s) {
    for (var i = 0; i < s.length; i++) {
      b.setUint8(off + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  b.setUint32(4, 36 + dataLen, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  b.setUint32(16, 16, Endian.little);
  b.setUint16(20, 1, Endian.little); // PCM
  b.setUint16(22, 1, Endian.little); // mono
  b.setUint32(24, sampleRate, Endian.little);
  b.setUint32(28, sampleRate * 2, Endian.little);
  b.setUint16(32, 2, Endian.little);
  b.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  b.setUint32(40, dataLen, Endian.little);
  for (var i = 0; i < audio.length; i++) {
    b.setInt16(
      44 + i * 2,
      (audio[i].clamp(-1.0, 1.0) * 32767).round(),
      Endian.little,
    );
  }
  return b.buffer.asUint8List();
}
