import 'dart:math' as math;

/// Water and steam properties from IAPWS-IF97, the Industrial Formulation
/// 1997 that steam tables in textbooks and power-plant software are built on.
///
/// Implemented here: the basic equations for regions 1 (compressed liquid),
/// 2 (superheated vapour), 3 (the near-critical region, as a Helmholtz
/// function of density), 4 (the saturation line) and 5 (high-temperature
/// steam), plus the B23 boundary between regions 2 and 3. The optional
/// backward equations are not: every inverse here — density in region 3,
/// temperature from enthalpy or entropy — is solved iteratively from the
/// basic equations instead, which keeps the implementation to one set of
/// coefficients per region, all of them checked against the release's own
/// verification tables in `test/iapws_if97_test.dart`.
///
/// Units throughout this file are the formulation's own: pressure in MPa,
/// temperature in K, specific volume in m³/kg, energies in kJ/kg, entropy and
/// heat capacities in kJ/(kg·K), speed of sound in m/s. Callers convert at
/// their boundary.
///
/// Validity: 273.15 K ≤ T ≤ 1073.15 K at p ≤ 100 MPa, and
/// 1073.15 K < T ≤ 2273.15 K at p ≤ 50 MPa.
abstract final class If97 {
  /// Specific gas constant of water, kJ/(kg·K).
  static const double r = 0.461526;

  /// Critical temperature, K.
  static const double tc = 647.096;

  /// Critical pressure, MPa.
  static const double pc = 22.064;

  /// Critical density, kg/m³.
  static const double rhoc = 322.0;

  /// Lowest temperature the formulation covers, K (0 °C).
  static const double tMin = 273.15;

  /// Upper temperature of regions 1–3, K.
  static const double tMax13 = 1073.15;

  /// Upper temperature of region 5, K.
  static const double tMax5 = 2273.15;

  /// Pressure ceilings, MPa.
  static const double pMax = 100;
  static const double pMax5 = 50;

  // ------------------------------------------------------------ region 4

  static const _n4 = [
    0.11670521452767e4,
    -0.72421316598986e6,
    -0.17073846940092e2,
    0.12020824702470e5,
    -0.32325550322333e7,
    0.14915108613530e2,
    -0.48232657361591e4,
    0.40511340542057e6,
    -0.23855557567849,
    0.65017534844798e3,
  ];

  /// Saturation pressure at [t] (K), MPa. Valid from 273.15 K to [tc].
  static double saturationPressure(double t) {
    final theta = t + _n4[8] / (t - _n4[9]);
    final a = theta * theta + _n4[0] * theta + _n4[1];
    final b = _n4[2] * theta * theta + _n4[3] * theta + _n4[4];
    final c = _n4[5] * theta * theta + _n4[6] * theta + _n4[7];
    return math.pow(2 * c / (-b + math.sqrt(b * b - 4 * a * c)), 4)
        .toDouble();
  }

  /// Saturation temperature at [p] (MPa), K. Valid from 611.213 Pa to [pc].
  static double saturationTemperature(double p) {
    final beta = math.pow(p, 0.25).toDouble();
    final e = beta * beta + _n4[2] * beta + _n4[5];
    final f = _n4[0] * beta * beta + _n4[3] * beta + _n4[6];
    final g = _n4[1] * beta * beta + _n4[4] * beta + _n4[7];
    final d = 2 * g / (-f - math.sqrt(f * f - 4 * e * g));
    final sum = _n4[9] + d;
    return (sum - math.sqrt(sum * sum - 4 * (_n4[8] + _n4[9] * d))) / 2;
  }

  // ------------------------------------------------------------ B23

  static const _nB23 = [
    0.34805185628969e3,
    -0.11671859879975e1,
    0.10192970039326e-2,
    0.57254459862746e3,
    0.13918839778870e2,
  ];

