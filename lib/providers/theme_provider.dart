import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amenities_kenya/services/preferences_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier(ref.read(preferencesServiceProvider));
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final PreferencesService _preferencesService;

  ThemeNotifier(this._preferencesService) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeString = await _preferencesService.getTheme();
    state = _themeModeFromString(themeString);
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    await _preferencesService.setTheme(themeMode.toString());
  }

  ThemeMode _themeModeFromString(String? themeString) {
    switch (themeString) {
      case 'ThemeMode.light':
        return ThemeMode.light;
      case 'ThemeMode.dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}