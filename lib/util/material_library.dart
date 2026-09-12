import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'others.dart';

enum MaterialCategory { metal, plastic, other }

/// An isotropic engineering material's properties, expressed in the app's
/// SI display units (GPa for modulus, MPa for stress, kg/m³ for density —
/// the same convention [UnitField.initialSI] uses), so a preset drops
/// straight into any `UnitField(category: ..., initialSI: ...)` with no
/// extra conversion.
///
/// Not covered: composite lamina properties (E1/E2/G12/ν12) — a different
/// data shape, out of scope for this isotropic-material picker.
class MaterialPreset {
  const MaterialPreset({
    required this.name,
    required this.category,
    this.elasticModulusSI,
    this.shearModulusSI,
    this.yieldStrengthSI,
    this.ultimateStrengthSI,
    this.densitySI,
    this.poissonsRatio,
    this.isCustom = false,
  });

  final String name;
  final MaterialCategory category;

  /// Young's modulus, E — GPa.
  final double? elasticModulusSI;

  /// Shear modulus, G — GPa.
  final double? shearModulusSI;

  /// Yield strength — MPa.
  final double? yieldStrengthSI;

  /// Ultimate tensile strength — MPa.
  final double? ultimateStrengthSI;

  /// Density — kg/m³.
  final double? densitySI;

  /// Poisson's ratio, ν — dimensionless.
  final double? poissonsRatio;

  /// True for user-added presets (only these are persisted / deletable).
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'name': name,
        'category': category.name,
        'E': elasticModulusSI,
        'G': shearModulusSI,
        'yield': yieldStrengthSI,
        'ultimate': ultimateStrengthSI,
        'density': densitySI,
        'nu': poissonsRatio,
      };

  factory MaterialPreset.fromJson(Map<String, dynamic> json) => MaterialPreset(
        name: json['name'] as String,
        category: MaterialCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => MaterialCategory.other,
        ),
        elasticModulusSI: (json['E'] as num?)?.toDouble(),
        shearModulusSI: (json['G'] as num?)?.toDouble(),
        yieldStrengthSI: (json['yield'] as num?)?.toDouble(),
        ultimateStrengthSI: (json['ultimate'] as num?)?.toDouble(),
        densitySI: (json['density'] as num?)?.toDouble(),
        poissonsRatio: (json['nu'] as num?)?.toDouble(),
        isCustom: true,
      );
}

