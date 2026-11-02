import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'hiligaynon_tts_dsp.dart';
import 'hiligaynon_tts_engine.dart';

enum SpeakStatus { idle, preparing, speaking }

/// One Hiligaynon text being turned into speech (possibly before anyone
/// tapped "Listen"). Pieces arrive while the voice is still generating.
class _Job {
  _Job(this.text);

  final String text;
  final List<Int16List> pieces = [];
  final StreamController<void> changes = StreamController<void>.broadcast();
  bool done = false;
  Object? error;
  int listeners = 0; // speakers currently playing this job

  void _changed() {
    if (!changes.isClosed) changes.add(null);
  }
}

/// "Listen" button for translation results.
///
/// Hiligaynon output is spoken by the offline native-speaker voice
/// ([HiligaynonTtsEngine]); Filipino output, or Hiligaynon when the voice
/// models are not in this build, uses the phone's fil-PH voice.
///
/// To make "Listen" feel instant:
///  * [prepare] starts generating as soon as a translation appears, before
///    the user taps anything;
///  * audio is played piece by piece through a PCM stream while the rest is
///    still being generated;
///  * finished results are kept in memory, so a replay is immediate.
class TranslationSpeaker {
  /// Shared by every screen so the models are loaded only once.
  static final HiligaynonTtsEngine _engine = HiligaynonTtsEngine();
  static Future<bool>? _bundled;

  /// The generation in progress (or the last one).
  static _Job? _job;

  /// Finished audio (text -> 16-bit samples), newest last.
  static final Map<String, Int16List> _cache = {};
  static const int _cacheSize = 30;

  static bool _pcmReady = false;

  final ValueNotifier<SpeakStatus> status = ValueNotifier(SpeakStatus.idle);
  final FlutterTts _tts = FlutterTts();
  int _request = 0;
  bool _disposed = false;
  StreamSubscription<void>? _jobSub;
  Timer? _endTimer;
  _Job? _playingJob;

  TranslationSpeaker() {
    _tts.setLanguage('fil-PH');
    _tts.setSpeechRate(0.45);
    _tts.setCompletionHandler(_done);
    _tts.setCancelHandler(_done);
  }

  static Future<bool> _hasVoice() =>
      _bundled ??= HiligaynonTtsEngine.isBundled();

  /// Loads the Hiligaynon voice in the background and does one tiny run, so
  /// the first "Listen" doesn't wait for it.
  static void warmUp() {
    _hasVoice().then((ok) {
      if (!ok) return;
      _engine.warmUp().catchError((Object e) {
        debugPrint('[HiligaynonTTS] warm-up failed: $e');
      });
    });
  }

  static String _key(String text) => text.trim();

  /// Starts generating [text] in the background (call it as soon as a
  /// Hiligaynon translation is shown). Cheap to call repeatedly.
  static Future<void> prepare(String text) async {
    final key = _key(text);
    if (key.isEmpty || !await _hasVoice()) return;
    if (_cache.containsKey(key)) return;
    final current = _job;
    if (current != null && current.text == key && current.error == null) {
      return;
    }
    // A newer translation replaces an old one nobody is listening to.
    if (current != null && !current.done) {
      if (current.listeners > 0) return; // don't cut off what is playing
      _engine.cancel();
    }
    _startJob(key);
  }

  static _Job _startJob(String key) {
    final job = _Job(key);
    _job = job;
    _engine.synthesize(key, onChunk: (piece) {
      job.pieces.add(_toPcm16(piece));
      job._changed();
    }).then((audio) {
      job.done = true;
      _cache.remove(key);
      _cache[key] = _toPcm16(audio);
      while (_cache.length > _cacheSize) {
        _cache.remove(_cache.keys.first);
      }
      job._changed();
    }, onError: (Object e, StackTrace st) {
      job.error = e;
      job.done = true;
      if (e is! TtsCancelled) {
        debugPrint('[HiligaynonTTS] generation failed: $e\n$st');
      }
      job._changed();
    });
    return job;
  }

  static Int16List _toPcm16(Float32List x) {
    final out = Int16List(x.length);
    for (var i = 0; i < x.length; i++) {
      out[i] = (x[i].clamp(-1.0, 1.0) * 32767).round();
    }
    return out;
  }

  static Future<void> _ensurePcm() async {
    if (_pcmReady) return;
    await FlutterPcmSound.setup(sampleRate: kSampleRate, channelCount: 1);
    await FlutterPcmSound.setFeedThreshold(kSampleRate ~/ 10);
    FlutterPcmSound.setFeedCallback((_) {});
    _pcmReady = true;
  }