  /// Pressure on the region 2–3 boundary at [t] (K), MPa.
  static double b23Pressure(double t) =>
      _nB23[0] + _nB23[1] * t + _nB23[2] * t * t;

  /// Temperature on the region 2–3 boundary at [p] (MPa), K.
  static double b23Temperature(double p) =>
      _nB23[3] + math.sqrt((p - _nB23[4]) / _nB23[2]);

  // ------------------------------------------------------------ region 1

  static const _i1 = [
    0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4,
    5, 8, 8, 21, 23, 29, 30, 31, 32, //
  ];
  static const _j1 = [
    -2, -1, 0, 1, 2, 3, 4, 5, -9, -7, -1, 0, 1, 3, -3, 0, 1, 3, 17, -4, 0, 6,
    -5, -2, 10, -8, -11, -6, -29, -31, -38, -39, -40, -41, //
  ];
  static const _n1 = [
    0.14632971213167,
    -0.84548187169114,
    -0.37563603672040e1,
    0.33855169168385e1,
    -0.95791963387872,
    0.15772038513228,
    -0.16616417199501e-1,
    0.81214629983568e-3,
    0.28319080123804e-3,
    -0.60706301565874e-3,
    -0.18990068218419e-1,
    -0.32529748770505e-1,
    -0.21841717175414e-1,
    -0.52838357969930e-4,
    -0.47184321073267e-3,
    -0.30001780793026e-3,
    0.47661393906987e-4,
    -0.44141845330846e-5,
    -0.72694996297594e-15,
    -0.31679644845054e-4,
    -0.28270797985312e-5,
    -0.85205128120103e-9,
    -0.22425281908000e-5,
    -0.65171222895601e-6,
    -0.14341729937924e-12,
    -0.40516996860117e-6,
    -0.12734301741641e-8,
    -0.17424871230634e-9,
    -0.68762131295531e-18,
    0.14478307828521e-19,
    0.26335781662795e-22,
    -0.11947622640071e-22,
    0.18228094581404e-23,
    -0.93537087292458e-25,
  ];

  /// Region 1 at ([p] MPa, [t] K).
  static SteamProperties region1(double p, double t) {
    final pi = p / 16.53;
    final tau = 1386 / t;
    final a = 7.1 - pi;
    final b = tau - 1.222;
    var g = 0.0, gp = 0.0, gpp = 0.0, gt = 0.0, gtt = 0.0, gpt = 0.0;
    for (var k = 0; k < _n1.length; k++) {
      final n = _n1[k];
      final i = _i1[k];
      final j = _j1[k];
      final ai = _pow(a, i);
      final bj = _pow(b, j);
      g += n * ai * bj;
      gp -= n * i * _pow(a, i - 1) * bj;
      gpp += n * i * (i - 1) * _pow(a, i - 2) * bj;
      gt += n * ai * j * _pow(b, j - 1);
      gtt += n * ai * j * (j - 1) * _pow(b, j - 2);
      gpt -= n * i * _pow(a, i - 1) * j * _pow(b, j - 1);
    }
    final v = r * t / (p * 1000) * pi * gp;
    final w2 = r * 1000 * t * gp * gp /
        ((gp - tau * gpt) * (gp - tau * gpt) / (tau * tau * gtt) - gpp);
    return SteamProperties(
      pressure: p,
      temperature: t,
      specificVolume: v,
      internalEnergy: r * t * (tau * gt - pi * gp),
      entropy: r * (tau * gt - g),
      enthalpy: r * t * tau * gt,
      cp: -r * tau * tau * gtt,
      cv: r *
          (-tau * tau * gtt +
              (gp - tau * gpt) * (gp - tau * gpt) / gpp),
      speedOfSound: math.sqrt(w2),
      region: 1,
    );
  }

  // ------------------------------------------------------------ region 2

