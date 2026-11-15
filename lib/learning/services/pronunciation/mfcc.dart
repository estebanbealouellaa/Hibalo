import 'dart:math' as math;
import 'dart:typed_data';

/// MFCC sound features for the Q09 similarity check (pure Dart, 16 kHz mono input).
///
/// 25 ms Hamming frames every 10 ms, 512-point FFT, 26 mel bands (80–7600 Hz),
/// log energies, DCT; coefficients 1–12 are kept (0 = loudness is dropped) and
/// each coefficient's average over the clip is subtracted, so the microphone
/// and the voice colour matter less.
class Mfcc {
  Mfcc._();

  static const int sampleRate = 16000;
  static const int frameLength = 400; // 25 ms
  static const int hop = 160; // 10 ms
  static const int fftSize = 512;
  static const int melBands = 26;
  static const int coefficients = 12;
  static const double lowHz = 80;
  static const double highHz = 7600;

  static final Float64List _window = Float64List.fromList([
    for (var i = 0; i < frameLength; i++) 0.54 - 0.46 * math.cos(2 * math.pi * i / (frameLength - 1)),
  ]);

  static final List<_Filter> _filters = _melFilters();

  static final List<Float64List> _dct = [
    for (var k = 1; k <= coefficients; k++)
      Float64List.fromList([
        for (var m = 0; m < melBands; m++) math.cos(math.pi * k * (m + 0.5) / melBands) * math.sqrt(2 / melBands),
      ]),
  ];

  /// One feature row per 10 ms frame. Fewer than 25 ms of sound gives no rows.
  static List<Float64List> features(Float64List samples) {
    final rows = <Float64List>[];
    final re = Float64List(fftSize);
    final im = Float64List(fftSize);
    final power = Float64List(fftSize ~/ 2 + 1);
    final logMel = Float64List(melBands);
    for (var start = 0; start + frameLength <= samples.length; start += hop) {
      re.fillRange(0, fftSize, 0);
      im.fillRange(0, fftSize, 0);
      for (var i = 0; i < frameLength; i++) {
        final previous = start + i > 0 ? samples[start + i - 1] : 0.0;
        re[i] = (samples[start + i] - 0.97 * previous) * _window[i];
      }
      fft(re, im);
      for (var k = 0; k < power.length; k++) {
        power[k] = re[k] * re[k] + im[k] * im[k];
      }
      for (var m = 0; m < melBands; m++) {
        final f = _filters[m];
        var sum = 0.0;
        for (var j = 0; j < f.weights.length; j++) {
          sum += f.weights[j] * power[f.firstBin + j];
        }
        logMel[m] = math.log(sum + 1e-10);
      }
      final row = Float64List(coefficients);
      for (var k = 0; k < coefficients; k++) {
        final basis = _dct[k];
        var c = 0.0;
        for (var m = 0; m < melBands; m++) {
          c += basis[m] * logMel[m];
        }
        row[k] = c;
      }
      rows.add(row);
    }
    // Cepstral mean normalisation.
    if (rows.isNotEmpty) {
      for (var k = 0; k < coefficients; k++) {
        var mean = 0.0;
        for (final r in rows) {
          mean += r[k];
        }
        mean /= rows.length;
        for (final r in rows) {
          r[k] -= mean;
        }
      }
    }
    return rows;
  }

  /// In-place radix-2 FFT; [re] and [im] must have the same power-of-two length.
  static void fft(Float64List re, Float64List im) {
    final n = re.length;
    for (var i = 1, j = 0; i < n; i++) {
      var bit = n >> 1;
      for (; (j & bit) != 0; bit >>= 1) {
        j ^= bit;
      }
      j ^= bit;
      if (i < j) {
        var t = re[i];
        re[i] = re[j];
        re[j] = t;
        t = im[i];
        im[i] = im[j];
        im[j] = t;
      }
    }
    for (var len = 2; len <= n; len <<= 1) {
      final angle = -2 * math.pi / len;
      final wr = math.cos(angle);
      final wi = math.sin(angle);
      final half = len >> 1;
      for (var i = 0; i < n; i += len) {
        var cr = 1.0;
        var ci = 0.0;
        for (var k = 0; k < half; k++) {
          final a = i + k;
          final b = a + half;
          final vr = re[b] * cr - im[b] * ci;
          final vi = re[b] * ci + im[b] * cr;
          re[b] = re[a] - vr;
          im[b] = im[a] - vi;
          re[a] += vr;
          im[a] += vi;
          final t = cr * wr - ci * wi;
          ci = cr * wi + ci * wr;
          cr = t;
        }
      }
    }
  }

  static double _hzToMel(double hz) => 2595 * math.log(1 + hz / 700) / math.ln10;
  static double _melToHz(double mel) => 700 * (math.pow(10, mel / 2595) - 1);

  /// Triangular mel filters over the FFT bins (HTK style).
  static List<_Filter> _melFilters() {
    final low = _hzToMel(lowHz);
    final high = _hzToMel(highHz);
    final edges = [for (var i = 0; i < melBands + 2; i++) _melToHz(low + (high - low) * i / (melBands + 1))];
    const binHz = sampleRate / fftSize;
    return [
      for (var m = 0; m < melBands; m++) () {
        final left = edges[m], centre = edges[m + 1], right = edges[m + 2];
        final first = (left / binHz).ceil();
        final last = math.min((right / binHz).floor(), fftSize ~/ 2);
        final weights = Float64List(math.max(0, last - first + 1));
        for (var k = first; k <= last; k++) {
          final hz = k * binHz;
          weights[k - first] = hz <= centre ? (hz - left) / (centre - left) : (right - hz) / (right - centre);
        }
        return _Filter(first, weights);
      }(),
    ];
  }
}

class _Filter {
  const _Filter(this.firstBin, this.weights);

  final int firstBin;
  final Float64List weights;
}
