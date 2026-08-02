/// ISO 286 limits and fits: standard tolerance grades, shaft fundamental
/// deviations, and the preferred hole-basis fits built from them.
///
/// Covers nominal sizes from 1 mm to 500 mm over the thirteen standard size
/// bands. Only the fits whose shaft deviations are constant across those bands
/// are listed — c, s and u split into finer sub-bands and are left out rather
/// than approximated.
library;

/// A nominal size band. Bounds read "over [min], up to and including [max]",
/// except the first band which includes its lower bound.
class SizeBand {
  const SizeBand(this.min, this.max);

  final int min;
  final int max;

  String get label => '$min–$max';

  bool contains(num diameter) =>
      (diameter > min || (min == 1 && diameter == 1)) && diameter <= max;
}

const List<SizeBand> sizeBands = [
  SizeBand(1, 3),
  SizeBand(3, 6),
  SizeBand(6, 10),
  SizeBand(10, 18),
  SizeBand(18, 30),
  SizeBand(30, 50),
  SizeBand(50, 80),
  SizeBand(80, 120),
  SizeBand(120, 180),
  SizeBand(180, 250),
  SizeBand(250, 315),
  SizeBand(315, 400),
  SizeBand(400, 500),
];

/// Standard tolerance grades in µm, indexed by [sizeBands].
const Map<int, List<int>> toleranceGrades = {
  6: [6, 8, 9, 11, 13, 16, 19, 22, 25, 29, 32, 36, 40],
  7: [10, 12, 15, 18, 21, 25, 30, 35, 40, 46, 52, 57, 63],
  8: [14, 18, 22, 27, 33, 39, 46, 54, 63, 72, 81, 89, 97],
  9: [25, 30, 36, 43, 52, 62, 74, 87, 100, 115, 130, 140, 155],
  11: [60, 75, 90, 110, 130, 160, 190, 220, 250, 290, 320, 360, 400],
};

/// Which limit a shaft's fundamental deviation defines: letters a–h fix the
/// upper deviation (es), letters j–zc the lower one (ei).
enum DeviationKind { upper, lower }

class ShaftDeviation {
  const ShaftDeviation(this.letter, this.kind, this.microns);

  final String letter;
  final DeviationKind kind;

  /// Fundamental deviation in µm, indexed by [sizeBands].
  final List<int> microns;
}

const Map<String, ShaftDeviation> shaftDeviations = {
  'd': ShaftDeviation('d', DeviationKind.upper, [
    -20, -30, -40, -50, -65, -80, -100, -120, -145, -170, -190, -210, -230, //
  ]),
  'f': ShaftDeviation('f', DeviationKind.upper, [
    -6, -10, -13, -16, -20, -25, -30, -36, -43, -50, -56, -62, -68, //
  ]),
  'g': ShaftDeviation('g', DeviationKind.upper, [
    -2, -4, -5, -6, -7, -9, -10, -12, -14, -15, -17, -18, -20, //
  ]),
  'h': ShaftDeviation('h', DeviationKind.upper, [
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, //
  ]),
  'k': ShaftDeviation('k', DeviationKind.lower, [
    0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, //
  ]),
  'n': ShaftDeviation('n', DeviationKind.lower, [
    4, 8, 10, 12, 15, 17, 20, 23, 27, 31, 34, 37, 40, //
  ]),
  'p': ShaftDeviation('p', DeviationKind.lower, [
    6, 12, 15, 18, 22, 26, 32, 37, 43, 50, 56, 62, 68, //
  ]),
};

class PreferredFit {
  const PreferredFit({
    required this.holeGrade,
    required this.shaftLetter,
    required this.shaftGrade,
  });

  final int holeGrade;
  final String shaftLetter;
  final int shaftGrade;

  String get name => 'H$holeGrade/$shaftLetter$shaftGrade';
}

/// The preferred hole-basis fits, loosest first.
const List<PreferredFit> preferredFits = [
  PreferredFit(holeGrade: 11, shaftLetter: 'h', shaftGrade: 11),
  PreferredFit(holeGrade: 9, shaftLetter: 'd', shaftGrade: 9),
  PreferredFit(holeGrade: 8, shaftLetter: 'f', shaftGrade: 7),
  PreferredFit(holeGrade: 7, shaftLetter: 'g', shaftGrade: 6),
  PreferredFit(holeGrade: 7, shaftLetter: 'h', shaftGrade: 6),
  PreferredFit(holeGrade: 7, shaftLetter: 'k', shaftGrade: 6),
  PreferredFit(holeGrade: 7, shaftLetter: 'n', shaftGrade: 6),
  PreferredFit(holeGrade: 7, shaftLetter: 'p', shaftGrade: 6),
];

/// One fit at one size band, with every limit in µm relative to the nominal
/// size. Negative clearance is interference.
class FitEntry {
  const FitEntry({
    required this.fit,
    required this.band,
    required this.holeUpper,
    required this.holeLower,
    required this.shaftUpper,
    required this.shaftLower,
  });

  final PreferredFit fit;
  final SizeBand band;
  final int holeUpper;
  final int holeLower;
  final int shaftUpper;
  final int shaftLower;

  int get maxClearance => holeUpper - shaftLower;
  int get minClearance => holeLower - shaftUpper;

  bool get isInterference => maxClearance < 0;
  bool get isTransition => minClearance < 0 && maxClearance >= 0;
}

/// Signed µm, e.g. `+21`, `0`, `-20`.
String formatMicrons(int value) => value > 0 ? '+$value' : '$value';

FitEntry _entry(PreferredFit fit, int bandIndex) {
  final band = sizeBands[bandIndex];
  final holeTolerance = toleranceGrades[fit.holeGrade]![bandIndex];
  final shaftTolerance = toleranceGrades[fit.shaftGrade]![bandIndex];
  final deviation = shaftDeviations[fit.shaftLetter]!;
  final value = deviation.microns[bandIndex];
  // Hole basis: the hole's lower limit is always the nominal size.
  return FitEntry(
    fit: fit,
    band: band,
    holeUpper: holeTolerance,
    holeLower: 0,
    shaftUpper:
        deviation.kind == DeviationKind.upper ? value : value + shaftTolerance,
    shaftLower:
        deviation.kind == DeviationKind.upper ? value - shaftTolerance : value,
  );
}

/// Every preferred fit across every size band, grouped by fit.
final List<FitEntry> fitEntries = [
  for (final fit in preferredFits)
    for (var i = 0; i < sizeBands.length; i++) _entry(fit, i),
];
