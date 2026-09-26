import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static final LocaleService _instance = LocaleService._internal();

  factory LocaleService() => _instance;

  LocaleService._internal();

  static const String _localeKey = 'selected_locale';
  Locale? _locale;

  Locale? get locale => _locale;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      await prefs.setString(_localeKey, locale.languageCode);
    }
    notifyListeners();
  }

  /// Converts the backend's string value ("default"/"fa"/"en") to a
  /// Flutter Locale. "default" means the user hasn't explicitly chosen a
  /// language yet - i.e. follow the system locale, represented here as
  /// Locale? == null.
  static Locale? localeFromBackend(String? value) {
    if (value == 'fa' || value == 'en') return Locale(value!);
    return null;
  }

  /// Converts a Flutter Locale to the string value expected by the backend.
  static String localeToBackend(Locale? locale) => locale?.languageCode ?? 'default';
}
