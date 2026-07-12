import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';

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

  group('SimplySupportedBeamCalculator', () {
    test('calculates a centered point load', () {
      final result = SimplySupportedBeamCalculator.calculate(
        const BeamAnalysisInput(
          span: 4,
          pointLoad: 10,
          pointPosition: 2,
          distributedLoad: 0,
          elasticModulus: 200,
          secondMoment: 100000000,
        ),
      );

      expect(result.leftReaction, 5);
      expect(result.rightReaction, 5);
      expect(result.maximumMoment, closeTo(10, 1e-9));
      expect(result.maximumMomentPosition, closeTo(2, 1e-9));
      expect(result.maximumDeflection, closeTo(0.6666667, 0.0001));
    });

    test('calculates a full-span UDL', () {
      final result = SimplySupportedBeamCalculator.calculate(
        const BeamAnalysisInput(
          span: 4,
          pointLoad: 0,
          pointPosition: 0,
          distributedLoad: 5,
          elasticModulus: 200,
          secondMoment: 100000000,
        ),
      );

      expect(result.leftReaction, 10);
      expect(result.rightReaction, 10);
      expect(result.maximumMoment, closeTo(10, 1e-9));
      expect(result.maximumDeflection, closeTo(0.8333333, 0.0001));
    });

    test('rejects loads outside the beam span', () {
      expect(
        () => SimplySupportedBeamCalculator.calculate(
          const BeamAnalysisInput(
            span: 4,
            pointLoad: 10,
            pointPosition: 5,
            distributedLoad: 0,
            elasticModulus: 200,
            secondMoment: 100000000,
          ),
        ),
        throwsFormatException,
      );
    });
  });
}
