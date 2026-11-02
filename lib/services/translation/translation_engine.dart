// Offline translation model: round-2 student (MarianMT, ONNX int8), section
// (G) of docs/translation/summary.md.
//
// Encoder:  input_ids, attention_mask -> last_hidden_state
// Decoder:  one token at a time, with a cache of past results:
//   input_ids [1, 1], encoder_attention_mask, encoder_hidden_states,
//   use_cache_branch [1], past_key_values.{L}.decoder.key|value and
//   past_key_values.{L}.encoder.key|value
//   -> logits [1, 1, vocab], present.{L}.*  (same names)
//
// The first decoder step gets zeros as cache. The encoder part of the cache
// is only set once, from step 1. The decoder part changes on every step.
//
// flutter_onnxruntime runs the model on a native background thread, so these
// calls don't block the UI. Tensors live on the native side and we only hold
// handles, so beam search can share a cache between hypotheses without
// copying it.

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

/// Number of hypotheses kept by beam search. Change it here.
const int kBeamSize = 4;

/// The same, for each sentence of an input with 2 or more sentences.
const int kParagraphBeamSize = 2;

/// CPU threads for one model call.
const int kTranslationThreads = 2;

/// A decoder cache that may be used by several hypotheses. It is freed when
/// the last one stops using it.
class _SharedCache {
  _SharedCache(this.tensors);

  final Map<String, OrtValue> tensors;
  int users = 0;

  Future<void> release() async {
    if (--users > 0) return;
    await Future.wait(tensors.values.map((t) => t.dispose()));
  }
}

class _Hypothesis {
  _Hypothesis(this.score, this.tokens, this.cache) {
    cache?.users++;
  }

  final double score; // total log-probability so far
  final List<int> tokens;
  final _SharedCache? cache; // null on the first step: zeros are used
}

class _Candidate {
  _Candidate(this.score, this.from, this.token, this.cache);

  final double score;
  final _Hypothesis from;
  final int token;
  final _SharedCache cache;
}

/// What one decoder step gives back.
class _StepResult {
  _StepResult(this.logits, this.present);

  final List<double> logits;
  final Map<String, OrtValue> present;
}

class TranslationEngine {
  TranslationEngine({this.threads = kTranslationThreads});

  final int threads;

  static const String modelDir = 'assets/translation/models';
  static const String _encoderFile = 'encoder_model.onnx';
  static const String _decoderFile = 'decoder_model_merged.onnx';

  /// Same limit as the Python model: the 160th token is always </s>.
  static const int _maxSteps = 160;

  static const int _startToken = 0;
  static const int _endToken = 1;

  /// Never output pad, unk or the language tags.
  static const List<int> _blocked = [0, 2, 3, 4];

  final OnnxRuntime _ort = OnnxRuntime();

  late OrtSession _encoder;
  late OrtSession _decoder;

  /// Every past_key_values.* name, built from decoder_layers in config.json,
  /// so the 8x4 backup model works with no code change.
  late List<String> _pastNames;
  late OrtValue _zeroPast;
  late OrtValue _useCacheFalse;
  late OrtValue _useCacheTrue;

  Future<void>? _loading;

  /// Only one translation uses the sessions at a time.
  Future<void> _busy = Future.value();

  /// True when the model files were bundled into this build.
  static Future<bool> isBundled() async {
    try {
      final assets = (await AssetManifest.loadFromAssetBundle(
        rootBundle,
      )).listAssets();
      return [
        _encoderFile,
        _decoderFile,
        'config.json',
        'spm.model',
      ].every((f) => assets.contains('$modelDir/$f'));
    } catch (_) {
      return false;
    }
  }

  /// Loads the two sessions once and keeps them in memory.
  Future<void> load() => _loading ??= _load().catchError((Object e) {
    _loading = null; // allow a retry
    throw e;
  });

  Future<void> _load() async {
    final sw = Stopwatch()..start();
    final config =
        jsonDecode(await rootBundle.loadString('$modelDir/config.json'))
            as Map<String, dynamic>;
    final layers = (config['decoder_layers'] as num).toInt();
    final heads = (config['decoder_attention_heads'] as num).toInt();
    final dModel = (config['d_model'] as num).toInt();
    final headSize = dModel ~/ heads;

    _pastNames = [
      for (var l = 0; l < layers; l++)
        for (final part in const ['decoder', 'encoder'])
          for (final kind in const ['key', 'value'])
            'past_key_values.$l.$part.$kind',
    ];

    final options = OrtSessionOptions(
      intraOpNumThreads: threads,
      interOpNumThreads: 1,
      providers: [OrtProvider.CPU],
    );
    _encoder = await _ort.createSessionFromAsset(
      '$modelDir/$_encoderFile',
      options: options,
    );
    _decoder = await _ort.createSessionFromAsset(
      '$modelDir/$_decoderFile',
      options: options,
    );

    _zeroPast = await OrtValue.fromList(Float32List(heads * headSize), [
      1,
      heads,
      1,
      headSize,
    ]);
    _useCacheFalse = await OrtValue.fromList(<bool>[false], [1]);
    _useCacheTrue = await OrtValue.fromList(<bool>[true], [1]);
    debugPrint(
      '[HibaloTranslate] model loaded in ${sw.elapsedMilliseconds} ms '
      '($layers decoder layers, $threads threads)',
    );
  }

