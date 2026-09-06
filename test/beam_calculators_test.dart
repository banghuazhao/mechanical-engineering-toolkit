import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';

void main() {
  group('BeamSectionCalculator', () {
    test('calculates a rectangular section', () {
      final result = BeamSectionCalculator.calculate(const BeamSectionInput(
        type: BeamSectionType.rectangle,
        width: 100,
        height: 200,
      ));

      expect(result.area, 20000);
      expect(result.ix, closeTo(66666666.6667, 0.001));
      expect(result.iy, closeTo(16666666.6667, 0.001));
      expect(result.zx, closeTo(666666.6667, 0.001));
    });

    test('subtracts the void in a hollow rectangle', () {
      final result = BeamSectionCalculator.calculate(const BeamSectionInput(
        type: BeamSectionType.hollowRectangle,
        width: 100,
        height: 200,
        wallThickness: 10,
      ));

      expect(result.area, 5600);
      expect(result.ix, closeTo(27786666.6667, 0.001));
    });

    test('rejects impossible section dimensions', () {
      expect(
        () => BeamSectionCalculator.calculate(const BeamSectionInput(
          type: BeamSectionType.hollowCircle,
          width: 20,
          height: 20,
          wallThickness: 10,
        )),
        throwsFormatException,
      );
    });
  });
}
