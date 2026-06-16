import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode _themeMode;
  bool _userOverride = false;

  ThemeProvider() {
    _themeMode = _timeBasedMode();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  /// AM (6:00–11:59) → light.  PM / night (12:00–5:59) → dark.
  ThemeMode _timeBasedMode() {
    final hour = DateTime.now().hour;
    return (hour >= 6 && hour < 12) ? ThemeMode.light : ThemeMode.dark;
  }

  /// Tap the toggle button → flip and lock until resetToAuto().
  void toggleTheme() {
    _userOverride = true;
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Called on app resume — re-applies time logic only if user hasn't overridden.
  void syncWithTime() {
    if (_userOverride) return;
    final auto = _timeBasedMode();
    if (auto != _themeMode) {
      _themeMode = auto;
      notifyListeners();
    }
  }

  /// Optional: restore automatic behaviour (e.g. from Settings screen).
  void resetToAuto() {
    _userOverride = false;
    _themeMode = _timeBasedMode();
    notifyListeners();
  }
}
