// GENERATED FILE — DO NOT EDIT.
//
// Written by tool/gen_swift_units.dart from
// lib/util/converter_catalog.dart, which is the one place a
// unit or a conversion factor should ever be changed. Run
// `dart run tool/gen_swift_units.dart` after editing it;
// test/swift_units_sync_test.dart fails until you do.
//
// Each unit converts to its category's base unit as
// `base = value * factor + offset`.

extension METoolkitUnitCategory {
  /// Every category the Unit Converter offers, in the order
  /// the app draws its chips.
  static let catalog: [METoolkitUnitCategory] = [
    METoolkitUnitCategory(
      id: "length",
      name: "Length",
      baseLabel: "m",
      units: [
        METoolkitUnit(label: "mm", factor: 0.001),
        METoolkitUnit(label: "cm", factor: 0.01),
        METoolkitUnit(label: "m", factor: 1.0),
        METoolkitUnit(label: "km", factor: 1000.0),
        METoolkitUnit(label: "in", factor: 0.0254),
        METoolkitUnit(label: "ft", factor: 0.3048),
        METoolkitUnit(label: "yd", factor: 0.9144),
        METoolkitUnit(label: "mi", factor: 1609.344),
      ]),
    METoolkitUnitCategory(
      id: "force",
      name: "Force",
      baseLabel: "N",
      units: [
        METoolkitUnit(label: "N", factor: 1.0),
        METoolkitUnit(label: "kN", factor: 1000.0),
        METoolkitUnit(label: "MN", factor: 1000000.0),
        METoolkitUnit(label: "lbf", factor: 4.44822),
        METoolkitUnit(label: "kip", factor: 4448.22),
      ]),
    METoolkitUnitCategory(
      id: "pressure",
      name: "Stress / Pressure",
      baseLabel: "Pa",
      units: [
        METoolkitUnit(label: "Pa", factor: 1.0),
        METoolkitUnit(label: "kPa", factor: 1000.0),
        METoolkitUnit(label: "MPa", factor: 1000000.0),
        METoolkitUnit(label: "GPa", factor: 1000000000.0),
        METoolkitUnit(label: "psi", factor: 6894.76),
        METoolkitUnit(label: "ksi", factor: 6894760.0),
        METoolkitUnit(label: "atm", factor: 101325.0),
        METoolkitUnit(label: "bar", factor: 100000.0),
      ]),
    METoolkitUnitCategory(
      id: "mass",
      name: "Mass",
      baseLabel: "kg",
      units: [
        METoolkitUnit(label: "g", factor: 0.001),
        METoolkitUnit(label: "kg", factor: 1.0),
        METoolkitUnit(label: "tonne", factor: 1000.0),
        METoolkitUnit(label: "oz", factor: 0.0283495),
        METoolkitUnit(label: "lb", factor: 0.453592),
        METoolkitUnit(label: "slug", factor: 14.5939),
      ]),
    METoolkitUnitCategory(
      id: "temperature",
      name: "Temperature",
      baseLabel: "°C",
      units: [
        METoolkitUnit(label: "°C", factor: 1.0),
        METoolkitUnit(label: "°F", factor: 0.5555555555555556, offset: -17.77777777777778),
        METoolkitUnit(label: "K", factor: 1.0, offset: -273.15),
      ]),
    METoolkitUnitCategory(
      id: "torque",
      name: "Torque",
      baseLabel: "N·m",
      units: [
        METoolkitUnit(label: "N·m", factor: 1.0),
        METoolkitUnit(label: "kN·m", factor: 1000.0),
        METoolkitUnit(label: "lbf·ft", factor: 1.35582),
        METoolkitUnit(label: "lbf·in", factor: 0.112985),
      ]),
    METoolkitUnitCategory(
      id: "power",
      name: "Power",
      baseLabel: "W",
      units: [
        METoolkitUnit(label: "W", factor: 1.0),
        METoolkitUnit(label: "kW", factor: 1000.0),
        METoolkitUnit(label: "MW", factor: 1000000.0),
        METoolkitUnit(label: "hp", factor: 745.7),
      ]),
    METoolkitUnitCategory(
      id: "angularVelocity",
      name: "Angular Velocity",
      baseLabel: "rad/s",
      units: [
        METoolkitUnit(label: "rad/s", factor: 1.0),
        METoolkitUnit(label: "rpm", factor: 0.10471975511965977),
        METoolkitUnit(label: "deg/s", factor: 0.017453292519943295),
      ]),
    METoolkitUnitCategory(
      id: "angle",
      name: "Angle",
      baseLabel: "rad",
      units: [
        METoolkitUnit(label: "rad", factor: 1.0),
        METoolkitUnit(label: "deg", factor: 0.017453292519943295),
      ]),
  ]
}
