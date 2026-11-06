import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How a translation's text was entered (the icon in History).
enum EntryInput { typed, voice, photo }

/// One translation in History or Saved.
class TranslationEntry {
  const TranslationEntry({
    required this.source,
    required this.translation,
    required this.fromHiligaynon,
    required this.input,
    required this.time,
  });

  final String source;
  final String translation;
  final bool fromHiligaynon;
  final EntryInput input;
  final DateTime time;

  /// Same text, translation and direction = the same entry (for Saved).
  String get key => '${fromHiligaynon ? 'hil' : 'fil'}|$source|$translation';

  String get fromLanguage => fromHiligaynon ? 'Hiligaynon' : 'Filipino';
  String get toLanguage => fromHiligaynon ? 'Filipino' : 'Hiligaynon';

  Map<String, Object> toJson() => {
    's': source,
    't': translation,
    'h': fromHiligaynon,
    'i': input.name,
    'at': time.millisecondsSinceEpoch,
  };

  static TranslationEntry? fromJson(Object? json) {
    if (json is! Map) return null;
    final source = json['s'], translation = json['t'], hil = json['h'], at = json['at'];
    if (source is! String || translation is! String || hil is! bool || at is! int) return null;
    return TranslationEntry(
      source: source,
      translation: translation,
      fromHiligaynon: hil,
      input: EntryInput.values.firstWhere((e) => e.name == json['i'], orElse: () => EntryInput.typed),
      time: DateTime.fromMillisecondsSinceEpoch(at),
    );
  }
}

/// What Share sends: both languages, one per line.
String shareText(TranslationEntry e) => '${e.fromLanguage}: ${e.source}\n${e.toLanguage}: ${e.translation}';

/// Translate History (the last [historyLimit]) and Saved words, kept ONLY on
/// this phone (shared preferences; nothing goes to Firebase). Uninstalling
/// the app or clearing them in Settings deletes them. Newest first.
class TranslationStore extends ChangeNotifier {
  TranslationStore._();

  static final TranslationStore instance = TranslationStore._();

  static const int historyLimit = 100;
  static const String historyKey = 'translate_history_v1';
  static const String savedKey = 'translate_saved_v1';

  final List<TranslationEntry> _history = [];
  final List<TranslationEntry> _saved = [];
  Future<void>? _loading;

  List<TranslationEntry> get history => List.unmodifiable(_history);
  List<TranslationEntry> get saved => List.unmodifiable(_saved);

  /// Reads both lists from the phone (once). Changes made before it
  /// finishes are kept (new ones first; a list cleared meanwhile stays empty).
  Future<void> load() => _loading ??= _load();

  bool _historyCleared = false;
  bool _savedCleared = false;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!_historyCleared) {
      for (final e in _decode(prefs.getString(historyKey))) {
        if (_history.length >= historyLimit) break;
        _history.add(e);
      }
    }
    if (!_savedCleared) {
      for (final e in _decode(prefs.getString(savedKey))) {
        if (!isSaved(e)) _saved.add(e);
      }
    }
    notifyListeners();
  }

  static List<TranslationEntry> _decode(String? raw) {
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return [for (final item in list) ?TranslationEntry.fromJson(item)];
    } catch (_) {
      return const [];
    }
  }

  /// Writes [key] after loading, so nothing on the phone is lost.
  Future<void> _write(String key) async {
    await load();
    final list = key == historyKey ? _history : _saved;
    final prefs = await SharedPreferences.getInstance();
    if (list.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode([for (final e in list) e.toJson()]));
    }
  }

  /// Adds a finished translation. An exact repeat of the newest one is
  /// skipped; only the last [historyLimit] are kept.
  Future<void> addToHistory(TranslationEntry entry) {
    if (entry.source.trim().isEmpty || entry.translation.trim().isEmpty) return Future.value();
    if (_history.isNotEmpty && _history.first.key == entry.key) return Future.value();
    _history.insert(0, entry);
    if (_history.length > historyLimit) _history.removeRange(historyLimit, _history.length);
    notifyListeners();
    return _write(historyKey);
  }

  bool isSaved(TranslationEntry entry) => _saved.any((e) => e.key == entry.key);

  /// Saves [entry], or removes it when it is already saved.
  Future<void> toggleSaved(TranslationEntry entry) {
    if (isSaved(entry)) {
      _saved.removeWhere((e) => e.key == entry.key);
    } else {
      _saved.insert(0, entry);
    }
    notifyListeners();
    return _write(savedKey);
  }

  Future<void> clearHistory() {
    _history.clear();
    _historyCleared = true;
    notifyListeners();
    return _write(historyKey);
  }

  Future<void> clearSaved() {
    _saved.clear();
    _savedCleared = true;
    notifyListeners();
    return _write(savedKey);
  }

  /// Tests: forget what was loaded.
  @visibleForTesting
  void resetForTest() {
    _history.clear();
    _saved.clear();
    _loading = null;
    _historyCleared = false;
    _savedCleared = false;
  }
}
