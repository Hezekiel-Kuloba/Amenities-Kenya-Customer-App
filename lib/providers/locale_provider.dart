import 'package:amenities_kenya/services/preferences_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider =
    StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref.read(preferencesServiceProvider));
});

class LocaleNotifier extends StateNotifier<Locale> {
  final PreferencesService _preferencesService;

  LocaleNotifier(this._preferencesService)
      : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode =
        await _preferencesService.getLanguageCode() ?? 'en';
    state = Locale(languageCode);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await _preferencesService.setLanguageCode(locale.languageCode);
  }
}

extension PreferencesServiceLocale on PreferencesService {
  static const _languageCodeKey = 'language_code';

  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  Future<void> setLanguageCode(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }
}