  /// Translates source ids (tag + text + </s>) with beam search.
  Future<List<int>> beamSearch(
    List<int> sourceIds, {
    int beamSize = kBeamSize,
  }) => _withEncoder(
    sourceIds,
    (hidden, mask) => _beam(hidden, mask, beamSize),
  );

  /// Translates source ids token by token. Only used by the exact-match test
  /// against the reference CSV.
  Future<List<int>> greedySearch(List<int> sourceIds) =>
      _withEncoder(sourceIds, _greedy);

  /// Runs one job at a time: the encoder, then [decode].
  Future<List<int>> _withEncoder(
    List<int> sourceIds,
    Future<List<int>> Function(OrtValue hidden, OrtValue mask) decode,
  ) {
    final run = _busy.then((_) async {
      await load();
      final s = sourceIds.length;
      final ids = await OrtValue.fromList(Int64List.fromList(sourceIds), [1, s]);
      final mask = await OrtValue.fromList(
        Int64List(s)..fillRange(0, s, 1),
        [1, s],
      );
      Map<String, OrtValue> encoded = const {};
      try {
        encoded = await _encoder.run({
          'input_ids': ids,
          'attention_mask': mask,
        });
        return await decode(encoded['last_hidden_state']!, mask);
      } finally {
        await Future.wait([ids, mask, ...encoded.values].map((v) => v.dispose()));
      }
    });
    _busy = run.then((_) {}, onError: (_) {});
    return run;
  }

  /// One decoder call. [past] is the full cache for this step.
  Future<_StepResult> _step(
    int token,
    OrtValue hidden,
    OrtValue mask,
    Map<String, OrtValue> past, {
    required bool first,
  }) async {
    final input = await OrtValue.fromList(Int64List.fromList([token]), [1, 1]);
    try {
      final out = await _decoder.run({
        'input_ids': input,
        'encoder_attention_mask': mask,
        'encoder_hidden_states': hidden,
        'use_cache_branch': first ? _useCacheFalse : _useCacheTrue,
        ...past,
      });
      final logits = await out['logits']!.asFlattenedList();
      await out.remove('logits')!.dispose();
      return _StepResult(logits.cast<double>(), out);
    } finally {
      await input.dispose();
    }
  }

  static String _presentName(String pastName) =>
      pastName.replaceFirst('past_key_values', 'present');

  /// Moves the wanted cache tensors out of [present] and frees the others.
  Future<Map<String, OrtValue>> _take(
    Map<String, OrtValue> present,
    Iterable<String> pastNames,
  ) async {
    final kept = {
      for (final name in pastNames) name: present.remove(_presentName(name))!,
    };
    await Future.wait(present.values.map((v) => v.dispose()));
    return kept;
  }

  Iterable<String> get _decoderPast =>
      _pastNames.where((n) => n.contains('.decoder.'));
  Iterable<String> get _encoderPast =>
      _pastNames.where((n) => n.contains('.encoder.'));

  // ── Greedy (summary.md, "Greedy loop") ─────────────────────────────────
  Future<List<int>> _greedy(OrtValue hidden, OrtValue mask) async {
    final output = <int>[];
    var encoderPast = <String, OrtValue>{};
    var decoderPast = <String, OrtValue>{};
    var token = _startToken;
    try {
      for (var step = 0; step < _maxSteps; step++) {
        final first = step == 0;
        final past = first
            ? {for (final n in _pastNames) n: _zeroPast}
            : {...encoderPast, ...decoderPast};
        final result = await _step(token, hidden, mask, past, first: first);

        final logits = Float64List.fromList(result.logits);
        for (final id in _blocked) {
          logits[id] = double.negativeInfinity;
        }
        token = step == _maxSteps - 1 ? _endToken : _argMax(logits);

        final oldDecoderPast = decoderPast;
        final names = first ? _pastNames : _decoderPast;
        final kept = await _take(result.present, names);
        await Future.wait(oldDecoderPast.values.map((v) => v.dispose()));
        decoderPast = {
          for (final n in _decoderPast) n: kept[n]!,
        };
        if (first) encoderPast = {for (final n in _encoderPast) n: kept[n]!};

        if (token == _endToken) break;
        output.add(token);
      }
      return output;
    } finally {
      await Future.wait(
        [...encoderPast.values, ...decoderPast.values].map((v) => v.dispose()),
      );
    }
  }

