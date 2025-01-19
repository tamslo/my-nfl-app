import 'package:flutter/material.dart';
import 'package:my_nfl_app/src/settings/selectable_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectableThemes = [
  SelectableTheme(
    mode: ThemeMode.system,
    displayString: 'System Theme',
    storageKey: 'system',
  ),
  SelectableTheme(
    mode: ThemeMode.light,
    displayString: 'Light Theme',
    storageKey: 'light',
  ),
  SelectableTheme(
    mode: ThemeMode.dark,
    displayString: 'Dark Theme',
    storageKey: 'dark',
  ),
];

class SettingsService {
  final String _themeModeKey = 'themeMode';
  Future<ThemeMode> themeMode() async {
    final sharedPreferences = SharedPreferencesAsync();
    final storedThemeMode = await sharedPreferences.getString(_themeModeKey);
    final userThemeMode = storedThemeMode ?? selectableThemes.first.storageKey;
    return selectableThemes.where(
      (selectableTheme) => selectableTheme.storageKey == userThemeMode
    ).first.mode;
  }

  /// Persists the user's preferred ThemeMode to local or remote storage.
  Future<void> updateThemeMode(ThemeMode theme) async {
    // Use the shared_preferences package to persist settings locally or the
    // http package to persist settings over the network.
    final sharedPreferences = SharedPreferencesAsync();
    final selectedThemeKey = selectableThemes.where(
      (selectableTheme) => selectableTheme.mode == theme
    ).first.storageKey;
    await sharedPreferences.setString(_themeModeKey, selectedThemeKey);
  }
}
