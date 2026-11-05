import 'dart:async';

import 'package:flutter/foundation.dart';

/// The 30 s countdown on timed questions (§4). It ticks once a second, can
/// be paused (Leave pop-up, feedback sheets) and calls [onTimeout] once at 0.
class QuizTimer extends ChangeNotifier {
  QuizTimer({required this.seconds, required this.onTimeout});

  final int seconds;
  final VoidCallback onTimeout;

  late int _left = seconds;
  Timer? _ticker;
  int _pauses = 0;
  bool _stopped = false;

  /// Whole seconds left.
  int get secondsLeft => _left;

  bool get isPaused => _pauses > 0;
  bool get isRunning => _ticker != null && !isPaused && !_stopped;

  /// "00:30" style, for the timer chip.
  String get label {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void start() {
    if (_ticker != null || _stopped) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Pauses until the matching [resume]. Pauses nest: a sheet over the
  /// Leave pop-up keeps the timer paused until both are closed.
  void pause() => _pauses++;

  void resume() {
    if (_pauses > 0) _pauses--;
  }

  /// Stops for good (the question was answered).
  void stop() {
    _stopped = true;
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    if (isPaused || _stopped) return;
    _left--;
    notifyListeners();
    if (_left <= 0) {
      stop();
      onTimeout();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
