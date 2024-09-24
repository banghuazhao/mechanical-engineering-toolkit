import 'package:flutter/material.dart';

import 'others.dart';

String doubleToString(double n, {int keepDecimal = 2}) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : keepDecimal);
}

class NumberPrecisionHelper extends ChangeNotifier {
  final String KEY = "Number_Precision";

  int get precision {
    int temp = SharedPreferencesHelper.localStorage.getInt(KEY) ?? 5;
    return temp;
  }

  set(int precision) {
    SharedPreferencesHelper.localStorage.setInt(KEY, precision);
    notifyListeners();
  }
}
