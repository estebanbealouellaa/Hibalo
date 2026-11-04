import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// The app language the user picked: English, Filipino or Hiligaynon
/// (`settings.uiLanguages` in lessons.json). It only changes the app's own
/// words. The picker (language pop-up, Me › Language) is a later task; until
/// then the app stays in English unless the setting is changed in code or in
/// the debug menu on the Learn screen.
class AppLanguage extends ChangeNotifier {
  AppLanguage._();

  static final AppLanguage instance = AppLanguage._();

  static const _prefsKey = 'app_language';

  /// Language name (as in lessons.json) → locale.
  static const Map<String, Locale> locales = {
    'English': Locale('en'),
    'Filipino': Locale('fil'),
    'Hiligaynon': Locale('hil'),
  };

  String _language = 'English';

  String get language => _language;
  Locale get locale => locales[_language]!;

  /// Reads the saved choice. Safe to skip: English is the default.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && locales.containsKey(saved) && saved != _language) {
        _language = saved;
        notifyListeners();
      }
    } catch (_) {
      // Keep English if the setting can't be read.
    }
  }

  Future<void> setLanguage(String language) async {
    if (!locales.containsKey(language) || language == _language) return;
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, language);
  }

  /// Everything MaterialApp needs for the app strings. Flutter has no
  /// Hiligaynon translations of its own buttons and dialogs, so for "hil" the
  /// three fallback delegates give it the English ones.
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
