import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// The rolled shape families this library covers.
///
/// All three are doubly symmetric I-shapes, which is deliberate. The section
/// modulus of a shape is I/c, where c is the distance to the extreme fibre —
/// only equal to half the depth when the centroid sits at mid-depth. Channels
/// and angles do not, so tabulating them here would mean either carrying their
/// centroid offsets as a second set of remembered numbers or publishing a
/// wrong Zy. Neither is worth it while the Beam Section Properties tool
/// already computes tubes, pipes and bar exactly from their dimensions — the
/// shapes a table is not needed for. This library exists for the shapes you
/// *cannot* compute: rolled ones, whose root fillets put a few percent of
/// extra material where a bare-geometry formula cannot see it.
enum SectionFamily { wShape, ipe, heb }

extension SectionFamilyLabel on SectionFamily {
  String label(BuildContext context) => switch (this) {
        SectionFamily.wShape => S.of(context).Family_W,
        SectionFamily.ipe => S.of(context).Family_IPE,
        SectionFamily.heb => S.of(context).Family_HEB,
      };
}

/// One rolled shape, in the app's SI display units throughout.
///
/// Only the three independent properties a table publishes — area and the two
/// second moments — are stored. Section modulus and radius of gyration are
/// derived from them rather than listed alongside, so the two can never
/// disagree: a transcription slip in Z is impossible if there is no Z to
/// transcribe.
class StandardSection {
  const StandardSection._({
    required this.designation,
    required this.family,
    required this.depth,
    required this.width,
    required this.webThickness,
    required this.flangeThickness,
    required this.area,
    required this.ix,
    required this.iy,
  });

  /// As it appears on a drawing, e.g. `W12X40` or `IPE 300`.
  final String designation;

  final SectionFamily family;

  /// Overall depth d, mm.
  final double depth;

  /// Flange width bf, mm.
  final double width;

  /// Web thickness tw, mm.
  final double webThickness;

  /// Flange thickness tf, mm.
  final double flangeThickness;

  /// Cross-sectional area, mm².
  final double area;

  /// Second moment of area about the strong axis, mm⁴.
  final double ix;

  /// Second moment of area about the weak axis, mm⁴.
  final double iy;

  /// Elastic section modulus about x, mm³. Exact for these shapes: they are
  /// symmetric about x, so the extreme fibre is at d/2.
  double get zx => ix / (depth / 2);

  /// Elastic section modulus about y, mm³ — extreme fibre at bf/2.
  double get zy => iy / (width / 2);

  /// Radius of gyration about x, mm.
  double get rx => math.sqrt(ix / area);

  /// Radius of gyration about y, mm.
  double get ry => math.sqrt(iy / area);

  /// Reads an AISC row in its published units: inches, in², in⁴.
  ///
  /// Converting here rather than in the table below keeps every literal
  /// identical to the printed source, which is the only way to proofread it.
  factory StandardSection.imperial({
    required String designation,
    required SectionFamily family,
    required double depth,
    required double width,
    required double webThickness,
    required double flangeThickness,
    required double area,
    required double ix,
    required double iy,
  }) =>
      StandardSection._(
        designation: designation,
        family: family,
        depth: in2mm(depth),
        width: in2mm(width),
        webThickness: in2mm(webThickness),
        flangeThickness: in2mm(flangeThickness),
        area: in2_2_mm2(area),
        ix: in4_2_mm4(ix),
        iy: in4_2_mm4(iy),
      );

  /// Reads a European row in its published units: mm, cm², cm⁴.
  factory StandardSection.metric({
    required String designation,
    required SectionFamily family,
    required double depth,
    required double width,
    required double webThickness,
    required double flangeThickness,
    required double area,
    required double ix,
    required double iy,
  }) =>
      StandardSection._(
        designation: designation,
        family: family,
        depth: depth,
        width: width,
        webThickness: webThickness,
        flangeThickness: flangeThickness,
        area: area * 1e2,
        ix: ix * 1e4,
        iy: iy * 1e4,
      );
}

