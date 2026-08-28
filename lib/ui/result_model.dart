import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// One labelled quantity on a result page.
///
/// This is the same shape [AppCopyableValue] already renders — a label plus
/// either a raw SI value with its [UnitCategory], or a pre-formatted string.
/// Declaring results as data rather than only as widgets means the on-screen
/// cards, the plain-text share, and the CSV export all read from one
/// description instead of each page hand-writing a second one.
///
/// Prefer [valueSI] + [category] over [value]: only then can an export honour
/// the reader's unit system and precision at export time, rather than freezing
/// whatever happened to be on screen.
class ResultValue {
  const ResultValue({
    required this.label,
    this.value,
    this.valueSI,
    this.category,
  }) : assert(value != null || valueSI != null,
            'Provide either value or valueSI');

  final String label;

  /// A pre-formatted display string. Ignored when [valueSI] is provided.
  ///
  /// Its unit, if any, is already baked into the text, so exports cannot
  /// separate it into a unit column or convert it.
  final String? value;

  /// The raw value in the app's SI display unit for [category].
  final double? valueSI;

  /// Unit category for [valueSI]. Null means dimensionless.
  final UnitCategory? category;

  /// The number as the reader should see it, without a unit suffix.
  String formattedValue(NumberPrecisionHelper precs, UnitSystem system) {
    final si = valueSI;
    if (si == null) return value!;
    final converted = category == null ? si : fromSI(si, category!, system);
    return precs.formatValue(converted);
  }

  /// The unit symbol for [system], or an empty string when the quantity is
  /// dimensionless or its value was supplied pre-formatted.
  String unit(UnitSystem system) {
    if (valueSI == null || category == null) return '';
    return unitLabel(category!, system);
  }

  /// Value and unit joined for a one-line rendering (share text, clipboard).
  String formatted(NumberPrecisionHelper precs, UnitSystem system) {
    final unitSymbol = unit(system);
    final number = formattedValue(precs, system);
    return unitSymbol.isEmpty ? number : '$number $unitSymbol';
  }
}

/// A titled group of [ResultValue]s — one card on screen, one block in an
/// export.
class ResultSection {
  const ResultSection({
    required this.title,
    required this.values,
    this.exportOnly = false,
  });

  final String title;
  final List<ResultValue> values;

  /// Keeps the section out of the on-screen cards while still exporting it.
  ///
  /// For a page that draws these numbers its own way — as a bar chart, say —
  /// and would otherwise show them twice under the same heading. The values
  /// still reach the share text, the CSV, the PDF and a saved project, which
  /// is the point: a section is dropped from the layout, never from the data.
  final bool exportOnly;
}

/// Renders [sections] as the plain-text body used by the share action.
List<String> resultShareLines(
  List<ResultSection> sections,
  NumberPrecisionHelper precs,
  UnitSystem system,
) {
  final lines = <String>[];
  for (final section in sections) {
    if (lines.isNotEmpty) lines.add('');
    lines.add(section.title);
    for (final value in section.values) {
      lines.add('${value.label}: ${value.formatted(precs, system)}');
    }
  }
  return lines;
}
