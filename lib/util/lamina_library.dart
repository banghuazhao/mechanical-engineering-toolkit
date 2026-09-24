/// A unidirectional composite lamina's in-plane elastic constants and
/// strengths, in the app's SI display units: GPa for moduli, MPa for
/// strengths.
///
/// The isotropic [MaterialPreset] cannot carry these — a lamina has two
/// moduli, a shear modulus and five strengths, not one of each — so the
/// composite tools get their own library.
class LaminaPreset {
  const LaminaPreset({
    required this.name,
    required this.e1,
    required this.e2,
    required this.g12,
    required this.nu12,
    this.xt,
    this.xc,
    this.yt,
    this.yc,
    this.s,
    this.isCustom = false,
  });

  final String name;

  /// Longitudinal and transverse Young's moduli, GPa.
  final double e1, e2;

  /// In-plane shear modulus, GPa.
  final double g12;

  /// Major Poisson's ratio.
  final double nu12;

  /// Fibre-direction tensile and compressive strengths, MPa.
  ///
  /// The strengths are optional so a user-defined lamina can be saved from
  /// its elastic constants alone — a data sheet often quotes those without
  /// allowables. Every built-in preset carries all five.
  final double? xt, xc;

  /// Transverse tensile and compressive strengths, MPa.
  final double? yt, yc;

  /// In-plane shear strength, MPa.
  final double? s;

  /// True for a lamina the user added; only those are stored and editable.
  final bool isCustom;

  LaminaPreset copyWith({String? name}) => LaminaPreset(
        name: name ?? this.name,
        e1: e1,
        e2: e2,
        g12: g12,
        nu12: nu12,
        xt: xt,
        xc: xc,
        yt: yt,
        yc: yc,
        s: s,
        isCustom: true,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'E1': e1,
        'E2': e2,
        'G12': g12,
        'nu12': nu12,
        'Xt': xt,
        'Xc': xc,
        'Yt': yt,
        'Yc': yc,
        'S': s,
      };

  factory LaminaPreset.fromJson(Map<String, dynamic> json) => LaminaPreset(
        name: json['name'] as String,
        e1: (json['E1'] as num).toDouble(),
        e2: (json['E2'] as num).toDouble(),
        g12: (json['G12'] as num).toDouble(),
        nu12: (json['nu12'] as num).toDouble(),
        xt: (json['Xt'] as num?)?.toDouble(),
        xc: (json['Xc'] as num?)?.toDouble(),
        yt: (json['Yt'] as num?)?.toDouble(),
        yc: (json['Yc'] as num?)?.toDouble(),
        s: (json['S'] as num?)?.toDouble(),
        isCustom: true,
      );
}

/// The five materials of Tsai & Hahn's *Introduction to Composite Materials*
/// (1980), table 1.1 — the set most composites coursework, Kaw's text
/// included, is worked in. Typical values for estimates and exercises, not a
/// supplier's allowables.
///
/// ν23 is deliberately absent: the source does not publish it, and a guessed
/// value would pass for a measured one. Tools that need it keep whatever the
/// user entered.
const List<LaminaPreset> builtInLaminae = [
  LaminaPreset(
    name: 'T300/5208 carbon/epoxy',
    e1: 181,
    e2: 10.3,
    g12: 7.17,
    nu12: 0.28,
    xt: 1500,
    xc: 1500,
    yt: 40,
    yc: 246,
    s: 68,
  ),
  LaminaPreset(
    name: 'AS/3501 carbon/epoxy',
    e1: 138,
    e2: 8.96,
    g12: 7.1,
    nu12: 0.30,
    xt: 1447,
    xc: 1447,
    yt: 51.7,
    yc: 206,
    s: 93,
  ),
  LaminaPreset(
    name: 'B(4)/5505 boron/epoxy',
    e1: 204,
    e2: 18.5,
    g12: 5.59,
    nu12: 0.23,
    xt: 1260,
    xc: 2500,
    yt: 61,
    yc: 202,
    s: 67,
  ),
  LaminaPreset(
    name: 'Scotchply 1002 E-glass/epoxy',
    e1: 38.6,
    e2: 8.27,
    g12: 4.14,
    nu12: 0.26,
    xt: 1062,
    xc: 610,
    yt: 31,
    yc: 118,
    s: 72,
  ),
  LaminaPreset(
    name: 'Kevlar 49/epoxy',
    e1: 76,
    e2: 5.5,
    g12: 2.3,
    nu12: 0.34,
    xt: 1400,
    xc: 235,
    yt: 12,
    yc: 53,
    s: 34,
  ),
];
