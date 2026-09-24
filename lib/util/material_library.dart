import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'fluid_library.dart';
import 'lamina_library.dart';
import 'others.dart';
import 'thermal_material_library.dart';

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

  MaterialPreset copyWith({String? name}) => MaterialPreset(
        name: name ?? this.name,
        category: category,
        elasticModulusSI: elasticModulusSI,
        shearModulusSI: shearModulusSI,
        yieldStrengthSI: yieldStrengthSI,
        ultimateStrengthSI: ultimateStrengthSI,
        densitySI: densitySI,
        poissonsRatio: poissonsRatio,
        isCustom: true,
      );

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

/// One library's user-defined entries, persisted as a list of JSON strings
/// under [storageKey].
///
/// Built-in presets are never stored — only what the user added — so a later
/// release can correct a built-in value without fighting a stale copy.
///
/// Entries are addressed by index rather than by name. Names are kept unique
/// from here on (see [MaterialLibrary.isNameTaken]), but a list saved before
/// that check existed may hold two entries with one name, and deleting one of
/// them must not take the other with it.
class CustomPresetList<T> {
  CustomPresetList._({
    required this.storageKey,
    required this.encode,
    required this.decode,
    required this.nameOf,
    required VoidCallback onChanged,
  }) : _onChanged = onChanged;

  final String storageKey;
  final Map<String, dynamic> Function(T preset) encode;
  final T Function(Map<String, dynamic> json) decode;
  final String Function(T preset) nameOf;
  final VoidCallback _onChanged;

  List<String> get _raw =>
      SharedPreferencesHelper.localStorage.getStringList(storageKey) ?? [];

  void _write(List<String> raw) {
    SharedPreferencesHelper.localStorage.setStringList(storageKey, raw);
    _onChanged();
  }

  /// The stored entries, oldest first. An entry that no longer decodes — a
  /// hand-edited backup, say — is skipped rather than taking the whole list
  /// down with it.
  List<T> get items {
    final result = <T>[];
    for (final entry in _raw) {
      final value = _tryDecode(entry);
      if (value != null) result.add(value);
    }
    return result;
  }

