import 'package:flutter/material.dart';

import 'others.dart';

enum UnitSystem { si, imperial }

class UnitSystemPreference extends ChangeNotifier {
  static const String _key = "Unit_System";

  UnitSystem get system {
    final raw = SharedPreferencesHelper.localStorage.getString(_key);
    return raw == 'imperial' ? UnitSystem.imperial : UnitSystem.si;
  }

  void set(UnitSystem system) {
    SharedPreferencesHelper.localStorage
        .setString(_key, system == UnitSystem.imperial ? 'imperial' : 'si');
    notifyListeners();
  }
}
