import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// The rows of a linalg [Matrix], in the plain form [matrixSection] takes.
List<List<double>> matrixRows(Matrix matrix) =>
    [for (var row = 0; row < matrix.m; row++) matrix[row]];

/// Declares a composite result matrix as an exportable section.
///
/// The grid on screen carries its meaning through position alone, which does
/// not survive a CSV row or a PDF table, so each entry is labelled with its
/// 1-based row and column — `(2,3)`.
ResultSection matrixSection(String title, List<List<double>> matrix) {
  final values = <ResultValue>[];
  for (var row = 0; row < matrix.length; row++) {
    for (var col = 0; col < matrix[row].length; col++) {
      values.add(ResultValue(
        label: '(${row + 1},${col + 1})',
        valueSI: matrix[row][col],
      ));
    }
  }
  return ResultSection(title: title, values: values);
}

/// Declares the labelled constants an `EngineeringConstantsWidget` shows.
///
/// [categoryForKey] is the same lookup the widget takes, so the export
/// converts and labels exactly the entries the card does. Entries with no
/// value are left out rather than exported as a zero.
ResultSection constantsSection(
  String title,
  Map<String, double?> constants, {
  UnitCategory? Function(String key)? categoryForKey,
}) {
  return ResultSection(
    title: title,
    values: [
      for (final entry in constants.entries)
        if (entry.value != null)
          ResultValue(
            label: entry.key,
            valueSI: entry.value,
            category: categoryForKey?.call(entry.key),
          ),
    ],
  );
}
