import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../models/catalog.dart';
import '../../models/questions.dart';
import 'clip_decoder.dart';
import 'dtw.dart';
import 'mfcc.dart';

/// Q09 pronunciation similarity (practice only; FUTURE_FEATURES #1). It measures how
/// alike the learner's sound is to the native clip, not whether the word is "correct".

/// When a recording counts as heard: its loudest 25 ms frame reaches [minLevelDb]
/// (dBFS) and the sound lasts at least [minSpeechMs].
class SpeechCheck {
  const SpeechCheck({this.minSpeechMs = 250, this.minLevelDb = -40});

  final int minSpeechMs;
  final double minLevelDb;

  /// Frames more than this many dB under the loudest frame count as silence.
  static const double dynamicRangeDb = 35;

  /// Below this a frame is always silence (mic hiss).
  static const double floorDb = -70;

  /// Silence kept on each side of the speech.
  static const int padMs = 50;
}

/// Where the speech is in a 16 kHz recording.
class SpeechSpan {
  const SpeechSpan({required this.start, required this.end, required this.speechMs, required this.peakDb, required this.heard});

  /// Sample range to compare (silence trimmed, [SpeechCheck.padMs] kept).
  final int start;
  final int end;
  final int speechMs;

  /// Loudest 25 ms frame, dBFS (0 = full scale).
  final double peakDb;
  final bool heard;
}

SpeechSpan findSpeech(Float64List x, SpeechCheck check) {
  const frame = 400, hop = 160, rate = 16000;
  final levels = <double>[];
  for (var s = 0; s + frame <= x.length; s += hop) {
    var sum = 0.0;
    for (var i = s; i < s + frame; i++) {
      sum += x[i] * x[i];
    }
    levels.add(10 * math.log(sum / frame + 1e-12) / math.ln10);
  }
  if (levels.isEmpty) return const SpeechSpan(start: 0, end: 0, speechMs: 0, peakDb: -120, heard: false);
  final peak = levels.reduce(math.max);
  // The trim only looks at the clip's own loudness, so a recording and a native clip are
  // cut the same way; minLevelDb / minSpeechMs only decide "Couldn't hear".
  final threshold = math.max(SpeechCheck.floorDb, peak - SpeechCheck.dynamicRangeDb);
  final first = levels.indexWhere((l) => l >= threshold);
  final last = levels.lastIndexWhere((l) => l >= threshold);
  if (first < 0) return SpeechSpan(start: 0, end: 0, speechMs: 0, peakDb: peak, heard: false);
  final speechMs = ((last - first) * hop + frame) * 1000 ~/ rate;
  const pad = SpeechCheck.padMs * rate ~/ 1000;
  return SpeechSpan(
    start: math.max(0, first * hop - pad),
    end: math.min(x.length, last * hop + frame + pad),
    speechMs: speechMs,
    peakDb: peak,
    heard: peak >= check.minLevelDb && speechMs >= check.minSpeechMs,
  );
}

/// The three practice levels. Lower distance or relative score = closer.
enum PronunciationLevel { veryClose, almost, tryAgain }

/// Null when a threshold is missing (settings.pronunciationFeedback has both, set from test recordings).
PronunciationLevel? levelFor(double score, {double? veryClose, double? almost}) {
  if (veryClose == null || almost == null || score.isNaN) return null;
  if (score <= veryClose) return PronunciationLevel.veryClose;
  if (score <= almost) return PronunciationLevel.almost;
  return PronunciationLevel.tryAgain;
}

class PronunciationComparison {
  const PronunciationComparison({
    required this.speech,
    required this.distance,
    required this.relative,
    required this.rank,
    required this.compared,
    required this.decodeMs,
    required this.computeMs,
    required this.decodedClips,
  });

  final SpeechSpan speech;
  bool get heard => speech.heard;

  /// (a) Plain DTW distance to the target clip; null when not heard.
  final double? distance;

  /// (b) Distance to the target ÷ the average distance to the other clips
  /// (below 1 = closer to the target than to other words); null without others.
  final double? relative;

  /// 1 = the target is the closest of all [compared] clips.
  final int? rank;

  /// Target + the other clips that could be used.
  final int compared;

  /// Time spent decoding clips not decoded before (0 once they're all cached).
  final int decodeMs;

  /// Speech check + MFCC + DTW, in the background isolate.
  final int computeMs;
  final int decodedClips;
}

/// Compares a learner recording with a native clip. Clip features are kept in memory
/// for the session (they're lesson clips, not the learner's voice); the learner's
/// recording is only read, never kept.
class PronunciationComparer {
  PronunciationComparer({ClipDecoder? decoder, this.check = const SpeechCheck(), this.useIsolate = true})
      : decoder = decoder ?? const AndroidClipDecoder();

