import 'package:flutter/material.dart';

import 'others.dart';

/// The appearance choices offered in Settings. [AppThemeMode.system] hands the
/// choice back to the device, which is what the app did unconditionally before
/// this preference existed.
enum AppThemeMode {
  system(ThemeMode.system),
  light(ThemeMode.light),
  dark(ThemeMode.dark);

  const AppThemeMode(this.themeMode);

  final ThemeMode themeMode;
}

class ThemePreference extends ChangeNotifier {
  static const String _key = "App_Theme_Mode";

  AppThemeMode get appThemeMode {
    final raw = SharedPreferencesHelper.localStorage.getString(_key);
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == raw,
      orElse: () => AppThemeMode.system,
    );
  }

  ThemeMode get themeMode => appThemeMode.themeMode;

  void set(AppThemeMode mode) {
    SharedPreferencesHelper.localStorage.setString(_key, mode.name);
    notifyListeners();
  }
}
