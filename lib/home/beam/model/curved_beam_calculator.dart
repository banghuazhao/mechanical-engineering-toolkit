import 'dart:math' as math;

/// The cross-sections the curved-beam tool can analyse. Each has a closed
/// form for ∫dA/r, which is all the Winkler–Bach theory needs beyond the area
/// and the centroid.
enum CurvedSection {
  rectangle,

  /// Widths [CurvedBeamInput.innerWidth] at the inner fibre and
  /// [CurvedBeamInput.outerWidth] at the outer — a triangle when one is zero.
  trapezoid,
  circle,

  /// A round tube: outer diameter d, bore di, concentric.
  tube,

  /// A flange and a web. The flange sits on the inner side by default, which
  /// is where a hook or a C-frame wants its material: the inner fibre is the
  /// one curvature overloads.
  tSection,

  /// Two flanges, possibly unequal, joined by a web.
  iSection,
}

/// How the section is loaded.
enum CurvedBeamLoading {
  /// A bending moment M and, optionally, a normal force N at the centroid.
  moment,

  /// A force F whose line of action passes through the centre of curvature —
  /// a crane hook, a C-clamp. The section then carries N = F and M = F·rc.
  hook,
}

class CurvedBeamInput {
  const CurvedBeamInput({
    required this.section,
    required this.innerRadius,
    this.depth = 0,
    this.width = 0,
    this.innerWidth = 0,
    this.outerWidth = 0,
    this.diameter = 0,
    this.boreDiameter = 0,
    this.flangeWidth = 0,
    this.flangeThickness = 0,
    this.webThickness = 0,
    this.outerFlangeWidth = 0,
    this.outerFlangeThickness = 0,
    this.flangeInside = true,
    this.loading = CurvedBeamLoading.moment,
    this.moment = 0,
    this.normalForce = 0,
  });

  final CurvedSection section;

  /// Radius to the inner fibre, ri — mm.
  final double innerRadius;

  /// Radial depth h of a rectangle, trapezoid, T or I — mm.
  final double depth;

  /// Width b of a rectangle — mm.
  final double width;

  /// Trapezoid widths at the inner and outer fibres — mm.
  final double innerWidth, outerWidth;

  /// Outer diameter of a circle or tube, and the tube's bore — mm.
  final double diameter, boreDiameter;

  /// The T's flange, or the I's inner flange — mm.
  final double flangeWidth, flangeThickness;

  /// Web thickness of a T or I — mm.
  final double webThickness;

  /// The I's outer flange — mm.
  final double outerFlangeWidth, outerFlangeThickness;

  /// Whether a T's flange is on the inner (concave) side.
  final bool flangeInside;

  final CurvedBeamLoading loading;

  /// Bending moment M — N·mm. Positive straightens the beam, which puts the
  /// inner fibre in tension. Ignored for [CurvedBeamLoading.hook].
  final double moment;

  /// Normal force at the centroid, or the hook load F — N. Positive is
  /// tension.
  final double normalForce;
}

/// One stress, curved and as straight-beam theory would have it.
class FibreStress {
  const FibreStress({
    required this.radius,
    required this.total,
    required this.bending,
    required this.straightBending,
  });

  /// Where the fibre is — mm from the centre of curvature.
  final double radius;

  /// Axial plus bending — MPa.
  final double total;

  /// The bending part alone, by curved-beam theory — MPa.
  final double bending;

  /// The bending part by the flexure formula M·c/I — MPa.
  final double straightBending;

  /// How much curvature raises (inner) or lowers (outer) the bending stress
  /// over the straight-beam figure.
  double get curvatureFactor =>
      straightBending == 0 ? 1 : bending / straightBending;
}

class CurvedBeamResult {
  const CurvedBeamResult({
    required this.area,
    required this.centroidRadius,
    required this.neutralRadius,
    required this.eccentricity,
    required this.integralDaOverR,
    required this.secondMoment,
    required this.moment,
    required this.normalForce,
    required this.inner,
    required this.outer,
    required this.innerRadius,
    required this.outerRadius,
  });

  /// A — mm².
  final double area;

  /// rc — mm.
  final double centroidRadius;

  /// rn = A / ∫dA/r — mm.
  final double neutralRadius;

  /// e = rc − rn — mm. Always positive: the neutral axis moves toward the
  /// centre of curvature.
  final double eccentricity;

  /// ∫dA/r — mm.
  final double integralDaOverR;

  /// I about the centroidal axis, for the straight-beam comparison — mm⁴.
  final double secondMoment;

  /// The moment and normal force the section carries — N·mm and N.
  final double moment, normalForce;

  final FibreStress inner, outer;

  final double innerRadius, outerRadius;

  double get depth => outerRadius - innerRadius;

  /// ci = rn − ri and co = ro − rn — mm.
  double get innerDistance => neutralRadius - innerRadius;
  double get outerDistance => outerRadius - neutralRadius;

  /// rc/h — a feel for how curved the beam is. Above about 10 the flexure
  /// formula is within a few per cent.
  double get curvatureRatio => centroidRadius / depth;

  /// σ at radius [r] — MPa.
  double stressAt(double r) =>
      normalForce / area +
      moment * (neutralRadius - r) / (area * eccentricity * r);

  /// The fibre with the larger magnitude of stress.
  FibreStress get governing =>
      inner.total.abs() >= outer.total.abs() ? inner : outer;
}

/// One rectangular band of a built-up section, from [from] to [to] radially.
class _Band {
  const _Band(this.width, this.from, this.to);
  final double width, from, to;
}

