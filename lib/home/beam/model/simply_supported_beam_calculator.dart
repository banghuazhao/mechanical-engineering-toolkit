import 'dart:math';

class BeamAnalysisInput {
  const BeamAnalysisInput({
    required this.span,
    required this.pointLoad,
    required this.pointPosition,
    required this.distributedLoad,
    required this.elasticModulus,
    required this.secondMoment,
  });

  final double span;
  final double pointLoad;
  final double pointPosition;
  final double distributedLoad;
  final double elasticModulus;
  final double secondMoment;
}

class BeamDiagramPoint {
  const BeamDiagramPoint(this.x, this.value);
  final double x;
  final double value;
}

class BeamAnalysisResult {
  const BeamAnalysisResult({
    required this.leftReaction,
    required this.rightReaction,
    required this.maximumMoment,
    required this.maximumMomentPosition,
    required this.maximumDeflection,
    required this.maximumDeflectionPosition,
    required this.shear,
    required this.moment,
    required this.deflection,
  });

  final double leftReaction;
  final double rightReaction;
  final double maximumMoment;
  final double maximumMomentPosition;
  final double maximumDeflection;
  final double maximumDeflectionPosition;
  final List<BeamDiagramPoint> shear;
  final List<BeamDiagramPoint> moment;
  final List<BeamDiagramPoint> deflection;
}

abstract final class SimplySupportedBeamCalculator {
  static BeamAnalysisResult calculate(BeamAnalysisInput input) {
    if (input.span <= 0) {
      throw const FormatException('Span must be greater than zero.');
    }
    if (input.pointLoad < 0 || input.distributedLoad < 0) {
      throw const FormatException('Loads cannot be negative.');
    }
    if (input.pointLoad == 0 && input.distributedLoad == 0) {
      throw const FormatException('Enter at least one load.');
    }
    if (input.pointPosition < 0 || input.pointPosition > input.span) {
      throw const FormatException(
          'Point-load position must be within the span.');
    }
    if (input.elasticModulus <= 0 || input.secondMoment <= 0) {
      throw const FormatException(
          'Elastic modulus and second moment must be positive.');
    }

    final span = input.span;
    final point = input.pointLoad;
    final a = input.pointPosition;
    final b = span - a;
    final udl = input.distributedLoad;
    final leftReaction = point * b / span + udl * span / 2;
    final rightReaction = point * a / span + udl * span / 2;
    final ei = input.elasticModulus * 1e9 * input.secondMoment * 1e-12;
    final shear = <BeamDiagramPoint>[];
    final moment = <BeamDiagramPoint>[];
    final deflection = <BeamDiagramPoint>[];
    var maximumMoment = 0.0;
    var maximumMomentPosition = 0.0;
    var maximumDeflection = 0.0;
    var maximumDeflectionPosition = 0.0;

    for (var index = 0; index <= 200; index++) {
      final x = span * index / 200;
      final afterPoint = x >= a;
      final shearValue = leftReaction - udl * x - (afterPoint ? point : 0);
      final momentValue = leftReaction * x -
          udl * x * x / 2 -
          (afterPoint ? point * (x - a) : 0);
      final udlDeflection = udl *
          1000 *
          x *
          (pow(span, 3) - 2 * span * x * x + pow(x, 3)) /
          (24 * ei);
      final pointDeflection = point == 0
          ? 0.0
          : x <= a
              ? point *
                  1000 *
                  b *
                  x *
                  (span * span - b * b - x * x) /
                  (6 * span * ei)
              : point *
                  1000 *
                  a *
                  (span - x) *
                  (span * span - a * a - pow(span - x, 2)) /
                  (6 * span * ei);
      final deflectionMm = (udlDeflection + pointDeflection) * 1000;
      shear.add(BeamDiagramPoint(x, shearValue));
      moment.add(BeamDiagramPoint(x, momentValue));
      deflection.add(BeamDiagramPoint(x, deflectionMm));
      if (momentValue.abs() > maximumMoment.abs()) {
        maximumMoment = momentValue;
        maximumMomentPosition = x;
      }
      if (deflectionMm.abs() > maximumDeflection.abs()) {
        maximumDeflection = deflectionMm;
        maximumDeflectionPosition = x;
      }
    }

    return BeamAnalysisResult(
      leftReaction: leftReaction,
      rightReaction: rightReaction,
      maximumMoment: maximumMoment,
      maximumMomentPosition: maximumMomentPosition,
      maximumDeflection: maximumDeflection,
      maximumDeflectionPosition: maximumDeflectionPosition,
      shear: List.unmodifiable(shear),
      moment: List.unmodifiable(moment),
      deflection: List.unmodifiable(deflection),
    );
  }
}
