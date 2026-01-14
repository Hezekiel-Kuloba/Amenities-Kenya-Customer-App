import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _themeKey = 'theme';
  static const _fontSizeKey = 'font_size';

  Future<void> setHasSeenOnboarding(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, value);
  }

  Future<bool> getHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }
 

  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> setTheme(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 16.0;
  }

  Future<void> setFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
  }
}

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});