  static const _j0_2 = [0, 1, -5, -4, -3, -2, -1, 2, 3];
  static const _n0_2 = [
    -0.96927686500217e1,
    0.10086655968018e2,
    -0.56087911283020e-2,
    0.71452738081455e-1,
    -0.40710498223928,
    0.14240819171444e1,
    -0.43839511319450e1,
    -0.28408632460772,
    0.21268463753307e-1,
  ];
  static const _ir2 = [
    1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 5, 6, 6, 6, 7, 7, 7,
    8, 8, 9, 10, 10, 10, 16, 16, 18, 20, 20, 20, 21, 22, 23, 24, 24, 24, //
  ];
  static const _jr2 = [
    0, 1, 2, 3, 6, 1, 2, 4, 7, 36, 0, 1, 3, 6, 35, 1, 2, 3, 7, 3, 16, 35, 0,
    11, 25, 8, 36, 13, 4, 10, 14, 29, 50, 57, 20, 35, 48, 21, 53, 39, 26, 40,
    58, //
  ];
  static const _nr2 = [
    -0.17731742473213e-2,
    -0.17834862292358e-1,
    -0.45996013696365e-1,
    -0.57581259083432e-1,
    -0.50325278727930e-1,
    -0.33032641670203e-4,
    -0.18948987516315e-3,
    -0.39392777243355e-2,
    -0.43797295650573e-1,
    -0.26674547914087e-4,
    0.20481737692309e-7,
    0.43870667284435e-6,
    -0.32277677238570e-4,
    -0.15033924542148e-2,
    -0.40668253562649e-1,
    -0.78847309559367e-9,
    0.12790717852285e-7,
    0.48225372718507e-6,
    0.22922076337661e-5,
    -0.16714766451061e-10,
    -0.21171472321355e-2,
    -0.23895741934104e2,
    -0.59059564324270e-17,
    -0.12621808899101e-5,
    -0.38946842435739e-1,
    0.11256211360459e-10,
    -0.82311340897998e1,
    0.19809712802088e-7,
    0.10406965210174e-18,
    -0.10234747095929e-12,
    -0.10018179379511e-8,
    -0.80882908646985e-10,
    0.10693031879409,
    -0.33662250574171,
    0.89185845355421e-24,
    0.30629316876232e-12,
    -0.42002467698208e-5,
    -0.59056029685639e-25,
    0.37826947613457e-5,
    -0.12768608934681e-14,
    0.73087610595061e-28,
    0.55414715350778e-16,
    -0.94369707241210e-6,
  ];

  /// Region 2 at ([p] MPa, [t] K).
  static SteamProperties region2(double p, double t) => _gibbsVapour(
        p: p,
        t: t,
        tauStar: 540,
        j0: _j0_2,
        n0: _n0_2,
        ir: _ir2,
        jr: _jr2,
        nr: _nr2,
        tauShift: 0.5,
        region: 2,
      );

  // ------------------------------------------------------------ region 5

  static const _j0_5 = [0, 1, -3, -2, -1, 2];
  static const _n0_5 = [
    -0.13179983674201e2,
    0.68540841634434e1,
    -0.24805148933466e-1,
    0.36901534980333,
    -0.31161318213925e1,
    -0.32961626538917,
  ];
  static const _ir5 = [1, 1, 1, 2, 2, 3];
  static const _jr5 = [1, 2, 3, 3, 9, 7];
  static const _nr5 = [
    0.15736404855259e-2,
    0.90153761673944e-3,
    -0.50270077677648e-2,
    0.22440037409485e-5,
    -0.41163275453471e-5,
    0.37919454822955e-7,
  ];

  /// Region 5 at ([p] MPa, [t] K).
  static SteamProperties region5(double p, double t) => _gibbsVapour(
        p: p,
        t: t,
        tauStar: 1000,
        j0: _j0_5,
        n0: _n0_5,
        ir: _ir5,
        jr: _jr5,
        nr: _nr5,
        tauShift: 0,
        region: 5,
      );

