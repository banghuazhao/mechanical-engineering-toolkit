/// Bolt strength grades, thread stress areas, and the clamp load and
/// tightening torque that follow from them.
///
/// Metric property classes are ISO 898-1; inch grades are SAE J429. The two
/// numbers on a metric class are not arbitrary: `8.8` means a nominal tensile
/// strength of 8 × 100 = 800 MPa and a yield of 0.8 × that. Inch grades carry
/// no such rule and are simply looked up.
///
/// Only the strengths are tabulated. Stress area, clamp load and torque are
/// derived on [BoltSpec], so a row cannot disagree with the size it belongs
/// to — the same reason pipe bore is derived from OD and wall rather than
/// listed alongside them.
library;

import 'dart:math' as math;

/// The customary nut factor K for a plain, non-plated, unlubricated thread.
///
/// It stands in for the whole friction problem — thread friction, face
/// friction and the thread's own helix — in `T = K·F·d`, and it is the reason
/// a torque figure is an estimate rather than a measurement. Zinc plating,
/// wax, or anti-seize move it between roughly 0.10 and 0.25, which swings the
/// torque for a given preload by more than a factor of two. Where the preload
/// actually matters, measure it: angle control, bolt stretch, or a load cell.
const double plainSteelNutFactor = 0.2;

/// Fraction of proof strength the clamp load is set to.
///
/// 75% is the usual figure for a reused fastener; 90% is common for a
/// permanent joint tightened once. Neither is a standard — both are practice.
const double clampLoadProofFraction = 0.75;

enum FastenerStandard { iso898, saeJ429 }

/// Strengths for one band of diameters within a grade.
///
/// A grade is not one set of numbers: ISO 898-1 derates class 8.8 above M16,
/// and SAE J429 derates grade 2 above 3/4 in, because a thicker section
/// cannot be through-hardened to the same properties. Getting this wrong
/// overstates the clamp load on exactly the large fasteners where it matters.
class StrengthBand {
  const StrengthBand({
    required this.maxDiameterMm,
    required this.proofStrength,
    required this.yieldStrength,
    required this.tensileStrength,
  });

  /// Largest nominal diameter this band covers, in mm, inclusive.
  final double maxDiameterMm;

  /// Proof strength, MPa — the stress the fastener carries with no measurable
  /// permanent set. This, not yield, is what a preload is set against.
  final double proofStrength;

  /// Yield strength (0.2% offset), MPa.
  final double yieldStrength;

  /// Minimum ultimate tensile strength, MPa.
  final double tensileStrength;
}

class BoltGrade {
  const BoltGrade({
    required this.designation,
    required this.standard,
    required this.headMarking,
    required this.bands,
  });

  /// As it is called out on a drawing, e.g. `10.9` or `SAE 5`.
  final String designation;

  final FastenerStandard standard;

  /// What is stamped on the head, so a fastener already in a joint can be
  /// identified — the reason this table beats a strength chart in a binder.
  final String headMarking;

  /// Ordered by [StrengthBand.maxDiameterMm], ascending.
  final List<StrengthBand> bands;

  bool get isMetric => standard == FastenerStandard.iso898;

  /// The band covering [diameterMm], or the largest band when the diameter is
  /// past the end of the table.
  StrengthBand bandFor(double diameterMm) {
    for (final band in bands) {
      if (diameterMm <= band.maxDiameterMm) return band;
    }
    return bands.last;
  }
}

/// One thread size, metric coarse or unified coarse.
class BoltSize {
  const BoltSize({
    required this.designation,
    required this.isMetric,
    required this.diameterMm,
    required this.threadLabel,
    required this.stressAreaMm2,
  });

  /// `M12` or `1/2-13`.
  final String designation;

  final bool isMetric;

  /// Nominal (major) diameter, mm.
  final double diameterMm;

  /// Pitch in mm for metric, threads per inch for unified.
  final String threadLabel;

  /// Tensile stress area As, mm² — the area the thread actually breaks at,
  /// midway between the pitch and minor diameters. Always smaller than the
  /// nominal shank area, which is why sizing a bolt on πd²/4 is unsafe.
  final double stressAreaMm2;
}

/// A size and a grade together: everything a row of the table shows.
class BoltSpec {
  const BoltSpec(this.size, this.grade);

  final BoltSize size;
  final BoltGrade grade;

  StrengthBand get band => grade.bandFor(size.diameterMm);

  /// Recommended clamp load, N. mm² × MPa is N exactly, no factor needed.
  double get clampLoad =>
      clampLoadProofFraction * size.stressAreaMm2 * band.proofStrength;

  /// Tightening torque for [clampLoad], N·m, from T = K·F·d.
  double get tighteningTorque =>
      plainSteelNutFactor * clampLoad * size.diameterMm / 1000;

  /// Matched against a typed query: `m12 10.9`, `1/2-13 sae 8`.
  String get searchText =>
      '${size.designation} ${size.threadLabel} ${grade.designation} '
      '${grade.standard == FastenerStandard.iso898 ? 'metric iso' : 'inch unc sae'}';
}

