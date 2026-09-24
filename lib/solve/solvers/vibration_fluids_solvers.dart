import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/beam_natural_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/shaft_critical_speed_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/torsional_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

T _named<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}

/// 709, shaft critical speed. The usual question: what diameter pushes the
/// first critical above the running speed?
final shaftCriticalSpeedSolver = ToolSolver(
  inputs: (recorded) => [
    SolveQuantity('d', (l) => l.Shaft_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('L', (l) => l.Span_L, category: UnitCategory.span),
    SolveQuantity('m', (l) => l.Rotor_Mass_M, category: UnitCategory.mass),
    SolveQuantity('a', (l) => l.Rotor_Position_A, category: UnitCategory.span),
    SolveQuantity('E', (l) => l.Elastic_Modulus_E,
        category: UnitCategory.modulus),
    if (recorded['ShaftMass'] != 'off')
      SolveQuantity('rho', (l) => l.Density, category: UnitCategory.density),
  ],
  outputs: (_) => [
    SolveQuantity('nc', (l) => l.Critical_Speed_Nc,
        category: UnitCategory.angularVelocity),
    SolveQuantity('f', (l) => l.Natural_Frequency_F,
        category: UnitCategory.frequency),
    SolveQuantity('delta', (l) => l.Static_Deflection_Delta,
        category: UnitCategory.length),
  ],
  evaluate: (x) {
    final support =
        _named(ShaftSupport.values, x['Support'], ShaftSupport.simplySupported);
    final span = requiredInput(x, 'L'), position = requiredInput(x, 'a');
    if (position <= 0 ||
        position > span ||
        (position == span && !support.allowsRotorAtEnd)) {
      throw const FormatException('rotor off the shaft');
    }
    final r = ShaftCriticalSpeedCalculator.calculate(
      modulusGPa: requiredInput(x, 'E'),
      diameterMm: requiredInput(x, 'd'),
      spanM: span,
      rotorMassKg: requiredInput(x, 'm'),
      rotorPositionM: position,
      support: support,
      densityKgM3: x['ShaftMass'] == 'off' ? null : requiredInput(x, 'rho'),
    );
    return {
      'nc': r.criticalSpeedRpm,
      'f': r.criticalFrequencyHz,
      'delta': r.staticDeflectionMm,
    };
  },
);

/// 710, beam natural frequency.
final beamNaturalFrequencySolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('L', (l) => l.Beam_Length_L, category: UnitCategory.span),
    SolveQuantity('I', (l) => l.Second_Moment_I,
        category: UnitCategory.momentOfInertia),
    SolveQuantity('A', (l) => l.Area_A, category: UnitCategory.area),
    SolveQuantity('E', (l) => l.Elastic_Modulus_E,
        category: UnitCategory.modulus),
    SolveQuantity('rho', (l) => l.Density, category: UnitCategory.density),
  ],
  outputs: [
    SolveQuantity('f', (l) => l.Natural_Frequency_F,
        category: UnitCategory.frequency),
    SolveQuantity('rpm', (l) => l.Equivalent_Shaft_Speed,
        category: UnitCategory.angularVelocity),
  ],
  evaluate: (x) {
    final r = BeamNaturalFrequencyCalculator.calculate(
      modulusGPa: requiredInput(x, 'E'),
      momentOfInertiaMm4: requiredInput(x, 'I'),
      areaMm2: requiredInput(x, 'A'),
      lengthM: requiredInput(x, 'L'),
      densityKgM3: requiredInput(x, 'rho'),
      endCondition: _named(BeamEndCondition.values, x['End Condition'],
          BeamEndCondition.values.first),
    );
    return {'f': r.fundamental.frequencyHz, 'rpm': r.fundamental.rpm};
  },
);