  /// Regions 2 and 5 share a form: an ideal-gas part plus a residual part
  /// of the dimensionless Gibbs free energy, differing only in coefficients.
  static SteamProperties _gibbsVapour({
    required double p,
    required double t,
    required double tauStar,
    required List<int> j0,
    required List<double> n0,
    required List<int> ir,
    required List<int> jr,
    required List<double> nr,
    required double tauShift,
    required int region,
  }) {
    final pi = p;
    final tau = tauStar / t;
    var g0 = math.log(pi), g0t = 0.0, g0tt = 0.0;
    for (var k = 0; k < n0.length; k++) {
      final j = j0[k];
      g0 += n0[k] * _pow(tau, j);
      g0t += n0[k] * j * _pow(tau, j - 1);
      g0tt += n0[k] * j * (j - 1) * _pow(tau, j - 2);
    }
    final g0p = 1 / pi;
    final b = tau - tauShift;
    var gr = 0.0, grp = 0.0, grpp = 0.0, grt = 0.0, grtt = 0.0, grpt = 0.0;
    for (var k = 0; k < nr.length; k++) {
      final n = nr[k];
      final i = ir[k];
      final j = jr[k];
      final pii = _pow(pi, i);
      final bj = _pow(b, j);
      gr += n * pii * bj;
      grp += n * i * _pow(pi, i - 1) * bj;
      grpp += n * i * (i - 1) * _pow(pi, i - 2) * bj;
      grt += n * pii * j * _pow(b, j - 1);
      grtt += n * pii * j * (j - 1) * _pow(b, j - 2);
      grpt += n * i * _pow(pi, i - 1) * j * _pow(b, j - 1);
    }
    final v = r * t / (p * 1000) * pi * (g0p + grp);
    final cross = 1 + pi * grp - tau * pi * grpt;
    final w2 = r *
        1000 *
        t *
        (1 + 2 * pi * grp + pi * pi * grp * grp) /
        ((1 - pi * pi * grpp) + cross * cross / (tau * tau * (g0tt + grtt)));
    return SteamProperties(
      pressure: p,
      temperature: t,
      specificVolume: v,
      internalEnergy: r * t * (tau * (g0t + grt) - pi * (g0p + grp)),
      entropy: r * (tau * (g0t + grt) - (g0 + gr)),
      enthalpy: r * t * tau * (g0t + grt),
      cp: -r * tau * tau * (g0tt + grtt),
      cv: r * (-tau * tau * (g0tt + grtt) - cross * cross / (1 - pi * pi * grpp)),
      speedOfSound: math.sqrt(w2),
      region: region,
    );
  }

  // ------------------------------------------------------------ region 3

  static const _n3first = 0.10658070028513e1;
  static const _i3 = [
    0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4,
    4, 5, 5, 5, 6, 6, 6, 7, 8, 9, 9, 10, 10, 11, //
  ];
  static const _j3 = [
    0, 1, 2, 7, 10, 12, 23, 2, 6, 15, 17, 0, 2, 6, 7, 22, 26, 0, 2, 4, 16, 26,
    0, 2, 4, 26, 1, 3, 26, 0, 2, 26, 2, 26, 2, 26, 0, 1, 26, //
  ];
  static const _n3 = [
    -0.15732845290239e2,
    0.20944396974307e2,
    -0.76867707878716e1,
    0.26185947787954e1,
    -0.28080781148620e1,
    0.12053369696517e1,
    -0.84566812812502e-2,
    -0.12654315477714e1,
    -0.11524407806681e1,
    0.88521043984318,
    -0.64207765181607,
    0.38493460186671,
    -0.85214708824206,
    0.48972281541877e1,
    -0.30502617256965e1,
    0.39420536879154e-1,
    0.12558408424308,
    -0.27999329698710,
    0.13899799569460e1,
    -0.20189915023570e1,
    -0.82147637173963e-2,
    -0.47596035734923,
    0.43984074473500e-1,
    -0.44476435428739,
    0.90572070719733,
    0.70522450087967,
    0.10770512626332,
    -0.32913623258954,
    -0.50871062041158,
    -0.22175400873096e-1,
    0.94260751665092e-1,
    0.16436278447961,
    -0.13503372241348e-1,
    -0.14834345352472e-1,
    0.57922953628084e-3,
    0.32308904703711e-2,
    0.80964802996215e-4,
    -0.16557679795037e-3,
    -0.44923899061815e-4,
  ];