/// Tensile stress area from ISO 898-1: As = (π/4)(d − 0.9382·p)², the mean of
/// the pitch and minor diameters. Used to check the tabulated values rather
/// than to produce them — the published numbers are what a drawing cites.
double metricStressArea(double diameterMm, double pitchMm) =>
    math.pi / 4 * math.pow(diameterMm - 0.9382 * pitchMm, 2).toDouble();

/// The unified-thread equivalent, As = 0.7854(d − 0.9743/n)², in in².
double unifiedStressArea(double diameterIn, double threadsPerInch) =>
    math.pi / 4 * math.pow(diameterIn - 0.9743 / threadsPerInch, 2).toDouble();

// --- Grades ---------------------------------------------------------------

/// ISO 898-1 property classes, in the range of sizes this table covers.
///
/// 4.6 and 5.8 are here because they are what an unmarked commercial bolt
/// usually turns out to be, and reading a 4.6 bolt as though it were 8.8
/// overstates its clamp load by a factor of nearly three.
const List<BoltGrade> metricGrades = [
  BoltGrade(
    designation: '4.6',
    standard: FastenerStandard.iso898,
    headMarking: '4.6',
    bands: [
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 225,
        yieldStrength: 240,
        tensileStrength: 400,
      ),
    ],
  ),
  BoltGrade(
    designation: '5.8',
    standard: FastenerStandard.iso898,
    headMarking: '5.8',
    bands: [
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 380,
        yieldStrength: 420,
        tensileStrength: 520,
      ),
    ],
  ),
  BoltGrade(
    designation: '8.8',
    standard: FastenerStandard.iso898,
    headMarking: '8.8',
    bands: [
      // Derated above M16: the larger section cannot be hardened through.
      StrengthBand(
        maxDiameterMm: 16,
        proofStrength: 580,
        yieldStrength: 640,
        tensileStrength: 800,
      ),
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 600,
        yieldStrength: 660,
        tensileStrength: 830,
      ),
    ],
  ),
  BoltGrade(
    designation: '10.9',
    standard: FastenerStandard.iso898,
    headMarking: '10.9',
    bands: [
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 830,
        yieldStrength: 940,
        tensileStrength: 1040,
      ),
    ],
  ),
  BoltGrade(
    designation: '12.9',
    standard: FastenerStandard.iso898,
    headMarking: '12.9',
    bands: [
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 970,
        yieldStrength: 1100,
        tensileStrength: 1220,
      ),
    ],
  ),
];

/// SAE J429 grades, converted from the published ksi values.
///
/// The head marking is the only way to tell these apart in a scrap bin: grade
/// 2 is unmarked, and the line count on 5 and 8 is the grade number minus two.
const List<BoltGrade> inchGrades = [
  BoltGrade(
    designation: 'SAE 2',
    standard: FastenerStandard.saeJ429,
    headMarking: 'no marks',
    bands: [
      // 1/4 to 3/4 in: 55 / 57 / 74 ksi.
      StrengthBand(
        maxDiameterMm: 19.05,
        proofStrength: 379,
        yieldStrength: 393,
        tensileStrength: 510,
      ),
      // 7/8 to 1 1/2 in: 33 / 36 / 60 ksi.
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 228,
        yieldStrength: 248,
        tensileStrength: 414,
      ),
    ],
  ),
  BoltGrade(
    designation: 'SAE 5',
    standard: FastenerStandard.saeJ429,
    headMarking: '3 radial lines',
    bands: [
      // 1/4 to 1 in: 85 / 92 / 120 ksi.
      StrengthBand(
        maxDiameterMm: 25.4,
        proofStrength: 586,
        yieldStrength: 634,
        tensileStrength: 827,
      ),
      // Over 1 to 1 1/2 in: 74 / 81 / 105 ksi.
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 510,
        yieldStrength: 558,
        tensileStrength: 724,
      ),
    ],
  ),
  BoltGrade(
    designation: 'SAE 8',
    standard: FastenerStandard.saeJ429,
    headMarking: '6 radial lines',
    bands: [
      // 1/4 to 1 1/2 in: 120 / 130 / 150 ksi.
      StrengthBand(
        maxDiameterMm: double.infinity,
        proofStrength: 827,
        yieldStrength: 896,
        tensileStrength: 1034,
      ),
    ],
  ),
];

// --- Sizes ----------------------------------------------------------------

