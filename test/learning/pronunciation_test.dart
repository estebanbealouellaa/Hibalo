import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hibalo_app/learning/data/json_reader.dart';
import 'package:hibalo_app/learning/data/lesson_repository.dart';
import 'package:hibalo_app/learning/models/catalog.dart';
import 'package:hibalo_app/learning/services/pronunciation/clip_decoder.dart';
import 'package:hibalo_app/learning/services/pronunciation/dtw.dart';
import 'package:hibalo_app/learning/services/pronunciation/mfcc.dart';
import 'package:hibalo_app/learning/services/pronunciation/similarity.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MFCC', () {
    test('one 12-value row per 10 ms, averages removed', () {
      final rows = Mfcc.features(tone(440, 1));
      expect(rows.length, (rate - 400) ~/ 160 + 1);
      expect(rows.every((r) => r.length == 12), isTrue);
      for (var k = 0; k < 12; k++) {
        final mean = rows.map((r) => r[k]).reduce((a, b) => a + b) / rows.length;
        expect(mean.abs(), lessThan(1e-9));
      }
    });

    test('shorter than one frame gives no rows', () {
      expect(Mfcc.features(tone(440, 0.02)), isEmpty);
    });

    test('FFT matches a plain DFT', () {
      final r = math.Random(5);
      final x = [for (var i = 0; i < 16; i++) r.nextDouble() - 0.5];
      final re = Float64List.fromList(x), im = Float64List(16);
      Mfcc.fft(re, im);
      for (var k = 0; k < 16; k++) {
        var sr = 0.0, si = 0.0;
        for (var n = 0; n < 16; n++) {
          sr += x[n] * math.cos(2 * math.pi * k * n / 16);
          si -= x[n] * math.sin(2 * math.pi * k * n / 16);
        }
        expect(re[k], closeTo(sr, 1e-9));
        expect(im[k], closeTo(si, 1e-9));
      }
    });
  });

  group('DTW', () {
    test('same sound = 0, empty = infinity, symmetric', () {
      final a = Mfcc.features(wordA()), b = Mfcc.features(wordB());
      expect(dtwDistance(a, a), 0);
      expect(dtwDistance(a, const []), double.infinity);
      expect(dtwDistance(a, b), closeTo(dtwDistance(b, a), 1e-9));
    });

    test('the same word said slower is closer than a different word', () {
      final target = Mfcc.features(wordA());
      final slow = Mfcc.features(wordA(speed: 0.7));
      final other = Mfcc.features(wordB());
      expect(dtwDistance(slow, target), lessThan(dtwDistance(other, target)));
    });
  });

  group('resampling', () {
    int crossings(Float64List x) {
      var n = 0;
      for (var i = 1; i < x.length; i++) {
        if ((x[i - 1] < 0) != (x[i] < 0)) n++;
      }
      return n;
    }

    test('48 kHz to 16 kHz keeps the pitch and a third of the samples', () {
      final x = tone(1000, 1, sampleRate: 48000);
      final y = resample(x, 48000, 16000);
      expect(y.length, 16000);
      expect(crossings(y), closeTo(2000, 4));
      final rms = math.sqrt(y.sublist(500, 15500).map((v) => v * v).reduce((a, b) => a + b) / 15000);
      expect(rms, closeTo(0.3 / math.sqrt2, 0.01));
    });

    test('sounds above 8 kHz are filtered out, not folded into speech', () {
      final y = resample(tone(12000, 1, sampleRate: 48000), 48000, 16000);
      final rms = math.sqrt(y.sublist(500, 15500).map((v) => v * v).reduce((a, b) => a + b) / 15000);
      expect(rms, lessThan(0.01));
    });

    test('stereo is averaged to mono', () {
      final pcm = RawPcm(samples: Int16List.fromList([16384, 0, 16384, 0]), sampleRate: 16000, channels: 2);
      expect(toMono16k(pcm), [0.25, 0.25]);
    });

    test('odd byte offsets are read correctly', () {
      final bytes = Uint8List.fromList([9, 1, 0, 255, 127]);
      expect(int16FromBytes(Uint8List.sublistView(bytes, 1)), [1, 32767]);
    });
  });

  group('speech check (Couldn\'t hear)', () {
    const check = SpeechCheck(minSpeechMs: 250, minLevelDb: -40);

    test('silence is not heard', () {
      final s = findSpeech(silence(1), check);
      expect(s.heard, isFalse);
    });

    test('a quiet sound (-50 dB) is not heard', () {
      final s = findSpeech(join([silence(0.3), tone(300, 0.6, amp: 0.004), silence(0.3)]), check);
      expect(s.peakDb, lessThan(-40));
      expect(s.heard, isFalse);
    });

    test('a short click (150 ms) is not heard', () {
      final s = findSpeech(join([silence(0.4), tone(300, 0.15), silence(0.4)]), check);
      expect(s.speechMs, lessThan(250));
      expect(s.heard, isFalse);
    });

    test('a word is heard and the silence around it is trimmed', () {
      final s = findSpeech(join([silence(0.5), wordA(), silence(0.7)]), check);
      expect(s.heard, isTrue);
      expect(s.speechMs, closeTo(600, 40)); // frames that touch the word count
      expect(s.start, closeTo(0.45 * rate, 0.04 * rate));
      expect(s.end, closeTo((0.5 + 0.58 + 0.05) * rate, 0.04 * rate));
    });
  });

  group('levels', () {
    test('no level until both thresholds are set', () {
      expect(levelFor(1), isNull);
      expect(levelFor(1, veryClose: 2), isNull);
    });

    test('Very close / Almost / Try again', () {
      expect(levelFor(1.9, veryClose: 2, almost: 3), PronunciationLevel.veryClose);
      expect(levelFor(2, veryClose: 2, almost: 3), PronunciationLevel.veryClose);
      expect(levelFor(2.5, veryClose: 2, almost: 3), PronunciationLevel.almost);
      expect(levelFor(3.1, veryClose: 2, almost: 3), PronunciationLevel.tryAgain);
    });
  });

  group('comparer', () {
    Map<String, Float64List> clips() => {'a': wordA(), 'b': wordB(), 'c': wordC()};

    test('the right word with another voice and speed ranks first (both scores)', () async {
      final decoder = FakeClipDecoder(clips());
      final comparer = PronunciationComparer(decoder: decoder, useIsolate: false);
      final learner = join([silence(0.4), wordA(f0: 210, speed: 0.8), silence(0.5)]);
      final c = await comparer.compare(learner: learner, target: 'a', others: ['a', 'b', 'c']);
      expect(c.heard, isTrue);
      expect(c.rank, 1);
      expect(c.compared, 3);
      expect(c.relative, lessThan(1));
      final wrong = await comparer.compare(learner: join([silence(0.4), wordB(f0: 210), silence(0.5)]), target: 'a', others: ['b', 'c']);
      expect(wrong.distance, greaterThan(c.distance!));
      expect(wrong.relative, greaterThan(1));
    });

    test('a clip compared with itself scores 0 (both sides are trimmed the same way)', () async {
      final quietEnds = {'a': join([noise(0.3, amp: 0.004), wordA(), noise(0.3, amp: 0.004, seed: 4)]), 'b': wordB()};
      final decoder = FakeClipDecoder(quietEnds);
      final comparer = PronunciationComparer(decoder: decoder, useIsolate: false);
      final learner = toMono16k(await decoder.decode('a'));
      final c = await comparer.compare(learner: learner, target: 'a', others: ['b']);
      expect(c.distance, 0);
      expect(c.rank, 1);
    });

    test('clips are decoded once, then cached', () async {
      final decoder = FakeClipDecoder(clips());
      final comparer = PronunciationComparer(decoder: decoder, useIsolate: false);
      final first = await comparer.compare(learner: wordA(), target: 'a', others: ['b', 'c']);
      final second = await comparer.compare(learner: wordA(), target: 'a', others: ['b', 'c']);
      expect(first.decodedClips, 3);
      expect(second.decodedClips, 0);
      expect(decoder.calls, ['a', 'b', 'c']);
      expect(comparer.isCached('a'), isTrue);
    });

    test('48 kHz clips (like the real ones) work', () async {
      final at48 = {for (final e in clips().entries) e.key: resample(e.value, 16000, 48000)};
      final comparer = PronunciationComparer(decoder: FakeClipDecoder(at48, sampleRate: 48000), useIsolate: false);
      final c = await comparer.compare(learner: wordA(f0: 180), target: 'a', others: ['b', 'c']);
      expect(c.rank, 1);
    });

    test('silence: Couldn\'t hear, no scores', () async {
      final comparer = PronunciationComparer(decoder: FakeClipDecoder(clips()), useIsolate: false);
      final c = await comparer.compare(learner: silence(1.5), target: 'a', others: ['b']);
      expect(c.heard, isFalse);
      expect(c.distance, isNull);
      expect(c.relative, isNull);
      expect(c.rank, isNull);
    });

    test('a missing target clip throws; a missing other clip is skipped', () async {
      final comparer = PronunciationComparer(decoder: FakeClipDecoder(clips()), useIsolate: false);
      expect(() => comparer.compare(learner: wordA(), target: 'x'), throwsA(isA<ClipDecodeException>()));
      final c = await comparer.compare(learner: wordA(), target: 'a', others: ['b', 'missing']);
      expect(c.compared, 2);
    });

    test('runs in a background isolate', () async {
      final comparer = PronunciationComparer(decoder: FakeClipDecoder(clips()));
      final c = await comparer.compare(learner: wordA(f0: 200), target: 'a', others: ['b', 'c']);
      expect(c.rank, 1);
      expect(comparer.isCached('c'), isTrue);
    });
  });

  group('settings flag', () {
    late LessonCatalog catalog;
    setUpAll(() async {
      catalog = (await LessonRepository.load(rootBundle)).catalog;
    });

    test('off by default, no thresholds yet', () {
      final p = catalog.settings.pronunciation;
      expect(p.enabled, isFalse);
      expect(p.veryClose, isNull);
      expect(p.almost, isNull);
      expect(p.active, isFalse);
      expect(p.minSpeechMs, 250);
      expect(p.minLevelDb, -40);
    });

    test('active only when enabled and both thresholds are set', () {
      PronunciationSettings read(Map<String, dynamic> m) =>
          PronunciationSettings.fromJson(JsonReader({'minSpeechMs': 250, 'minLevelDb': -40, ...m}, 'p'));
      expect(read({'enabled': true, 'veryClose': 1.0, 'almost': null}).active, isFalse);
      expect(read({'enabled': false, 'veryClose': 1.0, 'almost': 2.0}).active, isFalse);
      expect(read({'enabled': true, 'veryClose': 1.0, 'almost': 2}).active, isTrue);
      expect(() => read({'enabled': true, 'veryClose': 3.0, 'almost': 2.0}), throwsFormatException);
      expect(PronunciationSettings.fromJson(null).active, isFalse);
    });

    test('the 10 Beginner Q09 clips are the comparison set, all in the app', () {
      final clips = beginnerSpeakingClips(catalog);
      expect(clips.length, 10);
      for (final c in clips) {
        expect(File(c).existsSync(), isTrue, reason: c);
      }
    });
  });
}