  static int _argMax(List<double> values) {
    var best = 0;
    for (var i = 1; i < values.length; i++) {
      if (values[i] > values[best]) best = i;
    }
    return best;
  }

  // ── Beam search ────────────────────────────────────────────────────────
  //
  // Each hypothesis runs on its own, one decoder call per step, reusing its
  // cache handles. (Batching would mean copying all the cache tensors through
  // the plugin on every step.) The rule was checked in Python on the everyday
  // test: 75.35 / 64.86 chrF++ against 75.1 / 64.9 in the spec.
  Future<List<int>> _beam(OrtValue hidden, OrtValue mask, int beamSize) async {
    final finished = <(double, List<int>)>[]; // (score, tokens), best first
    var encoderPast = <String, OrtValue>{};
    var live = [_Hypothesis(0, const [], null)];
    final created = <_SharedCache>[];

    try {
      for (var step = 0; step < _maxSteps; step++) {
        final first = step == 0;
        final candidates = <_Candidate>[];

        for (final hyp in live) {
          final past = first
              ? {for (final n in _pastNames) n: _zeroPast}
              : {...encoderPast, ...hyp.cache!.tensors};
          final token = hyp.tokens.isEmpty ? _startToken : hyp.tokens.last;
          final result = await _step(token, hidden, mask, past, first: first);

          final kept = await _take(
            result.present,
            first ? _pastNames : _decoderPast,
          );
          if (first) {
            encoderPast = {for (final n in _encoderPast) n: kept[n]!};
          }
          final cache = _SharedCache({
            for (final n in _decoderPast) n: kept[n]!,
          });
          // Holds the cache until this step's choice is made.
          cache.users++;
          created.add(cache);

          final scores = _logSoftmax(result.logits);
          for (final id in _blocked) {
            scores[id] = double.negativeInfinity;
          }
          for (final id in _topIds(scores, 2 * beamSize)) {
            candidates.add(_Candidate(hyp.score + scores[id], hyp, id, cache));
          }
        }

        candidates.sort((a, b) => b.score.compareTo(a.score));
        final next = <_Hypothesis>[];
        for (final c in candidates) {
          if (c.token == _endToken) {
            // Length penalty 1.0: total log-prob / length (with </s>).
            final length = c.from.tokens.length + 1;
            finished.add((c.score / length, c.from.tokens));
          } else if (next.length < beamSize) {
            next.add(
              _Hypothesis(c.score, [...c.from.tokens, c.token], c.cache),
            );
          }
        }
        finished.sort((a, b) => b.$1.compareTo(a.$1));
        if (finished.length > beamSize) finished.length = beamSize;

        // This step's hypotheses and the step's own holds are done with.
        await Future.wait(
          live.where((h) => h.cache != null).map((h) => h.cache!.release()),
        );
        await Future.wait(created.map((c) => c.release()));
        created.clear();
        live = next;
        if (live.isEmpty) break;

        // Nothing still running can beat the worst of the finished ones.
        final bestPossible = live.first.score / (step + 2);
        if (finished.length >= beamSize && bestPossible <= finished.last.$1) {
          break;
        }
      }
      if (finished.isNotEmpty) return finished.first.$2;
      return live.first.tokens; // hit the 160 token limit
    } finally {
      await Future.wait(created.map((c) => c.release()));
      await Future.wait(
        live.where((h) => h.cache != null).map((h) => h.cache!.release()),
      );
      await Future.wait(encoderPast.values.map((v) => v.dispose()));
    }
  }

  static Float64List _logSoftmax(List<double> logits) {
    var top = double.negativeInfinity;
    for (final v in logits) {
      top = math.max(top, v);
    }
    var sum = 0.0;
    for (final v in logits) {
      sum += math.exp(v - top);
    }
    final shift = top + math.log(sum);
    final out = Float64List(logits.length);
    for (var i = 0; i < logits.length; i++) {
      out[i] = logits[i] - shift;
    }
    return out;
  }

  /// The [count] highest-scoring ids, best first.
  static List<int> _topIds(List<double> scores, int count) {
    final top = <int>[];
    for (var id = 0; id < scores.length; id++) {
      if (scores[id] == double.negativeInfinity) continue;
      if (top.length == count && scores[id] <= scores[top.last]) continue;
      var at = top.length;
      while (at > 0 && scores[id] > scores[top[at - 1]]) {
        at--;
      }
      top.insert(at, id);
      if (top.length > count) top.removeLast();
    }
    return top;
  }
}