  T? _tryDecode(String entry) {
    try {
      return decode(jsonDecode(entry) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  void add(T preset) => _write([..._raw, jsonEncode(encode(preset))]);

  /// Replaces the entry at [index] in [items].
  void replaceAt(int index, T preset) {
    final raw = _raw;
    final rawIndex = _rawIndexOf(raw, index);
    if (rawIndex == null) return;
    raw[rawIndex] = jsonEncode(encode(preset));
    _write(raw);
  }

  /// Removes the entry at [index] in [items].
  void removeAt(int index) {
    final raw = _raw;
    final rawIndex = _rawIndexOf(raw, index);
    if (rawIndex == null) return;
    raw.removeAt(rawIndex);
    _write(raw);
  }

  /// Maps an index in [items] — which skips undecodable entries — back to
  /// the stored list.
  int? _rawIndexOf(List<String> raw, int index) {
    var seen = -1;
    for (var i = 0; i < raw.length; i++) {
      if (_tryDecode(raw[i]) == null) continue;
      seen++;
      if (seen == index) return i;
    }
    return null;
  }
}

/// The four preset libraries a calculator can fill its inputs from, and the
/// entries the user has added to each, persisted locally via
/// SharedPreferences.
///
/// Built-ins live in each library's own file as `const` lists; this object
/// only holds what is editable. The isotropic list keeps the storage key and
/// JSON shape it has had since custom materials first shipped, so entries
/// saved by an older release are still there.
class MaterialLibrary extends ChangeNotifier {
  MaterialLibrary() {
    isotropic = CustomPresetList._(
      storageKey: 'CUSTOM_MATERIALS',
      encode: (m) => m.toJson(),
      decode: MaterialPreset.fromJson,
      nameOf: (m) => m.name,
      onChanged: notifyListeners,
    );
    laminae = CustomPresetList._(
      storageKey: 'CUSTOM_LAMINAE',
      encode: (l) => l.toJson(),
      decode: LaminaPreset.fromJson,
      nameOf: (l) => l.name,
      onChanged: notifyListeners,
    );
    fluids = CustomPresetList._(
      storageKey: 'CUSTOM_FLUIDS',
      encode: (f) => f.toJson(),
      decode: FluidPreset.fromJson,
      nameOf: (f) => f.name,
      onChanged: notifyListeners,
    );
    thermal = CustomPresetList._(
      storageKey: 'CUSTOM_THERMAL_MATERIALS',
      encode: (t) => t.toJson(),
      decode: ThermalMaterialPreset.fromJson,
      nameOf: (t) => t.name,
      onChanged: notifyListeners,
    );
  }

  late final CustomPresetList<MaterialPreset> isotropic;
  late final CustomPresetList<LaminaPreset> laminae;
  late final CustomPresetList<FluidPreset> fluids;
  late final CustomPresetList<ThermalMaterialPreset> thermal;

  List<MaterialPreset> get customPresets => isotropic.items;

  List<MaterialPreset> get all => [...builtInMaterials, ...isotropic.items];

  List<LaminaPreset> get allLaminae => [...builtInLaminae, ...laminae.items];

  List<FluidPreset> get allFluids => [...builtInFluids, ...fluids.items];

  List<ThermalMaterialPreset> get allThermal =>
      [...builtInThermalMaterials, ...thermal.items];

  void addCustom(MaterialPreset preset) => isotropic.add(preset);

  /// Whether [name] already names an entry — built-in or custom — in the
  /// library [builtIn] and [custom] describe, ignoring case and surrounding
  /// space. Pass [exceptIndex] when renaming custom entry [exceptIndex], so
  /// it does not collide with itself.
  static bool isNameTaken<T>(
    String name, {
    required List<T> builtIn,
    required CustomPresetList<T> custom,
    int? exceptIndex,
  }) {
    final wanted = name.trim().toLowerCase();
    for (final preset in builtIn) {
      if (custom.nameOf(preset).trim().toLowerCase() == wanted) return true;
    }
    final items = custom.items;
    for (var i = 0; i < items.length; i++) {
      if (i == exceptIndex) continue;
      if (custom.nameOf(items[i]).trim().toLowerCase() == wanted) return true;
    }
    return false;
  }

  /// Every custom entry, as one JSON document a user can keep or move to
  /// another device.
  String exportJson() => const JsonEncoder.withIndent('  ').convert({
        'format': exportFormat,
        'version': 1,
        'isotropic': [for (final m in isotropic.items) m.toJson()],
        'laminae': [for (final l in laminae.items) l.toJson()],
        'fluids': [for (final f in fluids.items) f.toJson()],
        'thermal': [for (final t in thermal.items) t.toJson()],
      });

  /// Tags an export so an import can tell it from any other JSON on the
  /// clipboard.
  static const exportFormat = 'me-toolkit-materials';

  /// Adds the entries of an [exportJson] document.
  ///
  /// An entry whose name is already taken in its library is skipped rather
  /// than renamed or overwritten: importing the same backup twice should
  /// change nothing the second time. Throws [FormatException] when [source]
  /// is not an export at all.
  ({int added, int skipped}) importJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source.trim());
    } on FormatException {
      throw const FormatException('Not a materials export');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded['format'] != exportFormat) {
      throw const FormatException('Not a materials export');
    }

    var added = 0;
    var skipped = 0;
    void merge<T>(String key, List<T> builtIn, CustomPresetList<T> custom) {
      final entries = decoded as Map<String, dynamic>;
      final list = entries[key];
      if (list is! List) return;
      for (final entry in list) {
        T preset;
        try {
          preset = custom.decode(Map<String, dynamic>.from(entry as Map));
        } catch (_) {
          skipped++;
          continue;
        }
        if (isNameTaken(custom.nameOf(preset),
            builtIn: builtIn, custom: custom)) {
          skipped++;
          continue;
        }
        custom.add(preset);
        added++;
      }
    }

    merge('isotropic', builtInMaterials, isotropic);
    merge('laminae', builtInLaminae, laminae);
    merge('fluids', builtInFluids, fluids);
    merge('thermal', builtInThermalMaterials, thermal);
    return (added: added, skipped: skipped);
  }
}
