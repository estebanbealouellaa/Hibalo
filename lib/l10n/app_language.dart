import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// The app language (English, Filipino or Hiligaynon); it changes only the app's own words, never lesson content.
/// Saved per account; signed out (and an account with no choice yet) is English.
class AppLanguage extends ChangeNotifier {
  AppLanguage._();

  static final AppLanguage instance = AppLanguage._();

  static String prefsKeyFor(String uid) => 'app_language_$uid';

  /// Language name (as in lessons.json) → locale.
  static const Map<String, Locale> locales = {
    'English': Locale('en'),
    'Filipino': Locale('fil'),
    'Hiligaynon': Locale('hil'),
  };

  String _language = 'English';
  String? _uid;

  String get language => _language;
  Locale get locale => locales[_language]!;

  /// Switches to [uid]'s saved language (sign-in, app start); null (signed out) = English.
  Future<void> useAccount(String? uid) async {
    _uid = uid;
    var language = 'English';
    if (uid != null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final saved = prefs.getString(prefsKeyFor(uid));
        if (saved != null && locales.containsKey(saved)) language = saved;
      } catch (_) {
        // Keep English if the setting can't be read.
      }
    }
    if (uid != _uid) return;
    _show(language);
  }

  /// Changes the language now and saves it for the signed-in account.
  Future<void> setLanguage(String language) async {
    if (!locales.containsKey(language)) return;
    _show(language);
    final uid = _uid;
    if (uid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKeyFor(uid), language);
  }

  void _show(String language) {
    if (language == _language) return;
    _language = language;
    notifyListeners();
  }

  /// Flutter has no Hiligaynon strings for its own widgets, so "hil" falls back to English ones.
  static const List<LocalizationsDelegate<dynamic>> delegates = [
    AppLocalizations.delegate,
    _HilMaterialFallback(),
    _HilCupertinoFallback(),
    _HilWidgetsFallback(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = AppLocalizations.supportedLocales;
}

const _english = Locale('en');

bool _isHil(Locale locale) => locale.languageCode == 'hil';

class _HilMaterialFallback extends LocalizationsDelegate<MaterialLocalizations> {
  const _HilMaterialFallback();

  @override
  bool isSupported(Locale locale) => _isHil(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(_english);

  @override
  bool shouldReload(_HilMaterialFallback old) => false;
}

class _HilCupertinoFallback extends LocalizationsDelegate<CupertinoLocalizations> {
  const _HilCupertinoFallback();

  @override
  bool isSupported(Locale locale) => _isHil(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(_english);

  @override
  bool shouldReload(_HilCupertinoFallback old) => false;
}

class _HilWidgetsFallback extends LocalizationsDelegate<WidgetsLocalizations> {
  const _HilWidgetsFallback();

  @override
  bool isSupported(Locale locale) => _isHil(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(_english);

  @override
  bool shouldReload(_HilWidgetsFallback old) => false;
}
