import 'package:flutter/material.dart';

import 'others.dart';

/// The languages offered in the drawer's language picker. [AppLanguage.system]
/// hands the choice back to the device locale.
enum AppLanguage {
  system(null),
  english(Locale('en')),
  simplifiedChinese(Locale('zh')),
  traditionalChinese(Locale('zh', 'HK'));

  const AppLanguage(this.locale);

  final Locale? locale;

  /// Endonym of the language, deliberately not translated: a picker is only
  /// useful when every entry is readable in its own language.
  String get nativeName {
    switch (this) {
      case AppLanguage.system:
        return 'System';
      case AppLanguage.english:
        return 'English';
      case AppLanguage.simplifiedChinese:
        return '简体中文';
      case AppLanguage.traditionalChinese:
        return '繁體中文';
    }
  }
}

class LanguagePreference extends ChangeNotifier {
  static const String _key = "App_Language";

  AppLanguage get language {
    final raw = SharedPreferencesHelper.localStorage.getString(_key);
    return AppLanguage.values.firstWhere(
      (language) => language.name == raw,
      orElse: () => AppLanguage.system,
    );
  }

  /// `null` lets [MaterialApp] resolve the locale from the device.
  Locale? get locale => language.locale;

  void set(AppLanguage language) {
    SharedPreferencesHelper.localStorage.setString(_key, language.name);
    notifyListeners();
  }
}
