import Foundation

/// One unit within a category, converting to the category's base unit as
/// `base = value * factor + offset`.
///
/// The offset exists for the two temperature scales that do not share zero
/// with Celsius; it is zero for every other unit in the catalogue.
struct METoolkitUnit: Hashable, Sendable {
  let label: String
  let factor: Double
  let offset: Double

  init(label: String, factor: Double, offset: Double = 0) {
    self.label = label
    self.factor = factor
    self.offset = offset
  }

  func toBase(_ value: Double) -> Double { value * factor + offset }

  func fromBase(_ base: Double) -> Double { (base - offset) / factor }
}

/// A group of units that can be converted between one another.
///
/// The table itself is generated — see `UnitCatalog.generated.swift` and
/// `tool/gen_swift_units.dart`. Nothing here should be edited to add a unit;
/// edit `lib/util/converter_catalog.dart` and re-run the generator, so the
/// app and the Shortcuts action cannot disagree about a factor.
struct METoolkitUnitCategory: Hashable, Sendable, Identifiable {
  let id: String
  let name: String
  let baseLabel: String
  let units: [METoolkitUnit]

  func unit(labeled label: String) -> METoolkitUnit? {
    units.first { $0.label == label }
  }

  static func category(id: String) -> METoolkitUnitCategory? {
    catalog.first { $0.id == id }
  }

  /// Finds the category that owns a unit label, for the case where a caller
  /// knows only the units. Labels are unique across the catalogue today; if
  /// that ever stops being true the first match wins, which is why the
  /// Shortcuts action asks for a category rather than relying on this.
  static func category(containingUnitLabeled label: String) -> METoolkitUnitCategory? {
    catalog.first { $0.unit(labeled: label) != nil }
  }
}

enum METoolkitConversionError: Error {
  case unknownCategory(String)
  case unknownUnit(category: String, label: String)
}

/// Converts [value] between two units of the same category, via its base
/// unit. Mirrors `convertUnit` in `lib/util/converter_catalog.dart`.
func METoolkitConvert(
  value: Double,
  from: METoolkitUnit,
  to: METoolkitUnit
) -> Double {
  to.fromBase(from.toBase(value))
}

/// Formats a converted value the way the app's Unit Converter screen does.
///
/// A translation of `formatConverterValue` in
/// `lib/util/converter_catalog.dart`: plain decimal to eight places with
/// trailing zeros stripped, switching to exponential outside
/// [0.001, 1e6). Kept in step by `test/converter_catalog_test.dart`, which
/// pins the Dart side against the same table of values quoted below.
///
///     0        -> "0"
///     25.4     -> "25.4"
///     1234567  -> "1.234567e+6"
///     1e9      -> "1e+9"
///     0.0001   -> "1e-4"
func METoolkitFormat(_ value: Double) -> String {
  if value == 0 { return "0" }
  let magnitude = abs(value)
  if magnitude >= 1e6 || magnitude < 0.001 {
    return METoolkitExponential(value)
  }
  var text = String(format: "%.8f", value)
  if text.contains(".") {
    while text.hasSuffix("0") { text.removeLast() }
    if text.hasSuffix(".") { text.removeLast() }
  }
  return text
}

/// Dart's `toStringAsExponential(6)` with its trailing mantissa zeros
/// stripped.
///
/// `String(format: "%.6e")` pads the exponent to two digits — "1.234567e+06"
/// where Dart writes "1.234567e+6" — so the exponent is rebuilt here. Without
/// that the Shortcut and the app would print the same number differently.
private func METoolkitExponential(_ value: Double) -> String {
  let formatted = String(format: "%.6e", value)
  guard let separator = formatted.range(of: "e") else { return formatted }

  var mantissa = String(formatted[formatted.startIndex..<separator.lowerBound])
  while mantissa.hasSuffix("0") { mantissa.removeLast() }
  if mantissa.hasSuffix(".") { mantissa.removeLast() }

  var exponent = String(formatted[separator.upperBound...])
  let sign = exponent.hasPrefix("-") ? "-" : "+"
  if exponent.hasPrefix("-") || exponent.hasPrefix("+") {
    exponent.removeFirst()
  }
  while exponent.count > 1 && exponent.hasPrefix("0") { exponent.removeFirst() }

  return "\(mantissa)e\(sign)\(exponent)"
}
