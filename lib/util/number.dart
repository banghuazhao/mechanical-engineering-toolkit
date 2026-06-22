import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'others.dart';

String doubleToString(double n, {int keepDecimal = 2}) {
  return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : keepDecimal);
}

enum NumberDisplayFormat { auto, scientific, decimal, engineering }

extension NumberDisplayFormatLabel on NumberDisplayFormat {
  String get label {
    switch (this) {
      case NumberDisplayFormat.auto:
        return 'Auto';
      case NumberDisplayFormat.scientific:
        return 'Scientific';
      case NumberDisplayFormat.decimal:
        return 'Decimal';
      case NumberDisplayFormat.engineering:
        return 'Engineering';
    }
  }

  String example(int precision) {
    const value = 12345.6789;
    switch (this) {
      case NumberDisplayFormat.auto:
        return '${value.toStringAsFixed(precision)} / 1.235e+9';
      case NumberDisplayFormat.scientific:
        return value.toStringAsExponential(precision);
      case NumberDisplayFormat.decimal:
        return value.toStringAsFixed(precision);
      case NumberDisplayFormat.engineering:
        return _engNotation(value, precision);
    }
  }
}

String _engNotation(double value, int precision) {
  if (value == 0) return '0';
  final isNegative = value < 0;
  final abs = value.abs();
  final rawExp = (math.log(abs) / math.ln10).floor();
  final engExp = (rawExp ~/ 3) * 3;
  final mantissa = abs / math.pow(10, engExp);
  final sign = isNegative ? '-' : '';
  final mantissaStr = mantissa.toStringAsFixed(precision);
  if (engExp == 0) return '$sign$mantissaStr';
  const sup = {'-': '⁻', '0': '⁰', '1': '¹', '2': '²', '3': '³', '4': '⁴', '5': '⁵', '6': '⁶', '7': '⁷', '8': '⁸', '9': '⁹'};
  final expStr = engExp.toString().split('').map((c) => sup[c] ?? c).join();
  return '$sign$mantissaStr ×10$expStr';
}

class NumberPrecisionHelper extends ChangeNotifier {
  static const String _precisionKey = "Number_Precision";
  static const String _formatKey = "Number_Format";

  int get precision {
    return SharedPreferencesHelper.localStorage.getInt(_precisionKey) ?? 3;
  }

  NumberDisplayFormat get displayFormat {
    final index = SharedPreferencesHelper.localStorage.getInt(_formatKey) ?? 0;
    return NumberDisplayFormat.values[index.clamp(0, NumberDisplayFormat.values.length - 1)];
  }

  void set(int precision) {
    SharedPreferencesHelper.localStorage.setInt(_precisionKey, precision);
    notifyListeners();
  }

  void setFormat(NumberDisplayFormat format) {
    SharedPreferencesHelper.localStorage.setInt(_formatKey, format.index);
    notifyListeners();
  }

  String formatValue(double? value) {
    if (value == null) return '';
    if (value == 0) return '0';

    switch (displayFormat) {
      case NumberDisplayFormat.scientific:
        return value.toStringAsExponential(precision);

      case NumberDisplayFormat.decimal:
        return value.toStringAsFixed(precision);

      case NumberDisplayFormat.auto:
        final abs = value.abs();
        if (abs >= 0.001 && abs < 1e6) {
          return value.toStringAsFixed(precision);
        }
        return value.toStringAsExponential(precision);

      case NumberDisplayFormat.engineering:
        return _engNotation(value, precision);
    }
  }
}

extension DoubleFormat on double {
  String formatted(NumberPrecisionHelper precs) => precs.formatValue(this);
}
