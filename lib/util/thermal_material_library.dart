/// A material's thermal conductivity, in the app's SI display unit
/// (W/(m·K)), for the conduction and fin tools.
///
/// Kept separate from `MaterialPreset` in `material_library.dart`, which
/// carries the structural properties (E, G, σy, ρ, ν) and no thermal ones:
/// the two lists overlap barely at all — nobody needs Young's modulus for
/// fibreglass batt, or a yield strength for still air in a cavity.
class ThermalMaterialPreset {
  const ThermalMaterialPreset({
    required this.name,
    required this.conductivitySI,
    required this.group,
  });

  final String name;

  /// Thermal conductivity k, W/(m·K).
  final double conductivitySI;

  /// Coarse grouping used to order the picker: metals conduct, insulators
  /// resist, and the building materials sit in between.
  final ThermalMaterialGroup group;
}

enum ThermalMaterialGroup { metal, building, insulation }

/// Nominal values near room temperature, for quick estimates — conductivity
/// varies with temperature, alloy, moisture content and density, so a real
/// design uses the figure from the actual product's data sheet.
const List<ThermalMaterialPreset> builtInThermalMaterials = [
  // Metals
  ThermalMaterialPreset(
    name: 'Copper',
    conductivitySI: 401,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Aluminum (pure)',
    conductivitySI: 237,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Aluminum (6061-T6)',
    conductivitySI: 167,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Brass (70Cu-30Zn)',
    conductivitySI: 110,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Carbon steel',
    conductivitySI: 60.5,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Cast iron',
    conductivitySI: 52,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Titanium',
    conductivitySI: 21.9,
    group: ThermalMaterialGroup.metal,
  ),
  ThermalMaterialPreset(
    name: 'Stainless steel (304)',
    conductivitySI: 14.9,
    group: ThermalMaterialGroup.metal,
  ),
  // Building materials
  ThermalMaterialPreset(
    name: 'Concrete (stone mix)',
    conductivitySI: 1.4,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'Glass (plate)',
    conductivitySI: 0.78,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'Brick (common)',
    conductivitySI: 0.72,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'Water (still)',
    conductivitySI: 0.607,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'PVC',
    conductivitySI: 0.19,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'Gypsum board',
    conductivitySI: 0.17,
    group: ThermalMaterialGroup.building,
  ),
  ThermalMaterialPreset(
    name: 'Softwood (pine)',
    conductivitySI: 0.12,
    group: ThermalMaterialGroup.building,
  ),
  // Insulation
  ThermalMaterialPreset(
    name: 'Fiberglass batt',
    conductivitySI: 0.043,
    group: ThermalMaterialGroup.insulation,
  ),
  ThermalMaterialPreset(
    name: 'Mineral wool',
    conductivitySI: 0.040,
    group: ThermalMaterialGroup.insulation,
  ),
  ThermalMaterialPreset(
    name: 'Expanded polystyrene',
    conductivitySI: 0.036,
    group: ThermalMaterialGroup.insulation,
  ),
  ThermalMaterialPreset(
    name: 'Polyurethane foam (rigid)',
    conductivitySI: 0.026,
    group: ThermalMaterialGroup.insulation,
  ),
  ThermalMaterialPreset(
    name: 'Air (still, cavity)',
    conductivitySI: 0.026,
    group: ThermalMaterialGroup.insulation,
  ),
];