/// 711, torsional natural frequency.
final torsionalFrequencySolver = ToolSolver(
  inputs: (recorded) => [
    SolveQuantity('d', (l) => l.Shaft_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('L', (l) => l.Shaft_Length_L, category: UnitCategory.span),
    SolveQuantity('J1', (l) => l.Rotor_Inertia_J1,
        category: UnitCategory.massMomentOfInertia),
    if (recorded['System'] == TorsionalSystem.twoRotor.name)
      SolveQuantity('J2', (l) => l.Rotor_Inertia_J2,
          category: UnitCategory.massMomentOfInertia),
    SolveQuantity('G', (l) => l.Shear_Modulus_G,
        category: UnitCategory.modulus),
  ],
  outputs: (_) => [
    SolveQuantity('f', (l) => l.Natural_Frequency_F,
        category: UnitCategory.frequency),
    SolveQuantity('rpm', (l) => l.Equivalent_Shaft_Speed,
        category: UnitCategory.angularVelocity),
  ],
  evaluate: (x) {
    final system = _named(
        TorsionalSystem.values, x['System'], TorsionalSystem.values.first);
    final r = TorsionalFrequencyCalculator.calculate(
      shearModulusGPa: requiredInput(x, 'G'),
      diameterMm: requiredInput(x, 'd'),
      lengthM: requiredInput(x, 'L'),
      firstInertiaKgM2: requiredInput(x, 'J1'),
      secondInertiaKgM2:
          system == TorsionalSystem.twoRotor ? requiredInput(x, 'J2') : null,
      system: system,
    );
    return {'f': r.frequencyHz, 'rpm': r.frequencyHz * 60};
  },
);

/// 800, Reynolds number — whichever of velocity and flow rate was entered.
final reynoldsSolver = ToolSolver(
  inputs: (recorded) => [
    if (recorded.containsKey('V'))
      SolveQuantity('V', (l) => l.Flow_Velocity_V,
          category: UnitCategory.velocity)
    else
      SolveQuantity('Q', (l) => l.Flow_Rate_Q,
          category: UnitCategory.volumeFlow),
    SolveQuantity('D', (l) => l.Inside_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('mu', (l) => l.Dynamic_Viscosity,
        category: UnitCategory.dynamicViscosity),
    SolveQuantity('rho', (l) => l.Density, category: UnitCategory.density),
  ],
  outputs: (_) => [
    SolveQuantity('Re', (l) => l.Reynolds_Number_Re),
    SolveQuantity('V', (l) => l.Flow_Velocity_V,
        category: UnitCategory.velocity),
  ],
  evaluate: (x) {
    final velocity = double.tryParse(x['V'] ?? '');
    final r = ReynoldsCalculator.calculate(
      diameter: requiredInput(x, 'D'),
      density: requiredInput(x, 'rho'),
      viscosity: requiredInput(x, 'mu'),
      velocity: velocity,
      flowRate: velocity == null ? requiredInput(x, 'Q') : null,
    );
    return {'Re': r.reynolds, 'V': r.velocity};
  },
);

/// 801, pipe pressure drop: most often, the bore that holds the drop to a
/// budget.
final pipePressureDropSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('D', (l) => l.Inside_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('Q', (l) => l.Flow_Rate_Q, category: UnitCategory.volumeFlow),
    SolveQuantity('L', (l) => l.Pipe_Length_L, category: UnitCategory.span),
    SolveQuantity('K', (l) => l.Minor_Loss_K),
    SolveQuantity('eps', (l) => l.Wall_Roughness,
        category: UnitCategory.length),
  ],
  outputs: [
    SolveQuantity('dp', (l) => l.Pressure_Drop,
        category: UnitCategory.pressure),
    SolveQuantity('hL', (l) => l.Total_Head_Loss, category: UnitCategory.span),
    SolveQuantity('V', (l) => l.Flow_Velocity_V,
        category: UnitCategory.velocity),
  ],
  evaluate: (x) {
    final r = PipeFlowCalculator.calculate(PipeFlowInput(
      diameter: requiredInput(x, 'D'),
      length: requiredInput(x, 'L'),
      flowRate: requiredInput(x, 'Q'),
      density: requiredInput(x, 'rho'),
      viscosity: requiredInput(x, 'mu'),
      roughness: inputValue(x, 'eps', 0.045),
      minorLossK: inputValue(x, 'K'),
    ));
    return {'dp': r.pressureDrop, 'hL': r.totalHeadLoss, 'V': r.velocity};
  },
);

/// 802, pump and fan power.
final pumpPowerSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('Q', (l) => l.Flow_Rate_Q, category: UnitCategory.volumeFlow),
    SolveQuantity('dp', (l) => l.Pressure_Rise,
        category: UnitCategory.pressure),
    SolveQuantity('eta', (l) => l.Efficiency_Eta),
  ],
  outputs: [
    SolveQuantity('Ps', (l) => l.Shaft_Power, category: UnitCategory.power),
    SolveQuantity('Ph', (l) => l.Hydraulic_Power, category: UnitCategory.power),
    SolveQuantity('H', (l) => l.Pump_Head, category: UnitCategory.span),
  ],
  evaluate: (x) {
    final r = PumpPowerCalculator.calculate(
      flowRate: requiredInput(x, 'Q'),
      pressureRise: requiredInput(x, 'dp'),
      density: requiredInput(x, 'rho'),
      efficiency: inputValue(x, 'eta', 70),
    );
    return {'Ps': r.shaftPower, 'Ph': r.hydraulicPower, 'H': r.head};
  },
);