  /// Pressure from the region 3 equation at ([rho] kg/m³, [t] K), MPa.
  static double region3Pressure(double rho, double t) {
    final delta = rho / rhoc;
    final tau = tc / t;
    var fd = _n3first / delta;
    for (var k = 0; k < _n3.length; k++) {
      final i = _i3[k];
      fd += _n3[k] * i * _pow(delta, i - 1) * _pow(tau, _j3[k]);
    }
    return rho * r * t * delta * fd / 1000;
  }

  /// Region 3 at ([rho] kg/m³, [t] K) — the region's natural variables.
  static SteamProperties region3ByDensity(double rho, double t) {
    final delta = rho / rhoc;
    final tau = tc / t;
    var f = _n3first * math.log(delta);
    var fd = _n3first / delta;
    var fdd = -_n3first / (delta * delta);
    var ft = 0.0, ftt = 0.0, fdt = 0.0;
    for (var k = 0; k < _n3.length; k++) {
      final n = _n3[k];
      final i = _i3[k];
      final j = _j3[k];
      final di = _pow(delta, i);
      final tj = _pow(tau, j);
      f += n * di * tj;
      fd += n * i * _pow(delta, i - 1) * tj;
      fdd += n * i * (i - 1) * _pow(delta, i - 2) * tj;
      ft += n * di * j * _pow(tau, j - 1);
      ftt += n * di * j * (j - 1) * _pow(tau, j - 2);
      fdt += n * i * _pow(delta, i - 1) * j * _pow(tau, j - 1);
    }
    final cross = delta * fd - delta * tau * fdt;
    final w2 = r *
        1000 *
        t *
        (2 * delta * fd + delta * delta * fdd - cross * cross / (tau * tau * ftt));
    return SteamProperties(
      pressure: rho * r * t * delta * fd / 1000,
      temperature: t,
      specificVolume: 1 / rho,
      internalEnergy: r * t * tau * ft,
      entropy: r * (tau * ft - f),
      enthalpy: r * t * (tau * ft + delta * fd),
      cp: r *
          (-tau * tau * ftt +
              cross * cross / (2 * delta * fd + delta * delta * fdd)),
      cv: -r * tau * tau * ftt,
      speedOfSound: w2 > 0 ? math.sqrt(w2) : double.nan,
      region: 3,
    );
  }

  /// Every density at which the region 3 isotherm [t] passes through [p],
  /// ascending. Below the critical temperature an isotherm through the
  /// two-phase dome has a van der Waals loop, so there can be three; the
  /// physical ones are the outermost.
  ///
  /// The search is confined to 90–800 kg/m³ on purpose. Region 3 itself only
  /// spans about 113 kg/m³ (saturated vapour at 623.15 K) to 762 kg/m³
  /// (100 MPa at 623.15 K), and beyond roughly 850 kg/m³ the fitted equation
  /// turns over and crosses every pressure a second time — a root that
  /// satisfies the algebra and describes no water that exists.
  static List<double> _region3Densities(double p, double t,
      {double lo = 90, double hi = 800}) {
    const steps = 1420;
    final roots = <double>[];
    double f(double rho) => region3Pressure(rho, t) - p;
    var a = lo;
    var fa = f(a);
    for (var k = 1; k <= steps; k++) {
      final b = lo + (hi - lo) * k / steps;
      final fb = f(b);
      if (fa == 0) {
        roots.add(a);
      } else if (fa.sign != fb.sign) {
        var x0 = a, x1 = b, f0 = fa;
        for (var it = 0; it < 80; it++) {
          final mid = (x0 + x1) / 2;
          final fm = f(mid);
          if (fm.sign == f0.sign) {
            x0 = mid;
            f0 = fm;
          } else {
            x1 = mid;
          }
          if (x1 - x0 < 1e-11) break;
        }
        roots.add((x0 + x1) / 2);
      }
      a = b;
      fa = fb;
    }
    return roots;
  }

