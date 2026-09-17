import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/gen_swift_units.dart';

/// Guards the one place the app's unit table is duplicated.
///
/// The Shortcuts "Convert Unit" action runs in Swift with no Dart available,
/// so it needs the catalogue compiled in. Adding a unit to
/// `lib/util/converter_catalog.dart` and forgetting to re-run the generator
/// would leave the Shortcut converting against a stale table — silently,
/// since a missing unit simply would not appear in the picker. This fails
/// instead.
void main() {
  test('the generated Swift catalogue matches the Dart one', () {
    final file = File(generatedPath);
    expect(
      file.existsSync(),
      isTrue,
      reason: '$generatedPath is missing — run `dart run '
          'tool/gen_swift_units.dart`',
    );
    expect(
      file.readAsStringSync(),
      generateSwiftUnits(),
      reason: 'The catalogue has changed since $generatedPath was written. '
          'Run `dart run tool/gen_swift_units.dart` and commit the result.',
    );
  });
}
