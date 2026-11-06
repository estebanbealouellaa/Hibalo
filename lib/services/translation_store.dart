import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How a translation's text was entered (the icon in History).
enum EntryInput { typed, voice, photo }

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

/// History (last [historyLimit]) and Saved, kept ONLY on this phone per account (never sent to Firebase); signed out = empty.
class TranslationStore extends ChangeNotifier {
  TranslationStore._();

  static final TranslationStore instance = TranslationStore._();

  static const int historyLimit = 100;
  static String historyKeyFor(String uid) => 'translate_history_v1_$uid';
  static String savedKeyFor(String uid) => 'translate_saved_v1_$uid';

  final List<TranslationEntry> _history = [];
  final List<TranslationEntry> _saved = [];
  Future<void>? _loading;
  String? _uid;

  String? get uid => _uid;

  List<TranslationEntry> get history => List.unmodifiable(_history);
  List<TranslationEntry> get saved => List.unmodifiable(_saved);

  bool _historyCleared = false;
  bool _savedCleared = false;

  /// Switches to [uid]'s lists (null on log out: nothing is shown).
  Future<void> setUser(String? uid) {
    if (uid == _uid) return load();
    _uid = uid;
    _history.clear();
    _saved.clear();
    _historyCleared = false;
    _savedCleared = false;
    _loading = null;
    notifyListeners();
    return load();
  }

  /// Reads the account's lists from the phone (once). Changes made before
  /// it finishes are kept (new ones first; a list cleared meanwhile stays
  /// empty).
  Future<void> load() {
    final uid = _uid;
    if (uid == null) return Future.value();
    return _loading ??= _load(uid);
  }

  Future<void> _load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    if (uid != _uid) return; // Switched account meanwhile.
    if (!_historyCleared) {
      for (final e in _decode(prefs.getString(historyKeyFor(uid)))) {
        if (_history.length >= historyLimit) break;
        _history.add(e);
      }
    }
    if (!_savedCleared) {
      for (final e in _decode(prefs.getString(savedKeyFor(uid)))) {
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

  /// Writes one list for the current account, after loading it, so nothing
  /// on the phone is lost.
  Future<void> _write({required bool history}) async {
    final uid = _uid;
    if (uid == null) return;
    await load();
    if (uid != _uid) return;
    final list = history ? _history : _saved;
    final key = history ? historyKeyFor(uid) : savedKeyFor(uid);
    final prefs = await SharedPreferences.getInstance();
    if (list.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, jsonEncode([for (final e in list) e.toJson()]));
    }
  }

  /// Adds a finished translation (an exact repeat of the newest is skipped); [replaceLatest] replaces the newest entry of the same text after a swap.
  Future<void> addToHistory(TranslationEntry entry, {bool replaceLatest = false}) {
    if (_uid == null) return Future.value();
    if (entry.source.trim().isEmpty || entry.translation.trim().isEmpty) return Future.value();
    if (_history.isNotEmpty && _history.first.key == entry.key) return Future.value();
    if (replaceLatest && _history.isNotEmpty && _history.first.source == entry.source) {
      _history.removeAt(0);
    }
    _history.insert(0, entry);
    if (_history.length > historyLimit) _history.removeRange(historyLimit, _history.length);
    notifyListeners();
    return _write(history: true);
  }

  bool isSaved(TranslationEntry entry) => _saved.any((e) => e.key == entry.key);

  Future<void> toggleSaved(TranslationEntry entry) {
    if (_uid == null) return Future.value();
    if (isSaved(entry)) {
      _saved.removeWhere((e) => e.key == entry.key);
    } else {
      _saved.insert(0, entry);
    }
    notifyListeners();
    return _write(history: false);
  }

  Future<void> clearHistory() {
    _history.clear();
    _historyCleared = true;
    notifyListeners();
    return _write(history: true);
  }

  Future<void> clearSaved() {
    _saved.clear();
    _savedCleared = true;
    notifyListeners();
    return _write(history: false);
  }

  /// Deletes [uid]'s History and Saved from the phone (Delete account), and
  /// hides them if that account is shown.
  Future<void> deleteUserData(String uid) async {
    if (_uid == uid) await setUser(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKeyFor(uid));
    await prefs.remove(savedKeyFor(uid));
  }

  /// Tests: forget the account and what was loaded.
  @visibleForTesting
  void resetForTest() {
    _history.clear();
    _saved.clear();
    _loading = null;
    _uid = null;
    _historyCleared = false;
    _savedCleared = false;
  }
}