/// 811, fin efficiency.
final finSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('L', (l) => l.Fin_Length_L, category: UnitCategory.length),
    SolveQuantity('t', (l) => l.Fin_Thickness_t, category: UnitCategory.length),
    SolveQuantity('w', (l) => l.Fin_Width_w, category: UnitCategory.length),
    SolveQuantity('k', (l) => l.Conductivity_k,
        category: UnitCategory.thermalConductivity),
    SolveQuantity('h', (l) => l.Film_Coefficient_h,
        category: UnitCategory.heatTransferCoefficient),
    SolveQuantity('Tb', (l) => l.Base_Temperature,
        category: UnitCategory.temperature, positive: false),
  ],
  outputs: [
    SolveQuantity('q', (l) => l.Fin_Heat_Flow, category: UnitCategory.heatFlow),
    SolveQuantity('eta', (l) => '${l.Fin_Efficiency_Eta} (%)'),
    SolveQuantity('eps', (l) => l.Fin_Effectiveness),
    SolveQuantity('Ttip', (l) => l.Tip_Temperature,
        category: UnitCategory.temperature, positive: false),
  ],
  evaluate: (x) {
    final r = FinCalculator.calculate(
      length: requiredInput(x, 'L'),
      thickness: requiredInput(x, 't'),
      width: requiredInput(x, 'w'),
      conductivity: requiredInput(x, 'k'),
      coefficient: requiredInput(x, 'h'),
      baseTemperature: requiredInput(x, 'Tb'),
      ambientTemperature: requiredInput(x, 'Tinf'),
    );
    return {
      'q': r.heatFlow,
      'eta': r.efficiency * 100,
      'eps': r.effectiveness,
      'Ttip': r.tipTemperature,
    };
  },
);

/// 812, heat exchanger by LMTD: the area for a duty, or the duty an area
/// will carry.
final lmtdSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('Q', (l) => l.Heat_Duty_Q, category: UnitCategory.heatFlow),
    SolveQuantity('U', (l) => l.Overall_Coefficient_U,
        category: UnitCategory.heatTransferCoefficient),
    SolveQuantity('Tco', (l) => l.Cold_Outlet,
        category: UnitCategory.temperature, positive: false),
    SolveQuantity('Tho', (l) => l.Hot_Outlet,
        category: UnitCategory.temperature, positive: false),
  ],
  outputs: [
    SolveQuantity('A', (l) => l.Required_Area_A,
        category: UnitCategory.areaStructural),
    SolveQuantity('lmtd', (l) => l.Log_Mean_Delta_T,
        category: UnitCategory.temperatureDelta),
  ],
  evaluate: (x) {
    final r = LmtdCalculator.calculate(
      hotInlet: requiredInput(x, 'Thi'),
      hotOutlet: requiredInput(x, 'Tho'),
      coldInlet: requiredInput(x, 'Tci'),
      coldOutlet: requiredInput(x, 'Tco'),
      arrangement: x['Flow'] == 'parallel'
          ? FlowArrangement.parallelFlow
          : FlowArrangement.counterFlow,
      overallCoefficient: requiredInput(x, 'U'),
      heatDuty: requiredInput(x, 'Q'),
    );
    return {'A': r.area, 'lmtd': r.lmtd};
  },
);