  final ClipDecoder decoder;
  final SpeechCheck check;

  /// Off in unit tests that run inside fake async.
  final bool useIsolate;

  /// One per app run, so the native clips are decoded once (they're cached in it).
  static PronunciationComparer shared(SpeechCheck check) =>
      _shared != null && _shared!.check.minSpeechMs == check.minSpeechMs && _shared!.check.minLevelDb == check.minLevelDb
          ? _shared!
          : _shared = PronunciationComparer(check: check);
  static PronunciationComparer? _shared;

  final Map<String, List<Float64List>> _features = {};
  final Set<String> _failed = {};

  bool isCached(String clip) => _features.containsKey(clip);

  /// [learner] = 16 kHz mono samples (-1…1). [others] = other clips to compare
  /// against for the relative score (the target is skipped if listed).
  /// Throws [ClipDecodeException] if the target clip can't be decoded.
  Future<PronunciationComparison> compare({
    required Float64List learner,
    required String target,
    List<String> others = const [],
  }) async {
    final watch = Stopwatch()..start();
    final wanted = [target, for (final o in others) if (o != target) o];
    final raw = <String, RawPcm>{};
    for (final clip in wanted) {
      if (_features.containsKey(clip) || _failed.contains(clip)) continue;
      try {
        raw[clip] = await decoder.decode(clip);
      } on ClipDecodeException {
        if (clip == target) rethrow;
        _failed.add(clip);
      }
    }
    final decodeMs = watch.elapsedMilliseconds;

    final job = _Job(
      learner: learner,
      raw: raw,
      cached: {for (final c in wanted) if (_features.containsKey(c)) c: _features[c]!},
      target: target,
      check: check,
    );
    watch.reset();
    final result = useIsolate ? await _runInBackground(job) : _run(job);
    final computeMs = watch.elapsedMilliseconds;
    _features.addAll(result.newFeatures);

    final d = result.distances;
    final targetDistance = d[target];
    final otherDistances = [
      for (final e in d.entries)
        if (e.key != target && e.value.isFinite) e.value,
    ];
    double? relative;
    int? rank;
    if (targetDistance != null && otherDistances.isNotEmpty) {
      final mean = otherDistances.reduce((a, b) => a + b) / otherDistances.length;
      relative = mean > 0 ? targetDistance / mean : null;
      rank = 1 + otherDistances.where((o) => o < targetDistance).length;
    }
    return PronunciationComparison(
      speech: result.speech,
      distance: targetDistance,
      relative: relative,
      rank: rank,
      compared: d.isEmpty ? 0 : 1 + otherDistances.length,
      decodeMs: decodeMs,
      computeMs: computeMs,
      decodedClips: raw.length,
    );
  }
}

/// Every Beginner Q09 clip that is in the app (the "others" for the relative score).
List<String> beginnerSpeakingClips(LessonCatalog catalog) => [
      for (final level in catalog.levels)
        if (level.id == 'beginner')
          for (final lesson in level.lessons)
            for (final q in lesson.quiz?.questions ?? const <QuizQuestion>[])
              if (q is SpeakingData && q.audio != null) q.audio!,
    ];

class _Job {
  const _Job({required this.learner, required this.raw, required this.cached, required this.target, required this.check});

  final Float64List learner;
  final Map<String, RawPcm> raw;
  final Map<String, List<Float64List>> cached;
  final String target;
  final SpeechCheck check;
}

class _Result {
  const _Result(this.speech, this.distances, this.newFeatures);

  final SpeechSpan speech;
  final Map<String, double> distances;
  final Map<String, List<Float64List>> newFeatures;
}

/// Features of a 16 kHz signal with the silence trimmed.
List<Float64List> _trimmedFeatures(Float64List x, SpeechSpan span) =>
    Mfcc.features(Float64List.sublistView(x, span.start, math.max(span.start, span.end)));

/// Top-level so the isolate closure only carries [job] (not the comparer or the decoder).
Future<_Result> _runInBackground(_Job job) => Isolate.run(() => _run(job));

_Result _run(_Job job) {
  final newFeatures = <String, List<Float64List>>{};
  for (final e in job.raw.entries) {
    final clip = toMono16k(e.value);
    // Native clips are already trimmed; the same trim keeps both sides alike.
    newFeatures[e.key] = _trimmedFeatures(clip, findSpeech(clip, job.check));
  }
  final speech = findSpeech(job.learner, job.check);
  if (!speech.heard) return _Result(speech, const {}, newFeatures);
  final mine = _trimmedFeatures(job.learner, speech);
  final all = {...job.cached, ...newFeatures};
  return _Result(speech, {for (final e in all.entries) e.key: dtwDistance(mine, e.value)}, newFeatures);
}
