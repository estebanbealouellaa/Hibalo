import 'dart:async';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'hiligaynon_tts_dsp.dart';
import 'hiligaynon_tts_engine.dart';

enum SpeakStatus { idle, preparing, speaking }

const String _googleEngine = 'com.google.android.tts';
const List<String> _filipinoCodes = ['fil-PH', 'tl-PH'];
const double _filipinoRate = 0.45;

/// How long the phone's voice gets to start speaking. A voice can be listed
/// as installed while its data is still missing, and then nothing plays.
const Duration _speechStartTimeout = Duration(seconds: 6);

/// Android's name for a voice whose data isn't downloaded yet.
const String _notInstalled = 'notInstalled';

/// The best voice from getVoices for [languageCode], or null. Only voices
/// that are on the phone and need no network count, and "-local" ones win.
@visibleForTesting
Map<String, String>? pickOfflineVoice(List<dynamic> voices, String languageCode) {
  final language = languageCode.split('-').first.toLowerCase();
  Map<String, String>? best;
  for (final raw in voices.whereType<Map<dynamic, dynamic>>()) {
    final voice = raw.map((k, v) => MapEntry('$k', '$v'));
    final name = voice['name'] ?? '';
    final locale = voice['locale'] ?? '';
    final features = (voice['features'] ?? '').split('\t');
    final offline =
        voice['network_required'] == '0' &&
        !name.endsWith('-network') &&
        !features.contains(_notInstalled);
    if (!offline || locale.split('-').first.toLowerCase() != language) continue;
    final picked = {'name': name, 'locale': locale};
    if (name.endsWith('-local')) return picked;
    best ??= picked;
  }
  return best;
}

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

/// "Listen": Hiligaynon uses the offline voice, Filipino (or a build without the voice) the phone's fil-PH voice; [prepare] starts early so it feels instant.
class TranslationSpeaker {
  /// Shared by every screen so the models are loaded only once.
  static final HiligaynonTtsEngine _engine = HiligaynonTtsEngine();
  static Future<bool>? _bundled;

  static _Job? _job;

  /// Finished audio (text -> 16-bit samples), newest last.
  static final Map<String, Int16List> _cache = {};
  static const int _cacheSize = 30;

  static bool _pcmReady = false;

  /// True once a Filipino voice is set. A failed search isn't remembered, so
  /// a voice installed later is found on the next tap.
  static bool _filipinoReady = false;
  static Future<bool>? _filipinoSearch;

  /// Shared by every screen: each new FlutterTts takes the speech events away
  /// from the one before it.
  static final FlutterTts _tts = _createTts();

  /// The speaker that last started the phone's voice; it gets the events.
  static TranslationSpeaker? _active;

  static FlutterTts _createTts() {
    final tts = FlutterTts();
    tts.setStartHandler(() => _active?._onSpeechStarted());
    tts.setCompletionHandler(() => _active?._done());
    tts.setCancelHandler(() => _active?._done());
    tts.setErrorHandler((message) => _active?._onSpeechError(message));
    return tts;
  }

  /// Called when Listen needs the phone's Filipino voice and it has none.
  VoidCallback? onFilipinoVoiceMissing;

  /// Called when the phone lists a Filipino voice but it didn't speak.
  VoidCallback? onFilipinoVoiceNotReady;

  final ValueNotifier<SpeakStatus> status = ValueNotifier(SpeakStatus.idle);
  Timer? _startWatchdog;
  int _request = 0;
  bool _disposed = false;
  StreamSubscription<void>? _jobSub;
  Timer? _endTimer;
  _Job? _playingJob;

  TranslationSpeaker() {
    _ensureFilipinoVoice(_tts);
  }

  static Future<bool> _hasVoice() =>
      _bundled ??= HiligaynonTtsEngine.isBundled();

  /// Finds the Filipino voice once. The chosen voice stays set for every
  /// speaker.
  static Future<bool> _ensureFilipinoVoice(FlutterTts tts) async {
    if (_filipinoReady) return true;
    return _filipinoSearch ??= _findFilipinoVoice(tts).then((found) {
      _filipinoReady = found;
      _filipinoSearch = null;
      return found;
    });
  }