  static Future<void> _releasePcm() async {
    if (!_pcmReady) return;
    _pcmReady = false;
    try {
      await FlutterPcmSound.release();
    } catch (_) {}
  }

  void _done() {
    if (!_disposed) status.value = SpeakStatus.idle;
  }

  /// Speaks [text], or stops if something is already playing/preparing.
  Future<void> toggle(String text, {required bool hiligaynon}) async {
    if (status.value != SpeakStatus.idle) {
      await stop();
      return;
    }
    if (text.trim().isEmpty) return;
    final request = ++_request;

    if (hiligaynon && await _hasVoice()) {
      status.value = SpeakStatus.preparing;
      try {
        if (await _playHiligaynon(_key(text), request)) return;
      } catch (e, st) {
        debugPrint('[HiligaynonTTS] playback failed: $e\n$st');
      }
      if (request != _request) return;
    }

    status.value = SpeakStatus.speaking;
    await _tts.speak(text);
  }

  /// Plays from the cache or from the running job. Returns false if the
  /// voice failed before any sound was played (caller falls back).
  Future<bool> _playHiligaynon(String key, int request) async {
    await _releasePcm(); // drop anything still queued from before
    await _ensurePcm();
    if (request != _request) return true;

    final cached = _cache[key];
    if (cached != null) {
      _cache[key] = _cache.remove(key)!; // mark as recently used
      final playedUntil = _feed(cached, DateTime.now());
      _playStarted(request);
      _scheduleEnd(playedUntil, request);
      return true;
    }

    var job = _job;
    if (job == null || job.text != key || job.error != null) {
      if (job != null && !job.done) _engine.cancel();
      job = _startJob(key);
    }
    final playing = job;
    playing.listeners++;
    _playingJob = playing;

    final finished = Completer<bool>();
    var fed = 0;
    var started = false;
    var playedUntil = DateTime.now();

    void pump() {
      if (request != _request || _disposed) {
        if (!finished.isCompleted) finished.complete(true);
        return;
      }
      if (playing.error != null && fed == 0) {
        if (!finished.isCompleted) finished.complete(false);
        return;
      }
      if (!started) {
        if (!_readyToStart(playing)) return;
        started = true;
        _playStarted(request);
      }
      while (fed < playing.pieces.length) {
        playedUntil = _feed(playing.pieces[fed], playedUntil);
        fed++;
      }
      if (playing.done) {
        _scheduleEnd(playedUntil, request);
        if (!finished.isCompleted) finished.complete(true);
      }
    }

    _jobSub?.cancel();
    _jobSub = playing.changes.stream.listen((_) => pump());
    pump();
    try {
      return await finished.future;
    } finally {
      playing.listeners--;
    }
  }

  /// Plays once two pieces are ready, while the next ones are still being
  /// generated. A long first sentence is cut in two, so this keeps the wait
  /// out of the middle of it. On a slow phone there can still be pauses
  /// between later sentences; removing them all would mean a much longer
  /// wait before the first sound.
  static bool _readyToStart(_Job job) => job.done || job.pieces.length >= 2;

  /// Queues [samples] on the PCM stream; returns when they will finish.
  DateTime _feed(Int16List samples, DateTime playedUntil) {
    FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
    final now = DateTime.now();
    final from = playedUntil.isAfter(now) ? playedUntil : now;
    return from.add(Duration(
        microseconds: samples.length * 1000000 ~/ kSampleRate));
  }

  void _playStarted(int request) {
    if (request != _request || _disposed) return;
    status.value = SpeakStatus.speaking;
    FlutterPcmSound.start();
  }

  void _scheduleEnd(DateTime playedUntil, int request) {
    _endTimer?.cancel();
    final wait = playedUntil.difference(DateTime.now()) +
        const Duration(milliseconds: 150);
    _endTimer = Timer(wait.isNegative ? Duration.zero : wait, () {
      if (request == _request) _done();
    });
  }

  Future<void> stop() async {
    _request++;
    _endTimer?.cancel();
    await _jobSub?.cancel();
    _jobSub = null;
    final job = _playingJob;
    _playingJob = null;
    // Stop generating only if this speaker was the one waiting for it.
    if (job != null && !job.done && identical(job, _job)) _engine.cancel();
    status.value = SpeakStatus.idle;
    await Future.wait([_releasePcm(), _tts.stop()]);
  }

  void dispose() {
    _disposed = true;
    _request++;
    _endTimer?.cancel();
    _jobSub?.cancel();
    _tts.stop();
    if (status.value != SpeakStatus.idle) _releasePcm();
    status.dispose();
  }
}
