import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Plays recorded lesson clips (never the TTS voice); slow = the same clip at 0.75×.
class LessonAudio {
  LessonAudio._();

  static final LessonAudio instance = LessonAudio._();

  static const double slowRate = 0.75;

  AudioPlayer? _player;
  Set<String>? _bundled;

  /// Bumped by every play / playAll / stop, so an older playAll knows it was interrupted.
  int _generation = 0;

  /// Plays [assetPath] ("assets/audio/…"). Buttons are hidden for missing clips; still,
  /// a clip that isn't in the app yet (or null) just plays nothing (§1.4).
  Future<void> play(String? assetPath, {bool slow = false}) async {
    _generation++;
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

  /// Plays [clips] one after another (a whole conversation). Returns true when the last one
  /// finished, false if it was stopped or replaced by another play, or a clip is missing.
  Future<bool> playAll(List<String> clips, {bool slow = false}) async {
    final generation = ++_generation;
    if (clips.isEmpty) return false;
    try {
      _bundled ??= (await AssetManifest.loadFromAssetBundle(rootBundle)).listAssets().toSet();
      if (!clips.every(_bundled!.contains)) return false;
      final player = _player ??= AudioPlayer();
      for (final clip in clips) {
        if (generation != _generation) return false;
        await player.stop();
        await player.setPlaybackRate(slow ? slowRate : 1.0);
        final done = player.onPlayerComplete.first;
        await player.play(AssetSource(clip.replaceFirst('assets/', '')));
        // A stop() elsewhere never completes the clip, so give up after a minute.
        await done.timeout(const Duration(minutes: 1));
      }
      return generation == _generation;
    } catch (e) {
      debugPrint('[LessonAudio] could not play the conversation: $e');
      return false;
    }
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _player?.stop();
    } catch (_) {}
  }
}
