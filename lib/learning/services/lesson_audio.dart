import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays the recorded lesson clips (one per word and one per letter).
/// Lesson audio is always a recording, never the TTS voice (§1.4). Slow
/// audio is the same clip at 0.75×.
class LessonAudio {
  LessonAudio._();

  static final LessonAudio instance = LessonAudio._();

  static const double slowRate = 0.75;

  AudioPlayer? _player;
  Set<String>? _bundled;

  /// Plays [assetPath] ("assets/audio/…"). The audio buttons always show, so
  /// a clip that isn't in the app yet (or null) just plays nothing (§1.4).
  Future<void> play(String? assetPath, {bool slow = false}) async {
    if (assetPath == null) return;
    try {
      _bundled ??= (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets().toSet();
      if (!_bundled!.contains(assetPath)) return; // not recorded yet
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
