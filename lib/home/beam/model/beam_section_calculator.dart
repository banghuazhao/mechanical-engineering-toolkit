import 'dart:math';

enum BeamSectionType {
  rectangle,
  hollowRectangle,
  circle,
  hollowCircle,
  iSection,
}

class BeamSectionInput {
  const BeamSectionInput({
    required this.type,
    required this.width,
    required this.height,
    this.wallThickness = 0,
    this.flangeThickness = 0,
    this.webThickness = 0,
  });

  final BeamSectionType type;
  final double width;
  final double height;
  final double wallThickness;
  final double flangeThickness;
  final double webThickness;
}

class BeamSectionResult {
  const BeamSectionResult({
    required this.area,
    required this.ix,
    required this.iy,
    required this.zx,
    required this.zy,
    required this.polarMoment,
  });

  final double area;
  final double ix;
  final double iy;
  final double zx;
  final double zy;
  final double polarMoment;
}

abstract final class BeamSectionCalculator {
  static BeamSectionResult calculate(BeamSectionInput input) {
    if (input.width <= 0 || input.height <= 0) {
      throw const FormatException('Dimensions must be greater than zero.');
    }

    late double area;
    late double ix;
    late double iy;
    switch (input.type) {
      case BeamSectionType.rectangle:
        area = input.width * input.height;
        ix = input.width * pow(input.height, 3) / 12;
        iy = input.height * pow(input.width, 3) / 12;
      case BeamSectionType.hollowRectangle:
        final t = input.wallThickness;
        if (t <= 0 || 2 * t >= min(input.width, input.height)) {
          throw const FormatException(
            'Wall thickness must be positive and less than half the smallest dimension.',
          );
        }
        final innerWidth = input.width - 2 * t;
        final innerHeight = input.height - 2 * t;
        area = input.width * input.height - innerWidth * innerHeight;
        ix = (input.width * pow(input.height, 3) -
                innerWidth * pow(innerHeight, 3)) /
            12;
        iy = (input.height * pow(input.width, 3) -
                innerHeight * pow(innerWidth, 3)) /
            12;
      case BeamSectionType.circle:
        final diameter = input.width;
        area = pi * pow(diameter, 2) / 4;
        ix = pi * pow(diameter, 4) / 64;
        iy = ix;
      case BeamSectionType.hollowCircle:
        final outerDiameter = input.width;
        final t = input.wallThickness;
        if (t <= 0 || 2 * t >= outerDiameter) {
          throw const FormatException(
            'Wall thickness must be positive and less than the radius.',
          );
        }
        final innerDiameter = outerDiameter - 2 * t;
        area = pi * (pow(outerDiameter, 2) - pow(innerDiameter, 2)) / 4;
        ix = pi * (pow(outerDiameter, 4) - pow(innerDiameter, 4)) / 64;
        iy = ix;
      case BeamSectionType.iSection:
        final tf = input.flangeThickness;
        final tw = input.webThickness;
        if (tf <= 0 || tw <= 0 || 2 * tf >= input.height || tw > input.width) {
          throw const FormatException(
            'Flange/web thicknesses do not fit within the overall section.',
          );
        }
        final webHeight = input.height - 2 * tf;
        area = 2 * input.width * tf + tw * webHeight;
        final flangeOffset = (input.height - tf) / 2;
        ix = 2 *
                (input.width * pow(tf, 3) / 12 +
                    input.width * tf * pow(flangeOffset, 2)) +
            tw * pow(webHeight, 3) / 12;
        iy = 2 * tf * pow(input.width, 3) / 12 + webHeight * pow(tw, 3) / 12;
    }

    return BeamSectionResult(
      area: area,
      ix: ix,
      iy: iy,
      zx: ix / (input.height / 2),
      zy: iy / (input.width / 2),
      polarMoment: ix + iy,
    );
  }
}