/// Curated built-in isotropic engineering materials with widely-cited
/// nominal properties, for quick estimates — not a substitute for a material
/// data sheet or spec.
const List<MaterialPreset> builtInMaterials = [
  MaterialPreset(
    name: 'Structural Steel (A36)',
    category: MaterialCategory.metal,
    elasticModulusSI: 200,
    shearModulusSI: 77,
    yieldStrengthSI: 250,
    ultimateStrengthSI: 400,
    densitySI: 7850,
    poissonsRatio: 0.26,
  ),
  MaterialPreset(
    name: 'Stainless Steel (304)',
    category: MaterialCategory.metal,
    elasticModulusSI: 193,
    shearModulusSI: 75,
    yieldStrengthSI: 215,
    ultimateStrengthSI: 505,
    densitySI: 8000,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'Aluminum (6061-T6)',
    category: MaterialCategory.metal,
    elasticModulusSI: 68.9,
    shearModulusSI: 26,
    yieldStrengthSI: 276,
    ultimateStrengthSI: 310,
    densitySI: 2700,
    poissonsRatio: 0.33,
  ),
  MaterialPreset(
    name: 'Titanium (Ti-6Al-4V)',
    category: MaterialCategory.metal,
    elasticModulusSI: 113.8,
    shearModulusSI: 44,
    yieldStrengthSI: 880,
    ultimateStrengthSI: 950,
    densitySI: 4430,
    poissonsRatio: 0.34,
  ),
  MaterialPreset(
    name: 'Gray Cast Iron',
    category: MaterialCategory.metal,
    elasticModulusSI: 110,
    shearModulusSI: 44,
    yieldStrengthSI: 130,
    ultimateStrengthSI: 200,
    densitySI: 7200,
    poissonsRatio: 0.26,
  ),
  MaterialPreset(
    name: 'Copper (C11000)',
    category: MaterialCategory.metal,
    elasticModulusSI: 117,
    shearModulusSI: 44.7,
    yieldStrengthSI: 70,
    ultimateStrengthSI: 220,
    densitySI: 8940,
    poissonsRatio: 0.34,
  ),
  MaterialPreset(
    name: 'Brass (C26000)',
    category: MaterialCategory.metal,
    elasticModulusSI: 105,
    shearModulusSI: 39,
    yieldStrengthSI: 125,
    ultimateStrengthSI: 300,
    densitySI: 8530,
    poissonsRatio: 0.33,
  ),
  // The grades a machine-design drawing calls out most often. Yield and
  // ultimate are typical values in the stated condition (MatWeb / ASM
  // Handbook), not specification minimums — check the certificate for a
  // design that runs close to either.
  MaterialPreset(
    name: 'AISI 1018 Steel (cold drawn)',
    category: MaterialCategory.metal,
    elasticModulusSI: 205,
    shearModulusSI: 80,
    yieldStrengthSI: 370,
    ultimateStrengthSI: 440,
    densitySI: 7870,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'AISI 1045 Steel (cold drawn)',
    category: MaterialCategory.metal,
    elasticModulusSI: 205,
    shearModulusSI: 80,
    yieldStrengthSI: 530,
    ultimateStrengthSI: 625,
    densitySI: 7870,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'AISI 4140 Steel (normalized)',
    category: MaterialCategory.metal,
    elasticModulusSI: 205,
    shearModulusSI: 80,
    yieldStrengthSI: 655,
    ultimateStrengthSI: 1020,
    densitySI: 7850,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'Structural Steel (A572 Gr 50)',
    category: MaterialCategory.metal,
    elasticModulusSI: 200,
    shearModulusSI: 77,
    yieldStrengthSI: 345,
    ultimateStrengthSI: 450,
    densitySI: 7850,
    poissonsRatio: 0.26,
  ),
  MaterialPreset(
    name: 'Stainless Steel (316)',
    category: MaterialCategory.metal,
    elasticModulusSI: 193,
    shearModulusSI: 75,
    yieldStrengthSI: 205,
    ultimateStrengthSI: 515,
    densitySI: 8000,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'Aluminum (2024-T3)',
    category: MaterialCategory.metal,
    elasticModulusSI: 73.1,
    shearModulusSI: 28,
    yieldStrengthSI: 345,
    ultimateStrengthSI: 483,
    densitySI: 2780,
    poissonsRatio: 0.33,
  ),
  MaterialPreset(
    name: 'Aluminum (7075-T6)',
    category: MaterialCategory.metal,
    elasticModulusSI: 71.7,
    shearModulusSI: 26.9,
    yieldStrengthSI: 503,
    ultimateStrengthSI: 572,
    densitySI: 2810,
    poissonsRatio: 0.33,
  ),
  MaterialPreset(
    name: 'Aluminum (5052-H32)',
    category: MaterialCategory.metal,
    elasticModulusSI: 70.3,
    shearModulusSI: 25.9,
    yieldStrengthSI: 193,
    ultimateStrengthSI: 228,
    densitySI: 2680,
    poissonsRatio: 0.33,
  ),
  MaterialPreset(
    name: 'Inconel 718 (aged)',
    category: MaterialCategory.metal,
    elasticModulusSI: 200,
    shearModulusSI: 77,
    yieldStrengthSI: 1100,
    ultimateStrengthSI: 1375,
    densitySI: 8190,
    poissonsRatio: 0.29,
  ),
  MaterialPreset(
    name: 'Magnesium (AZ31B-H24)',
    category: MaterialCategory.metal,
    elasticModulusSI: 45,
    shearModulusSI: 17,
    yieldStrengthSI: 220,
    ultimateStrengthSI: 290,
    densitySI: 1770,
    poissonsRatio: 0.35,
  ),
  MaterialPreset(
    name: 'Ductile Iron (65-45-12)',
    category: MaterialCategory.metal,
    elasticModulusSI: 169,
    shearModulusSI: 66,
    yieldStrengthSI: 310,
    ultimateStrengthSI: 448,
    densitySI: 7100,
    poissonsRatio: 0.28,
  ),
  MaterialPreset(
    name: 'ABS Plastic',
    category: MaterialCategory.plastic,
    elasticModulusSI: 2.3,
    shearModulusSI: 0.8,
    yieldStrengthSI: 40,
    ultimateStrengthSI: 40,
    densitySI: 1050,
    poissonsRatio: 0.35,
  ),
  MaterialPreset(
    name: 'Nylon 6/6',
    category: MaterialCategory.plastic,
    elasticModulusSI: 2.8,
    shearModulusSI: 1.0,
    yieldStrengthSI: 70,
    ultimateStrengthSI: 82,
    densitySI: 1140,
    poissonsRatio: 0.39,
  ),
  MaterialPreset(
    name: 'Polycarbonate (PC)',
    category: MaterialCategory.plastic,
    elasticModulusSI: 2.4,
    shearModulusSI: 0.88,
    yieldStrengthSI: 62,
    ultimateStrengthSI: 65,
    densitySI: 1200,
    poissonsRatio: 0.37,
  ),
  MaterialPreset(
    name: 'Acetal (POM)',
    category: MaterialCategory.plastic,
    elasticModulusSI: 2.9,
    shearModulusSI: 1.0,
    yieldStrengthSI: 65,
    ultimateStrengthSI: 70,
    densitySI: 1410,
    poissonsRatio: 0.35,
  ),
  MaterialPreset(
    name: 'Douglas Fir (along grain)',
    category: MaterialCategory.other,
    elasticModulusSI: 13.4,
    yieldStrengthSI: 40,
    ultimateStrengthSI: 50,
    densitySI: 530,
  ),
  MaterialPreset(
    name: 'Concrete (compressive)',
    category: MaterialCategory.other,
    elasticModulusSI: 25,
    ultimateStrengthSI: 30,
    densitySI: 2400,
    poissonsRatio: 0.2,
  ),
  MaterialPreset(
    name: 'Soda-lime Glass',
    category: MaterialCategory.other,
    elasticModulusSI: 70,
    ultimateStrengthSI: 50,
    densitySI: 2500,
    poissonsRatio: 0.22,
  ),
];

/// User-defined custom materials, persisted locally via SharedPreferences.
/// Built-in presets above are not stored — only user additions are.
class MaterialLibrary extends ChangeNotifier {
  static const _key = 'CUSTOM_MATERIALS';

  List<MaterialPreset> get customPresets {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    return raw.map((s) => MaterialPreset.fromJson(jsonDecode(s))).toList();
  }

  List<MaterialPreset> get all => [...builtInMaterials, ...customPresets];

  void addCustom(MaterialPreset preset) {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    raw.add(jsonEncode(preset.toJson()));
    SharedPreferencesHelper.localStorage.setStringList(_key, raw);
    notifyListeners();
  }

  void removeCustom(String name) {
    final raw = SharedPreferencesHelper.localStorage.getStringList(_key) ?? [];
    raw.removeWhere((s) => (jsonDecode(s) as Map)['name'] == name);
    SharedPreferencesHelper.localStorage.setStringList(_key, raw);
    notifyListeners();
  }
}