/// Metric coarse threads, ISO 261 / ISO 898-1.
const List<BoltSize> metricSizes = [
  BoltSize(
      designation: 'M3',
      isMetric: true,
      diameterMm: 3,
      threadLabel: '0.5 mm',
      stressAreaMm2: 5.03),
  BoltSize(
      designation: 'M4',
      isMetric: true,
      diameterMm: 4,
      threadLabel: '0.7 mm',
      stressAreaMm2: 8.78),
  BoltSize(
      designation: 'M5',
      isMetric: true,
      diameterMm: 5,
      threadLabel: '0.8 mm',
      stressAreaMm2: 14.2),
  BoltSize(
      designation: 'M6',
      isMetric: true,
      diameterMm: 6,
      threadLabel: '1.0 mm',
      stressAreaMm2: 20.1),
  BoltSize(
      designation: 'M8',
      isMetric: true,
      diameterMm: 8,
      threadLabel: '1.25 mm',
      stressAreaMm2: 36.6),
  BoltSize(
      designation: 'M10',
      isMetric: true,
      diameterMm: 10,
      threadLabel: '1.5 mm',
      stressAreaMm2: 58.0),
  BoltSize(
      designation: 'M12',
      isMetric: true,
      diameterMm: 12,
      threadLabel: '1.75 mm',
      stressAreaMm2: 84.3),
  BoltSize(
      designation: 'M14',
      isMetric: true,
      diameterMm: 14,
      threadLabel: '2.0 mm',
      stressAreaMm2: 115),
  BoltSize(
      designation: 'M16',
      isMetric: true,
      diameterMm: 16,
      threadLabel: '2.0 mm',
      stressAreaMm2: 157),
  BoltSize(
      designation: 'M18',
      isMetric: true,
      diameterMm: 18,
      threadLabel: '2.5 mm',
      stressAreaMm2: 192),
  BoltSize(
      designation: 'M20',
      isMetric: true,
      diameterMm: 20,
      threadLabel: '2.5 mm',
      stressAreaMm2: 245),
  BoltSize(
      designation: 'M22',
      isMetric: true,
      diameterMm: 22,
      threadLabel: '2.5 mm',
      stressAreaMm2: 303),
  BoltSize(
      designation: 'M24',
      isMetric: true,
      diameterMm: 24,
      threadLabel: '3.0 mm',
      stressAreaMm2: 353),
  BoltSize(
      designation: 'M27',
      isMetric: true,
      diameterMm: 27,
      threadLabel: '3.0 mm',
      stressAreaMm2: 459),
  BoltSize(
      designation: 'M30',
      isMetric: true,
      diameterMm: 30,
      threadLabel: '3.5 mm',
      stressAreaMm2: 561),
  BoltSize(
      designation: 'M36',
      isMetric: true,
      diameterMm: 36,
      threadLabel: '4.0 mm',
      stressAreaMm2: 817),
];

/// Unified coarse (UNC) threads. Stress areas are the published in² values
/// converted at 645.16 mm²/in², so every derived figure below stays in one
/// system of units.
const List<BoltSize> inchSizes = [
  BoltSize(
      designation: '1/4-20',
      isMetric: false,
      diameterMm: 6.35,
      threadLabel: '20 TPI',
      stressAreaMm2: 20.51), // 0.0318 in²
  BoltSize(
      designation: '5/16-18',
      isMetric: false,
      diameterMm: 7.938,
      threadLabel: '18 TPI',
      stressAreaMm2: 33.81), // 0.0524 in²
  BoltSize(
      designation: '3/8-16',
      isMetric: false,
      diameterMm: 9.525,
      threadLabel: '16 TPI',
      stressAreaMm2: 50.00), // 0.0775 in²
  BoltSize(
      designation: '7/16-14',
      isMetric: false,
      diameterMm: 11.113,
      threadLabel: '14 TPI',
      stressAreaMm2: 68.58), // 0.1063 in²
  BoltSize(
      designation: '1/2-13',
      isMetric: false,
      diameterMm: 12.7,
      threadLabel: '13 TPI',
      stressAreaMm2: 91.55), // 0.1419 in²
  BoltSize(
      designation: '9/16-12',
      isMetric: false,
      diameterMm: 14.288,
      threadLabel: '12 TPI',
      stressAreaMm2: 117.4), // 0.182 in²
  BoltSize(
      designation: '5/8-11',
      isMetric: false,
      diameterMm: 15.875,
      threadLabel: '11 TPI',
      stressAreaMm2: 145.8), // 0.226 in²
  BoltSize(
      designation: '3/4-10',
      isMetric: false,
      diameterMm: 19.05,
      threadLabel: '10 TPI',
      stressAreaMm2: 215.5), // 0.334 in²
  BoltSize(
      designation: '7/8-9',
      isMetric: false,
      diameterMm: 22.225,
      threadLabel: '9 TPI',
      stressAreaMm2: 298.1), // 0.462 in²
  BoltSize(
      designation: '1-8',
      isMetric: false,
      diameterMm: 25.4,
      threadLabel: '8 TPI',
      stressAreaMm2: 390.9), // 0.606 in²
];

/// Every size crossed with every grade of its own thread system, metric
/// first, then by ascending diameter and grade.
final List<BoltSpec> boltSpecs = [
  for (final size in metricSizes)
    for (final grade in metricGrades) BoltSpec(size, grade),
  for (final size in inchSizes)
    for (final grade in inchGrades) BoltSpec(size, grade),
];