/// One row as it is printed in a shape table: the designation followed by
/// depth, flange width, web thickness, flange thickness, area and the two
/// second moments, in whatever units that table publishes.
typedef _Row = (String, double, double, double, double, double, double, double);

/// AISC wide-flange shapes, in inches / in² / in⁴ as published.
final List<StandardSection> _wShapes = [
  for (final row in const <_Row>[
    //          designation,  d,     bf,     tw,     tf,     A,     Ix,    Iy
    ('W4X13', 4.16, 4.060, 0.280, 0.345, 3.83, 11.3, 3.86),
    ('W6X9', 5.90, 3.940, 0.170, 0.215, 2.68, 16.4, 2.20),
    ('W6X15', 5.99, 5.990, 0.230, 0.260, 4.43, 29.1, 9.32),
    ('W6X20', 6.20, 6.020, 0.260, 0.365, 5.87, 41.4, 13.3),
    ('W8X10', 7.89, 3.940, 0.170, 0.205, 2.96, 30.8, 2.09),
    ('W8X18', 8.14, 5.250, 0.230, 0.330, 5.26, 61.9, 7.97),
    ('W8X31', 8.00, 7.995, 0.285, 0.435, 9.13, 110, 37.1),
    ('W8X40', 8.25, 8.070, 0.360, 0.560, 11.7, 146, 49.1),
    ('W10X12', 9.87, 3.960, 0.190, 0.210, 3.54, 53.8, 2.18),
    ('W10X22', 10.2, 5.750, 0.240, 0.360, 6.49, 118, 11.4),
    ('W10X33', 9.73, 7.960, 0.290, 0.435, 9.71, 171, 36.6),
    ('W10X49', 10.0, 10.000, 0.340, 0.560, 14.4, 272, 93.4),
    ('W12X14', 11.9, 3.970, 0.200, 0.225, 4.16, 88.6, 2.36),
    ('W12X26', 12.2, 6.490, 0.230, 0.380, 7.65, 204, 17.3),
    ('W12X40', 11.9, 8.005, 0.295, 0.515, 11.7, 307, 44.1),
    ('W12X50', 12.2, 8.080, 0.370, 0.640, 14.6, 391, 56.3),
    ('W12X65', 12.1, 12.000, 0.390, 0.605, 19.1, 533, 174),
    ('W14X22', 13.7, 5.000, 0.230, 0.335, 6.49, 199, 7.00),
    ('W14X30', 13.8, 6.730, 0.270, 0.385, 8.85, 291, 19.6),
    ('W14X48', 13.8, 8.030, 0.340, 0.595, 14.1, 484, 51.4),
    ('W14X74', 14.2, 10.070, 0.450, 0.785, 21.8, 795, 134),
    ('W16X26', 15.7, 5.500, 0.250, 0.345, 7.68, 301, 9.59),
    ('W16X40', 16.0, 7.000, 0.305, 0.505, 11.8, 518, 28.9),
    ('W18X35', 17.7, 6.000, 0.300, 0.425, 10.3, 510, 15.3),
    ('W18X50', 18.0, 7.500, 0.355, 0.570, 14.7, 800, 40.1),
    ('W21X44', 20.7, 6.500, 0.350, 0.450, 13.0, 843, 20.7),
    ('W21X62', 21.0, 8.240, 0.400, 0.615, 18.3, 1330, 57.5),
    ('W24X55', 23.6, 7.005, 0.395, 0.505, 16.2, 1350, 29.1),
    ('W24X76', 23.9, 8.990, 0.440, 0.680, 22.4, 2100, 82.5),
  ])
    StandardSection.imperial(
      designation: row.$1,
      family: SectionFamily.wShape,
      depth: row.$2,
      width: row.$3,
      webThickness: row.$4,
      flangeThickness: row.$5,
      area: row.$6,
      ix: row.$7,
      iy: row.$8,
    ),
];

