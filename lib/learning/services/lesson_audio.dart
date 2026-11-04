import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Plays the recorded lesson clips (one per word and one per letter).
/// Lesson audio is always a recording, never the TTS voice (§1.4). Slow
/// audio is the same clip at 0.75×.
class LessonAudio {
  LessonAudio._();

  static final LessonAudio instance = LessonAudio._();

  static const double slowRate = 0.75;

  AudioPlayer? _player;

  /// Plays [assetPath] ("assets/audio/…"). Does nothing for null: the screens
  /// hide the button when a clip is missing, so this is only a safety net.
  Future<void> play(String? assetPath, {bool slow = false}) async {
    if (assetPath == null) return;
    try {
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.setPlaybackRate(slow ? slowRate : 1.0);
      // audioplayers wants the path inside assets/.
      await player.play(AssetSource(assetPath.replaceFirst('assets/', '')));
    } catch (e) {
      debugPrint('[LessonAudio] could not play $assetPath: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _player?.stop();
    } catch (_) {}
  }
}
