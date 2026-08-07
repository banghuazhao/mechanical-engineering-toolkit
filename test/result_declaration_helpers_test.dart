import 'package:flutter_test/flutter_test.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/home/composite/composite_results.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// The helpers that let a page laying its own results out by hand still
/// declare them, which is what unlocks the CSV and PDF share formats.
void main() {
  group('matrixSection', () {
    test('labels every entry by its 1-based row and column', () {
      final section = matrixSection('A', [
        [1, 2],
        [3, 4],
      ]);

      expect(section.title, 'A');
      expect(section.values.map((v) => v.label),
          ['(1,1)', '(1,2)', '(2,1)', '(2,2)']);
      expect(section.values.map((v) => v.valueSI), [1, 2, 3, 4]);
    });

    test('matrixRows reads a linalg matrix row by row', () {
      final rows = matrixRows(Matrix([
        [1, 2, 3],
        [4, 5, 6],
      ]));

      expect(rows, [
        [1, 2, 3],
        [4, 5, 6],
      ]);
    });
  });

  group('constantsSection', () {
    test('applies the same unit lookup the card uses', () {
      final section = constantsSection(
        'Engineering constants',
        {'E1': 120, 'nu12': 0.3},
        categoryForKey: (key) =>
            key.startsWith('E') ? UnitCategory.modulus : null,
      );

      expect(section.values.first.category, UnitCategory.modulus);
      expect(section.values.last.category, isNull);
    });

    test('leaves out an entry with no value rather than exporting a zero', () {
      final section = constantsSection('Stress', {'σ11': 10.0, 'σ22': null});

      expect(section.values.map((v) => v.label), ['σ11']);
    });
  });

  group('multipleRowSection', () {
    test('pairs each title with its value and unit', () {
      final section = multipleRowSection(
        title: 'Moments of Inertia',
        resultTitles: const ['Ix', 'Iy'],
        resultValues: const [100.0, 200.0],
        resultUnits: const [
          UnitCategory.momentOfInertia,
          UnitCategory.momentOfInertia,
        ],
      );

      expect(section.values.map((v) => v.label), ['Ix', 'Iy']);
      expect(section.values.map((v) => v.valueSI), [100.0, 200.0]);
      expect(section.values.every((v) => v.category == UnitCategory.momentOfInertia),
          isTrue);
    });

    test('skips rows the tool did not compute', () {
      final section = multipleRowSection(
        title: 'Result Stress',
        resultTitles: const ['σ1', 'σ2'],
        resultValues: const [10.0, null],
      );

      expect(section.values.map((v) => v.label), ['σ1']);
    });

    test('tolerates fewer units than titles', () {
      final section = multipleRowSection(
        title: 'Mixed',
        resultTitles: const ['a', 'b'],
        resultValues: const [1.0, 2.0],
        resultUnits: const [UnitCategory.length],
      );

      expect(section.values[0].category, UnitCategory.length);
      expect(section.values[1].category, isNull);
    });
  });
}