  /// Region 3 at ([p] MPa, [t] K), solving for the density.
  static SteamProperties region3(double p, double t) {
    final roots = _region3Densities(p, t);
    if (roots.isEmpty) {
      throw const SteamRangeException('region 3 density did not converge');
    }
    final vapourSide = t < tc && p < saturationPressure(t);
    return region3ByDensity(vapourSide ? roots.first : roots.last, t);
  }

  // ------------------------------------------------------------ dispatch

  /// Which region ([p] MPa, [t] K) falls in, or throws [SteamRangeException].
  ///
  /// A point exactly on the saturation line is two-phase and has no single
  /// state; it is reported as liquid (region 1 or 3) here, and callers that
  /// care ask for [saturation] instead.
  static int regionOf(double p, double t) {
    if (p <= 0 || !p.isFinite || !t.isFinite) {
      throw const SteamRangeException('pressure must be positive');
    }
    if (t < tMin - 1e-9) throw const SteamRangeException('below 0 °C');
    if (t > tMax5) throw const SteamRangeException('above 2000 °C');
    if (t > tMax13) {
      if (p > pMax5) {
        throw const SteamRangeException('above 50 MPa at over 800 °C');
      }
      return 5;
    }
    if (p > pMax) throw const SteamRangeException('above 100 MPa');
    if (t <= 623.15) {
      return p >= saturationPressure(t) ? 1 : 2;
    }
    return p > b23Pressure(t) ? 3 : 2;
  }

  /// The single-phase state at ([p] MPa, [t] K).
  static SteamProperties state(double p, double t) =>
      switch (regionOf(p, t)) {
        1 => region1(p, t),
        2 => region2(p, t),
        3 => region3(p, t),
        _ => region5(p, t),
      };

  // ------------------------------------------------------------ saturation

  /// Saturated liquid and vapour at [t] (K), 273.15 K to [tc].
  static SaturationProperties saturationAtTemperature(double t) {
    if (t < tMin - 1e-9 || t > tc + 1e-9) {
      throw const SteamRangeException('saturation temperature out of range');
    }
    final p = t >= tc ? pc : saturationPressure(t);
    if (t <= 623.15) {
      return SaturationProperties(
        liquid: region1(p, t),
        vapour: region2(p, t),
      );
    }
    return _saturationRegion3(p, math.min(t, tc));
  }

  /// Saturated liquid and vapour at [p] (MPa), 611.213 Pa to [pc].
  static SaturationProperties saturationAtPressure(double p) {
    if (p < 611.213e-6 - 1e-12 || p > pc + 1e-9) {
      throw const SteamRangeException('saturation pressure out of range');
    }
    if (p >= pc) return _saturationRegion3(pc, tc);
    final t = saturationTemperature(p);
    if (t <= 623.15) {
      return SaturationProperties(
        liquid: region1(p, t),
        vapour: region2(p, t),
      );
    }
    return _saturationRegion3(p, t);
  }