  static Future<bool> _findFilipinoVoice(FlutterTts tts) async {
    if (!Platform.isAndroid) {
      await tts.setLanguage(_filipinoCodes.first);
      await tts.setSpeechRate(_filipinoRate);
      return true;
    }
    try {
      for (final engine in await _enginesToTry(tts)) {
        if (await _useFilipinoVoice(tts, engine)) return true;
      }
    } catch (e) {
      debugPrint('[FilipinoTTS] voice search failed: $e');
    }
    debugPrint('[FilipinoTTS] no offline Filipino voice on this phone');
    return false;
  }

  /// Google's engine first, then the phone's default, then the others.
  static Future<List<String>> _enginesToTry(FlutterTts tts) async {
    final installed = ((await tts.getEngines) as List? ?? const [])
        .whereType<String>()
        .toList();
    final fallback = await tts.getDefaultEngine;
    return {
      if (installed.contains(_googleEngine)) _googleEngine,
      if (fallback is String && installed.contains(fallback)) fallback,
      ...installed,
    }.toList();
  }

  /// Sets the best offline Filipino voice of [engine], if it has one.
  static Future<bool> _useFilipinoVoice(FlutterTts tts, String engine) async {
    try {
      // No timeout: starting a second engine while this one is still starting
      // makes flutter_tts reply twice, and that crashes the app.
      await tts.setEngine(engine);
      final voices = (await tts.getVoices) as List? ?? const [];
      for (final code in _filipinoCodes) {
        if (await tts.isLanguageAvailable(code) != true) continue;
        final voice = pickOfflineVoice(voices, code);
        if (voice == null) continue;
        await tts.setLanguage(code);
        if (await tts.setVoice(voice) != 1) continue;
        // Set after the engine: changing engines starts a new speech object.
        await tts.setSpeechRate(_filipinoRate);
        debugPrint(
          '[FilipinoTTS] engine=$engine lang=$code voice=${voice['name']}',
        );
        return true;
      }
    } on PlatformException catch (e) {
      debugPrint('[FilipinoTTS] $engine did not start: $e');
    }
    return false;
  }

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
    _startWatchdog?.cancel();
    if (!_disposed) status.value = SpeakStatus.idle;
  }

  void _onSpeechStarted() => _startWatchdog?.cancel();

  void _onSpeechError(String message) {
    debugPrint('[FilipinoTTS] speech error: $message');
    final neverStarted = _startWatchdog?.isActive ?? false;
    _done();
    if (neverStarted) onFilipinoVoiceNotReady?.call();
  }

  /// Nothing played in time: stop waiting and tell the user.
  void _onSpeechStartTimeout(int request) {
    if (request != _request || _disposed) return;
    debugPrint('[FilipinoTTS] no speech after $_speechStartTimeout');
    _request++;
    _tts.stop();
    status.value = SpeakStatus.idle;
    onFilipinoVoiceNotReady?.call();
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

    // Never speak with a voice of another language.
    status.value = SpeakStatus.preparing;
    final hasFilipino = await _ensureFilipinoVoice(_tts);
    if (request != _request || _disposed) return;
    if (!hasFilipino) {
      status.value = SpeakStatus.idle;
      onFilipinoVoiceMissing?.call();
      return;
    }

    status.value = SpeakStatus.speaking;
    _active = this;
    _startWatchdog?.cancel();
    _startWatchdog = Timer(
      _speechStartTimeout,
      () => _onSpeechStartTimeout(request),
    );
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

  /// Starts once two pieces are ready, so a long cut first sentence plays without a gap.
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
    _startWatchdog?.cancel();
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
    _startWatchdog?.cancel();
    _endTimer?.cancel();
    _jobSub?.cancel();
    if (identical(_active, this)) _active = null;
    _tts.stop();
    if (status.value != SpeakStatus.idle) _releasePcm();
    status.dispose();
  }
}
