// Emits the Swift copy of the Unit Converter's catalogue.
//
// The Shortcuts "Convert Unit" action runs in the App Intents extension
// process, with no Flutter engine and no Dart, so it needs the conversion
// table in Swift. Rather than keep a second hand-maintained copy — which
// would drift the first time a unit was added on one side only — this script
// imports `lib/util/converter_catalog.dart` and writes the table out.
//
// Run it after changing the catalogue:
//
//   dart run tool/gen_swift_units.dart
//
// `test/swift_units_sync_test.dart` fails until the committed file matches
// what this script would write, so a forgotten run is caught by `flutter
// test` rather than by a Shortcut quietly converting with a stale factor.

import 'dart:io';

import 'package:mechanical_engineering_toolkit/util/converter_catalog.dart';

/// Where the generated file lives, relative to the repository root. It sits
/// under `apple/`, which both the iOS and the macOS Xcode project compile
/// from — one copy, two platforms.
const generatedPath = 'apple/METoolkitShared/UnitCatalog.generated.swift';

/// Renders [value] as a Swift `Double` literal that round-trips exactly.
///
/// `toString()` on a Dart double already gives the shortest representation
/// that parses back to the same bits, and Swift's Double literal parser has
/// the same guarantee, so the two agree. Integral values print as "1.0"
/// rather than "1" to keep them unambiguously Double in Swift.
String _swiftDouble(double value) {
  final text = value.toString();
  if (text.contains('.') || text.contains('e') || text.contains('E')) {
    return text;
  }
  return '$text.0';
}

String _swiftString(String value) {
  final escaped = value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  return '"$escaped"';
}

String generateSwiftUnits() {
  final out = StringBuffer();
  out.writeln('// GENERATED FILE — DO NOT EDIT.');
  out.writeln('//');
  out.writeln('// Written by tool/gen_swift_units.dart from');
  out.writeln('// lib/util/converter_catalog.dart, which is the one place a');
  out.writeln('// unit or a conversion factor should ever be changed. Run');
  out.writeln('// `dart run tool/gen_swift_units.dart` after editing it;');
  out.writeln('// test/swift_units_sync_test.dart fails until you do.');
  out.writeln('//');
  out.writeln('// Each unit converts to its category\'s base unit as');
  out.writeln('// `base = value * factor + offset`.');
  out.writeln();
  out.writeln('extension METoolkitUnitCategory {');
  out.writeln('  /// Every category the Unit Converter offers, in the order');
  out.writeln('  /// the app draws its chips.');
  out.writeln('  static let catalog: [METoolkitUnitCategory] = [');
  for (final category in converterCategories) {
    out.writeln('    METoolkitUnitCategory(');
    out.writeln('      id: ${_swiftString(category.id)},');
    out.writeln('      name: ${_swiftString(category.name)},');
    out.writeln('      baseLabel: ${_swiftString(category.baseLabel)},');
    out.writeln('      units: [');
    for (final unit in category.units) {
      final label = _swiftString(unit.label);
      final factor = _swiftDouble(unit.factor);
      if (unit.offset == 0) {
        out.writeln('        METoolkitUnit(label: $label, factor: $factor),');
      } else {
        out.writeln('        METoolkitUnit(label: $label, factor: $factor, '
            'offset: ${_swiftDouble(unit.offset)}),');
      }
    }
    out.writeln('      ]),');
  }
  out.writeln('  ]');
  out.writeln('}');
  return out.toString();
}

void main(List<String> args) {
  final file = File(generatedPath);
  if (!file.parent.existsSync()) {
    stderr.writeln('No ${file.parent.path} directory — run this from the '
        'repository root.');
    exitCode = 1;
    return;
  }
  file.writeAsStringSync(generateSwiftUnits());
  stdout.writeln('Wrote $generatedPath');
}