  /// Saturated states above 623.15 K, where both lie in region 3 and have to
  /// be found as the outermost densities on the isotherm at the saturation
  /// pressure. Very close to the critical point the loop is too shallow to
  /// cross reliably, so the auxiliary saturated-density correlations of
  /// IAPWS (Wagner & Pruß) stand in — they agree with region 3 to well within
  /// the formulation's own uncertainty there.
  static SaturationProperties _saturationRegion3(double p, double t) {
    if (tc - t < 1e-6) {
      final critical = region3ByDensity(rhoc, tc);
      return SaturationProperties(liquid: critical, vapour: critical);
    }
    final roots = _region3Densities(p, t);
    final liquidRoots = roots.where((rho) => rho > rhoc).toList();
    final vapourRoots = roots.where((rho) => rho < rhoc).toList();
    final rhoL = liquidRoots.isNotEmpty
        ? liquidRoots.last
        : _auxSaturatedLiquidDensity(t);
    final rhoV = vapourRoots.isNotEmpty
        ? vapourRoots.first
        : _auxSaturatedVapourDensity(t);
    return SaturationProperties(
      liquid: region3ByDensity(rhoL, t),
      vapour: region3ByDensity(rhoV, t),
    );
  }

  static double _auxSaturatedLiquidDensity(double t) {
    final th = 1 - t / tc;
    return rhoc *
        (1 +
            1.99274064 * math.pow(th, 1 / 3) +
            1.09965342 * math.pow(th, 2 / 3) -
            0.510839303 * math.pow(th, 5 / 3) -
            1.75493479 * math.pow(th, 16 / 3) -
            45.5170352 * math.pow(th, 43 / 3) -
            6.74694450e5 * math.pow(th, 110 / 3));
  }

  static double _auxSaturatedVapourDensity(double t) {
    final th = 1 - t / tc;
    return rhoc *
        math.exp(-2.03150240 * math.pow(th, 2 / 6) -
            2.68302940 * math.pow(th, 4 / 6) -
            5.38626492 * math.pow(th, 8 / 6) -
            17.2991605 * math.pow(th, 18 / 6) -
            44.7586581 * math.pow(th, 37 / 6) -
            63.9201063 * math.pow(th, 71 / 6));
  }

  // ------------------------------------------------------------ inverses

  /// The state at [p] (MPa) with specific enthalpy [h] (kJ/kg).
  static SteamPoint stateFromPressureEnthalpy(double p, double h) =>
      _stateFromPressure(p, h, (s) => s.enthalpy);

  /// The state at [p] (MPa) with specific entropy [s] (kJ/(kg·K)).
  static SteamPoint stateFromPressureEntropy(double p, double s) =>
      _stateFromPressure(p, s, (st) => st.entropy);

  /// The wet mixture at [p] (MPa) with vapour quality [x].
  static SteamPoint stateFromPressureQuality(double p, double x) {
    if (x < 0 || x > 1) throw const SteamRangeException('quality not in 0–1');
    return SteamPoint.mixture(saturationAtPressure(p), x);
  }

  /// Solves for the temperature at which [property] reaches [target] along
  /// the isobar [p], after first checking whether the target falls inside
  /// the dome. Both enthalpy and entropy rise monotonically with temperature
  /// at constant pressure, so a bisection cannot miss.
  static SteamPoint _stateFromPressure(
    double p,
    double target,
    double Function(SteamProperties) property,
  ) {
    if (p <= 0 || p > pMax) {
      throw const SteamRangeException('pressure out of range');
    }
    var tLow = tMin;
    final tHigh = p <= pMax5 ? tMax5 : tMax13;
    if (p < pc) {
      final sat = saturationAtPressure(p);
      final f = property(sat.liquid);
      final g = property(sat.vapour);
      if (target >= f && target <= g) {
        return SteamPoint.mixture(sat, (target - f) / (g - f));
      }
      final tSat = sat.liquid.temperature;
      if (target < f) {
        return SteamPoint.single(
          _bisect(p, tLow, tSat - 1e-9, target, property),
        );
      }
      tLow = tSat + 1e-9;
    }
    return SteamPoint.single(_bisect(p, tLow, tHigh, target, property));
  }