/// Winkler–Bach curved-beam theory: plane sections stay plane, but fibres at
/// different radii have different lengths, so the bending stress is
/// hyperbolic through the depth and the neutral axis sits inside the
/// centroid by e = rc − rn.
abstract final class CurvedBeamCalculator {
  static CurvedBeamResult calculate(CurvedBeamInput input) {
    final ri = input.innerRadius;
    if (!(ri > 0)) {
      throw const FormatException('Inner radius must be positive.');
    }

    double area, integral, rc, secondMoment, ro;

    switch (input.section) {
      case CurvedSection.circle:
      case CurvedSection.tube:
        final d = input.diameter;
        final di =
            input.section == CurvedSection.tube ? input.boreDiameter : 0.0;
        _positive([d]);
        if (di < 0 || di >= d) {
          throw const FormatException(
              'The bore must be smaller than the outer diameter.');
        }
        final r = d / 2, rh = di / 2;
        rc = ri + r;
        ro = ri + d;
        area = math.pi * (r * r - rh * rh);
        // ∫dA/r over a disc of radius a centred at rc is 2π(rc − √(rc² − a²)).
        double disc(double a) =>
            a == 0 ? 0 : 2 * math.pi * (rc - math.sqrt(rc * rc - a * a));
        integral = disc(r) - disc(rh);
        secondMoment = math.pi * (math.pow(r, 4) - math.pow(rh, 4)) / 4;

      case CurvedSection.trapezoid:
        final h = input.depth, bi = input.innerWidth, bo = input.outerWidth;
        _positive([h]);
        if (bi < 0 || bo < 0 || bi + bo <= 0) {
          throw const FormatException(
              'The widths cannot be negative, and one must be positive.');
        }
        ro = ri + h;
        area = (bi + bo) * h / 2;
        integral = (bi * ro - bo * ri) / h * math.log(ro / ri) + (bo - bi);
        rc = ri + h * (bi + 2 * bo) / (3 * (bi + bo));
        secondMoment =
            h * h * h * (bi * bi + 4 * bi * bo + bo * bo) / (36 * (bi + bo));

      case CurvedSection.rectangle:
      case CurvedSection.tSection:
      case CurvedSection.iSection:
        final bands = _bands(input);
        ro = bands.last.to;
        area = 0;
        integral = 0;
        var firstMoment = 0.0, secondAboutCentre = 0.0;
        for (final band in bands) {
          final a = band.from, b = band.to, w = band.width;
          area += w * (b - a);
          integral += w * math.log(b / a);
          firstMoment += w * (b * b - a * a) / 2;
          secondAboutCentre += w * (b * b * b - a * a * a) / 3;
        }
        rc = firstMoment / area;
        secondMoment = secondAboutCentre - area * rc * rc;
    }

    final rn = area / integral;
    final e = rc - rn;
    if (!(e > 0)) {
      // Only reachable when the beam is so gently curved that rc − rn is lost
      // to rounding, at which point the straight-beam formula is exact enough.
      throw const FormatException(
          'The beam is too gently curved to resolve the neutral-axis shift; '
          'use the flexure formula.');
    }

    final normal = input.normalForce;
    final m =
        input.loading == CurvedBeamLoading.hook ? normal * rc : input.moment;

    FibreStress fibre(double r) {
      final bending = m * (rn - r) / (area * e * r);
      return FibreStress(
        radius: r,
        total: normal / area + bending,
        bending: bending,
        straightBending: m * (rc - r) / secondMoment,
      );
    }

    return CurvedBeamResult(
      area: area,
      centroidRadius: rc,
      neutralRadius: rn,
      eccentricity: e,
      integralDaOverR: integral,
      secondMoment: secondMoment,
      moment: m,
      normalForce: normal,
      inner: fibre(ri),
      outer: fibre(ro),
      innerRadius: ri,
      outerRadius: ro,
    );
  }

  static void _positive(List<double> values) {
    for (final v in values) {
      if (!(v > 0)) {
        throw const FormatException('Every dimension must be positive.');
      }
    }
  }

  /// The section as bands of constant width, inner fibre first.
  static List<_Band> _bands(CurvedBeamInput input) {
    final ri = input.innerRadius, h = input.depth;
    switch (input.section) {
      case CurvedSection.rectangle:
        _positive([h, input.width]);
        return [_Band(input.width, ri, ri + h)];
      case CurvedSection.tSection:
        final bf = input.flangeWidth, tf = input.flangeThickness;
        final tw = input.webThickness;
        _positive([h, bf, tf, tw]);
        if (tf >= h) {
          throw const FormatException(
              'The flange must be thinner than the overall depth.');
        }
        return input.flangeInside
            ? [_Band(bf, ri, ri + tf), _Band(tw, ri + tf, ri + h)]
            : [_Band(tw, ri, ri + h - tf), _Band(bf, ri + h - tf, ri + h)];
      case CurvedSection.iSection:
        final b1 = input.flangeWidth, t1 = input.flangeThickness;
        final b2 = input.outerFlangeWidth, t2 = input.outerFlangeThickness;
        final tw = input.webThickness;
        _positive([h, b1, t1, b2, t2, tw]);
        if (t1 + t2 >= h) {
          throw const FormatException(
              'The two flanges must be thinner together than the depth.');
        }
        return [
          _Band(b1, ri, ri + t1),
          _Band(tw, ri + t1, ri + h - t2),
          _Band(b2, ri + h - t2, ri + h),
        ];
      case CurvedSection.trapezoid:
      case CurvedSection.circle:
      case CurvedSection.tube:
        throw StateError('${input.section} is not built from bands');
    }
  }
}
