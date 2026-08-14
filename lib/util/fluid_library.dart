/// A working fluid's two flow properties, in the app's SI display units
/// (kg/m³ for density, Pa·s for dynamic viscosity), so a preset drops straight
/// into a `UnitField(category: ..., initialSI: ...)` with no conversion.
///
/// Viscosity is the property nobody remembers, and it swings four orders of
/// magnitude between air and glycerin — which is exactly why picking a fluid
/// beats typing one in.
class FluidPreset {
  const FluidPreset({
    required this.name,
    required this.densitySI,
    required this.viscositySI,
  });

  /// Includes the reference temperature: both properties are strong functions
  /// of it, so a bare "water" would be a trap.
  final String name;

  /// Density ρ, kg/m³.
  final double densitySI;

  /// Dynamic viscosity μ, Pa·s.
  final double viscositySI;
}

/// Nominal properties at 1 atm and the stated temperature, for quick
/// estimates — not a substitute for a property table at your actual
/// operating condition.
const List<FluidPreset> builtInFluids = [
  FluidPreset(name: 'Water, 20 °C', densitySI: 998.2, viscositySI: 1.002e-3),
  FluidPreset(name: 'Water, 60 °C', densitySI: 983.2, viscositySI: 4.665e-4),
  FluidPreset(name: 'Water, 90 °C', densitySI: 965.3, viscositySI: 3.150e-4),
  FluidPreset(name: 'Seawater, 20 °C', densitySI: 1025, viscositySI: 1.07e-3),
  FluidPreset(name: 'Air, 20 °C', densitySI: 1.204, viscositySI: 1.825e-5),
  FluidPreset(name: 'Air, 40 °C', densitySI: 1.127, viscositySI: 1.918e-5),
  FluidPreset(
    name: 'Engine oil (unused), 20 °C',
    densitySI: 888.1,
    viscositySI: 0.8374,
  ),
  FluidPreset(
    name: 'Engine oil (unused), 40 °C',
    densitySI: 876.1,
    viscositySI: 0.2177,
  ),
  FluidPreset(
    name: 'Ethylene glycol, 20 °C',
    densitySI: 1117,
    viscositySI: 0.0214,
  ),
  FluidPreset(name: 'Glycerin, 20 °C', densitySI: 1264, viscositySI: 1.519),
  FluidPreset(name: 'Kerosene, 20 °C', densitySI: 804, viscositySI: 1.92e-3),
  FluidPreset(name: 'Mercury, 20 °C', densitySI: 13529, viscositySI: 1.526e-3),
];