  static SteamProperties _bisect(
    double p,
    double tLow,
    double tHigh,
    double target,
    double Function(SteamProperties) property,
  ) {
    final low = property(state(p, tLow));
    final high = property(state(p, tHigh));
    if (target < low - 1e-9 || target > high + 1e-9) {
      throw const SteamRangeException('outside the range of the formulation');
    }
    var a = tLow, b = tHigh;
    for (var it = 0; it < 100 && b - a > 1e-10; it++) {
      final mid = (a + b) / 2;
      if (property(state(p, mid)) < target) {
        a = mid;
      } else {
        b = mid;
      }
    }
    return state(p, (a + b) / 2);
  }

  /// `x` to a small integer power without going through `pow`, which is both
  /// slower and — for a negative base — no more exact.
  static double _pow(double x, int n) {
    if (n == 0) return 1;
    var result = 1.0;
    var base = n > 0 ? x : 1 / x;
    var e = n.abs();
    while (e > 0) {
      if (e & 1 == 1) result *= base;
      base *= base;
      e >>= 1;
    }
    return result;
  }
}

/// Raised for a state IAPWS-IF97 does not cover.
class SteamRangeException implements Exception {
  const SteamRangeException(this.message);
  final String message;

  @override
  String toString() => 'SteamRangeException: $message';
}

/// One single-phase state, in the formulation's units (see [If97]).
class SteamProperties {
  const SteamProperties({
    required this.pressure,
    required this.temperature,
    required this.specificVolume,
    required this.internalEnergy,
    required this.entropy,
    required this.enthalpy,
    required this.cp,
    required this.cv,
    required this.speedOfSound,
    required this.region,
  });

  /// MPa.
  final double pressure;

  /// K.
  final double temperature;

  /// m³/kg.
  final double specificVolume;

  /// kJ/kg.
  final double internalEnergy;

  /// kJ/(kg·K).
  final double entropy;

  /// kJ/kg.
  final double enthalpy;

  /// kJ/(kg·K).
  final double cp;

  /// kJ/(kg·K).
  final double cv;

  /// m/s.
  final double speedOfSound;

  /// The IF97 region the state was computed in: 1, 2, 3 or 5.
  final int region;

  /// kg/m³.
  double get density => 1 / specificVolume;
}

/// Saturated liquid and saturated vapour at one saturation temperature.
class SaturationProperties {
  const SaturationProperties({required this.liquid, required this.vapour});

  final SteamProperties liquid;
  final SteamProperties vapour;

  double get pressure => liquid.pressure;
  double get temperature => liquid.temperature;

  /// Latent heat of vaporization, kJ/kg.
  double get hfg => vapour.enthalpy - liquid.enthalpy;

  /// Entropy of vaporization, kJ/(kg·K).
  double get sfg => vapour.entropy - liquid.entropy;
}

/// A state that is either single-phase or a wet mixture of known quality.
class SteamPoint {
  SteamPoint.single(SteamProperties this.single)
      : saturation = null,
        quality = null;

  SteamPoint.mixture(SaturationProperties this.saturation, double this.quality)
      : single = null;

  final SteamProperties? single;
  final SaturationProperties? saturation;

  /// Mass fraction of vapour, 0–1, for a wet mixture; null otherwise.
  final double? quality;

  bool get isMixture => saturation != null;

  double _mix(double Function(SteamProperties) f) {
    final sat = saturation;
    if (sat == null) return f(single!);
    final x = quality!;
    return f(sat.liquid) + x * (f(sat.vapour) - f(sat.liquid));
  }

  double get pressure => single?.pressure ?? saturation!.pressure;
  double get temperature => single?.temperature ?? saturation!.temperature;
  double get specificVolume => _mix((s) => s.specificVolume);
  double get internalEnergy => _mix((s) => s.internalEnergy);
  double get enthalpy => _mix((s) => s.enthalpy);
  double get entropy => _mix((s) => s.entropy);
  double get density => 1 / specificVolume;
}