/// European IPE shapes, in mm / cm² / cm⁴ as published.
final List<StandardSection> _ipeShapes = [
  for (final row in const <_Row>[
    //        designation,  h,    b,    tw,   tf,    A,     Ix,     Iy
    ('IPE 80', 80.0, 46.0, 3.8, 5.2, 7.64, 80.1, 8.49),
    ('IPE 100', 100.0, 55.0, 4.1, 5.7, 10.3, 171, 15.9),
    ('IPE 120', 120.0, 64.0, 4.4, 6.3, 13.2, 318, 27.7),
    ('IPE 140', 140.0, 73.0, 4.7, 6.9, 16.4, 541, 44.9),
    ('IPE 160', 160.0, 82.0, 5.0, 7.4, 20.1, 869, 68.3),
    ('IPE 180', 180.0, 91.0, 5.3, 8.0, 23.9, 1317, 101),
    ('IPE 200', 200.0, 100.0, 5.6, 8.5, 28.5, 1943, 142),
    ('IPE 220', 220.0, 110.0, 5.9, 9.2, 33.4, 2772, 205),
    ('IPE 240', 240.0, 120.0, 6.2, 9.8, 39.1, 3892, 284),
    ('IPE 270', 270.0, 135.0, 6.6, 10.2, 45.9, 5790, 420),
    ('IPE 300', 300.0, 150.0, 7.1, 10.7, 53.8, 8356, 604),
    ('IPE 330', 330.0, 160.0, 7.5, 11.5, 62.6, 11770, 788),
    ('IPE 360', 360.0, 170.0, 8.0, 12.7, 72.7, 16270, 1043),
    ('IPE 400', 400.0, 180.0, 8.6, 13.5, 84.5, 23130, 1318),
    ('IPE 450', 450.0, 190.0, 9.4, 14.6, 98.8, 33740, 1676),
    ('IPE 500', 500.0, 200.0, 10.2, 16.0, 116, 48200, 2142),
    ('IPE 600', 600.0, 220.0, 12.0, 19.0, 156, 92080, 3387),
  ])
    StandardSection.metric(
      designation: row.$1,
      family: SectionFamily.ipe,
      depth: row.$2,
      width: row.$3,
      webThickness: row.$4,
      flangeThickness: row.$5,
      area: row.$6,
      ix: row.$7,
      iy: row.$8,
    ),
];

/// European HEB (HE-B) wide-flange shapes, in mm / cm² / cm⁴ as published.
final List<StandardSection> _hebShapes = [
  for (final row in const <_Row>[
    //        designation,  h,     b,     tw,   tf,   A,     Ix,     Iy
    ('HEB 100', 100.0, 100.0, 6.0, 10.0, 26.0, 450, 167),
    ('HEB 120', 120.0, 120.0, 6.5, 11.0, 34.0, 864, 318),
    ('HEB 140', 140.0, 140.0, 7.0, 12.0, 43.0, 1509, 550),
    ('HEB 160', 160.0, 160.0, 8.0, 13.0, 54.3, 2492, 889),
    ('HEB 180', 180.0, 180.0, 8.5, 14.0, 65.3, 3831, 1363),
    ('HEB 200', 200.0, 200.0, 9.0, 15.0, 78.1, 5696, 2003),
    ('HEB 240', 240.0, 240.0, 10.0, 17.0, 106, 11260, 3923),
    ('HEB 300', 300.0, 300.0, 11.0, 19.0, 149, 25170, 8563),
  ])
    StandardSection.metric(
      designation: row.$1,
      family: SectionFamily.heb,
      depth: row.$2,
      width: row.$3,
      webThickness: row.$4,
      flangeThickness: row.$5,
      area: row.$6,
      ix: row.$7,
      iy: row.$8,
    ),
];

/// Every shape in the library, imperial families first.
final List<StandardSection> standardSections = [
  ..._wShapes,
  ..._ipeShapes,
  ..._hebShapes,
];
