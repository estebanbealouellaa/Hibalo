import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/progress.dart';

/// Saves learning progress on the phone (SharedPreferences, one JSON value).
/// The app works offline, so this is the main copy; Firestore sync comes on
/// top of it in step 5.
class ProgressStore {
  static const _key = 'learning_progress_v1';

  /// Keys written by the old learning module (removed in step 2). Its
  /// progress is reset, not moved over, so these are deleted once.
  static const _oldKeys = ['hili_xp', 'hili_streak', 'hili_last_day', 'hili_claimed'];
  static const _oldKeyPrefix = 'lesson_sections_done_';

  Future<ProgressSnapshot> load() async {
    final prefs = await SharedPreferences.getInstance();
    await _removeOldModule(prefs);
    final text = prefs.getString(_key);
    if (text == null) return ProgressSnapshot();
    try {
      final json = jsonDecode(text);
      if (json is Map<String, dynamic>) return ProgressSnapshot.fromJson(json);
    } on FormatException {
      // A damaged value: start fresh rather than crash.
    }
    return ProgressSnapshot();
  }

  Future<void> save(ProgressSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(snapshot.toJson()));
  }

  Future<void> _removeOldModule(SharedPreferences prefs) async {
    for (final key in prefs.getKeys().toList()) {
      if (_oldKeys.contains(key) || key.startsWith(_oldKeyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
