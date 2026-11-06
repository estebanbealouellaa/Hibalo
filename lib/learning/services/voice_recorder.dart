import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';
import 'package:record/record.dart';

/// Q09 recording: kept in memory only, never written to storage or uploaded; [clear] deletes it.
abstract class VoiceRecorder {
  /// Starts recording. Returns false when the mic is not available
  /// (permission refused, no mic, or the recorder failed to start).
  Future<bool> start();

  Future<void> stop();

  bool get hasRecording;

  Future<void> play();

  Future<void> clear();

  Future<void> dispose();
}

/// The real recorder: 16 kHz mono 16-bit PCM from the `record` package,
/// collected in memory and played with `flutter_pcm_sound`.
class InMemoryVoiceRecorder implements VoiceRecorder {
  InMemoryVoiceRecorder({this.maxLength = const Duration(seconds: 15)});

  static const int sampleRate = 16000;

  /// Recording stops on its own after this long.
  final Duration maxLength;

  final AudioRecorder _recorder = AudioRecorder();
  final BytesBuilder _pending = BytesBuilder(copy: false);
  StreamSubscription<Uint8List>? _sub;
  Timer? _limit;
  Uint8List? _kept;
  Timer? _playEnd;

  @override
  bool get hasRecording => _kept != null && _kept!.lengthInBytes > 1;

  @override
  Future<bool> start() async {
    try {
      if (!await _recorder.hasPermission()) return false;
      await _stopPlayback();
      _pending.clear();
      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: sampleRate,
        numChannels: 1,
      ));
      _sub = stream.listen(_pending.add);
      _limit = Timer(maxLength, stop);
      return true;
    } catch (e) {
      debugPrint('[VoiceRecorder] mic not available: $e');
      return false;
    }
  }

  @override
  Future<void> stop() async {
    _limit?.cancel();
    _limit = null;
    try {
      await _recorder.stop();
    } catch (_) {}
    await _sub?.cancel();
    _sub = null;
    final bytes = _pending.takeBytes();
    if (bytes.lengthInBytes > 1) _kept = bytes;
  }

  @override
  Future<void> play() async {
    var bytes = _kept;
    if (bytes == null) return;
    // An Int16 view needs an even start offset.
    if (bytes.offsetInBytes.isOdd) bytes = Uint8List.fromList(bytes);
    try {
      await _stopPlayback();
      // Little-endian 16-bit samples, as the recorder delivers them.
      final samples = bytes.buffer.asInt16List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 2);
      await FlutterPcmSound.setup(sampleRate: sampleRate, channelCount: 1);
      FlutterPcmSound.setFeedCallback((_) {});
      await FlutterPcmSound.feed(PcmArrayInt16.fromList(samples));
      FlutterPcmSound.start();
      final length = Duration(microseconds: samples.length * 1000000 ~/ sampleRate);
      _playEnd = Timer(length + const Duration(milliseconds: 300), _stopPlayback);
    } catch (e) {
      debugPrint('[VoiceRecorder] could not play back: $e');
    }
  }

  Future<void> _stopPlayback() async {
    if (_playEnd == null) return;
    _playEnd?.cancel();
    _playEnd = null;
    try {
      await FlutterPcmSound.release();
    } catch (_) {}
  }

  @override
  Future<void> clear() async {
    await _stopPlayback();
    _pending.clear();
    _kept = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await clear();
    try {
      await _recorder.dispose();
    } catch (_) {}
  }
}
