import 'package:mechanical_engineering_toolkit/home/machine_design/model/bearing_life_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/power_screw_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/press_fit_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spur_gear_calculator.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

// Every solver below reads its inputs exactly as the tool's input page reads
// its `initialInputs` — same keys, same defaults — so that a solved value
// dropped back into that map reopens the page with it in the right field.

/// 701, helical compression spring.
final springSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('d', (l) => l.Wire_Diameter_D, category: UnitCategory.length),
    SolveQuantity('D', (l) => l.Mean_Coil_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('Na', (l) => l.Active_Coils_Na),
    SolveQuantity('G', (l) => l.Shear_Modulus_G,
        category: UnitCategory.modulus),
    SolveQuantity('F', (l) => l.Operating_Force_F,
        category: UnitCategory.force),
  ],
  outputs: [
    SolveQuantity('k', (l) => l.Spring_Rate_K,
        category: UnitCategory.distributedLoadSmall),
    SolveQuantity('tau', (l) => l.Shear_Stress_Tau,
        category: UnitCategory.stress),
    SolveQuantity('delta', (l) => l.Deflection_Delta,
        category: UnitCategory.length),
    SolveQuantity('fn', (l) => l.Natural_Frequency_Estimate,
        category: UnitCategory.frequency),
    SolveQuantity('C', (l) => l.Spring_Index_C),
    SolveQuantity('Ls', (l) => l.Solid_Height, category: UnitCategory.length),
  ],
  evaluate: (x) {
    final r = SpringDesignCalculator.calculate(SpringDesignInput(
      wireDiameter: requiredInput(x, 'd'),
      coilDiameter: requiredInput(x, 'D'),
      activeCoils: requiredInput(x, 'Na'),
      shearModulusGPa: requiredInput(x, 'G'),
      force: double.tryParse(x['F'] ?? ''),
      densityKgM3: inputValue(x, 'rho', 7850),
    ));
    return {
      'k': r.rateNPerMm,
      'fn': r.naturalFrequencyHz,
      'C': r.springIndex,
      'Ls': r.solidHeightMm,
      if (r.shearStressMPa != null) 'tau': r.shearStressMPa!,
      if (r.deflectionMm != null) 'delta': r.deflectionMm!,
    };
  },
);

/// 702, spur gear. The tooth counts are whole numbers and so are not offered
/// as inputs to solve for.
final spurGearSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('m', (l) => l.Module_M, category: UnitCategory.length),
    SolveQuantity('F', (l) => l.Face_Width_F, category: UnitCategory.length),
    SolveQuantity('Wt', (l) => l.Tangential_Load_Wt,
        category: UnitCategory.force),
  ],
  outputs: [
    SolveQuantity('sb', (l) => l.Bending_Stress_Pinion,
        category: UnitCategory.stress),
    SolveQuantity('sc', (l) => l.Contact_Stress_Est,
        category: UnitCategory.stress),
    SolveQuantity('a', (l) => l.Center_Distance, category: UnitCategory.length),
    SolveQuantity('d1', (l) => l.Pinion_Pitch_Diameter_D1,
        category: UnitCategory.length),
  ],
  evaluate: (x) {
    final r = SpurGearCalculator.calculate(SpurGearInput(
      module: requiredInput(x, 'm'),
      pinionTeeth: int.parse(x['N1']!),
      gearTeeth: int.parse(x['N2']!),
      faceWidth: requiredInput(x, 'F'),
      tangentialLoad: double.tryParse(x['Wt'] ?? ''),
      elasticCoefficient: inputValue(x, 'Cp', 191),
    ));
    return {
      'a': r.centerDistance,
      'd1': r.pinionPitchDiameter,
      if (r.bendingStressMPa != null) 'sb': r.bendingStressMPa!,
      if (r.contactStressMPa != null) 'sc': r.contactStressMPa!,
    };
  },
);

/// 703, shaft fatigue (DE-Goodman). Solving for the safety factor given a
/// diameter is the reverse question this answers most often.
final shaftFatigueSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('n', (l) => l.Target_Factor_of_Safety_N),
    SolveQuantity('Ma', (l) => l.Alternating_Moment_Ma,
        category: UnitCategory.momentSection),
    SolveQuantity('Mm', (l) => l.Mean_Moment_Mm,
        category: UnitCategory.momentSection),
    SolveQuantity('Ta', (l) => l.Alternating_Torque_Ta,
        category: UnitCategory.momentSection),
    SolveQuantity('Tm', (l) => l.Mean_Torque_Tm,
        category: UnitCategory.momentSection),
    SolveQuantity('Se', (l) => l.Endurance_Limit_Se,
        category: UnitCategory.stress),
    SolveQuantity('Sut', (l) => l.Ultimate_Strength_Sut,
        category: UnitCategory.stress),
    SolveQuantity('Kf', (l) => l.Kf_Bending),
    SolveQuantity('Kfs', (l) => l.Kfs_Torsion),
  ],
  outputs: [
    SolveQuantity('d', (l) => l.Required_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('sa', (l) => l.Von_Mises_Alternating,
        category: UnitCategory.stress),
    SolveQuantity('sm', (l) => l.Von_Mises_Mean, category: UnitCategory.stress),
  ],
  evaluate: (x) {
    final r = ShaftFatigueCalculator.calculate(ShaftFatigueInput(
      alternatingMoment: inputValue(x, 'Ma'),
      meanMoment: inputValue(x, 'Mm'),
      alternatingTorque: inputValue(x, 'Ta'),
      meanTorque: inputValue(x, 'Tm'),
      kf: inputValue(x, 'Kf', 1.6),
      kfs: inputValue(x, 'Kfs', 1.3),
      enduranceLimit: requiredInput(x, 'Se'),
      ultimateStrength: requiredInput(x, 'Sut'),
      safetyFactor: inputValue(x, 'n', 2),
    ));
    return {
      'd': r.diameterMm,
      'sa': r.alternatingVonMises,
      'sm': r.meanVonMises,
    };
  },
);

/// 704, bearing L10 life: most often, the rating C needed for a life.
final bearingLifeSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('C', (l) => l.Dynamic_Load_Rating_C,
        category: UnitCategory.forceStructural),
    SolveQuantity('P', (l) => l.Equivalent_Load_P,
        category: UnitCategory.forceStructural),
    SolveQuantity('n', (l) => l.Speed_N,
        category: UnitCategory.angularVelocity),
  ],
  outputs: [
    SolveQuantity('Lh', (l) => l.L10_Hours),
    SolveQuantity('L10', (l) => l.L10_Million_Revolutions),
  ],
  evaluate: (x) {
    final r = BearingLifeCalculator.calculate(
      dynamicLoadRating: requiredInput(x, 'C'),
      equivalentLoad: requiredInput(x, 'P'),
      type: x['Type'] == 'roller' ? BearingType.roller : BearingType.ball,
      speedRpm: requiredInput(x, 'n'),
    );
    return {'Lh': r.l10Hours, 'L10': r.l10Million};
  },
);

/// 705, belt and chain drives.
final beltDriveSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('C', (l) => l.Center_Distance_C,
        category: UnitCategory.length),
    SolveQuantity('d1', (l) => l.Small_Pulley_Diameter_D1,
        category: UnitCategory.length),
    SolveQuantity('d2', (l) => l.Large_Pulley_Diameter_D2,
        category: UnitCategory.length),
    SolveQuantity('n1', (l) => l.Input_Speed_N1,
        category: UnitCategory.angularVelocity),
    SolveQuantity('P', (l) => l.Power_Optional, category: UnitCategory.power),
  ],
  outputs: [
    SolveQuantity('L', (l) => l.Belt_Length_L, category: UnitCategory.length),
    SolveQuantity('n2', (l) => l.Output_Speed_N2,
        category: UnitCategory.angularVelocity),
    SolveQuantity('wrap', (l) => l.Wrap_Angle_Small_Pulley,
        category: UnitCategory.angle),
    SolveQuantity('T1', (l) => l.Driving_Torque_T1,
        category: UnitCategory.torque),
    SolveQuantity('Ft', (l) => l.Belt_Pull_Ft, category: UnitCategory.force),
  ],
  evaluate: (x) {
    final power = double.tryParse(x['P'] ?? '');
    final r = BeltDriveCalculator.calculate(BeltDriveInput(
      smallPulleyDiameter: requiredInput(x, 'd1'),
      largePulleyDiameter: requiredInput(x, 'd2'),
      centerDistance: requiredInput(x, 'C'),
      inputSpeedRpm: requiredInput(x, 'n1'),
      powerW: power == null ? null : power * 1000,
    ));
    return {
      'L': r.beltLength,
      'n2': r.outputSpeedRpm,
      'wrap': r.smallWrapAngleDeg,
      if (r.drivingTorqueNm != null) 'T1': r.drivingTorqueNm!,
      if (r.beltPullN != null) 'Ft': r.beltPullN!,
    };
  },
);

/// 706, bolt preload: T = K·F·d, with d in mm and T in N·m.
final boltPreloadSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('F', (l) => l.Target_Preload_F, category: UnitCategory.force),
    SolveQuantity('d', (l) => l.Nominal_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('K', (_) => 'K'),
  ],
  outputs: [
    SolveQuantity('T', (l) => l.Tightening_Torque_T,
        category: UnitCategory.torque),
  ],
  evaluate: (x) {
    final f = requiredInput(x, 'F'), d = requiredInput(x, 'd');
    final k = inputValue(x, 'K', 0.2);
    if (f <= 0 || d <= 0 || k <= 0) throw const FormatException('positive');
    return {'T': k * f * (d / 1000)};
  },
);

/// 707, fillet weld: τ = F / (0.707·w·L).
final filletWeldSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('w', (l) => l.Leg_Size_W, category: UnitCategory.length),
    SolveQuantity('L', (l) => l.Effective_Length_L,
        category: UnitCategory.length),
    SolveQuantity('F', (l) => l.Applied_Force_F, category: UnitCategory.force),
    SolveQuantity('allow', (l) => l.Allowable_Shear_Stress_Optional,
        category: UnitCategory.stress),
  ],
  outputs: [
    SolveQuantity('tau', (_) => 'Shear stress, τ',
        category: UnitCategory.stress),
    SolveQuantity('n', (l) => l.Factor_of_Safety),
  ],
  evaluate: (x) {
    final w = requiredInput(x, 'w'), l = requiredInput(x, 'L');
    final f = requiredInput(x, 'F');
    if (w <= 0 || l <= 0 || f <= 0) throw const FormatException('positive');
    final tau = f / (0.707 * w * l);
    final allow = double.tryParse(x['allow'] ?? '');
    return {
      'tau': tau,
      if (allow != null && allow > 0) 'n': allow / tau,
    };
  },
);

/// 708, press and shrink fits.
final pressFitSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('delta', (l) => l.Diametral_Interference,
        category: UnitCategory.length),
    SolveQuantity('r', (l) => l.Interface_Radius_R,
        category: UnitCategory.length),
    SolveQuantity('ro', (l) => l.Hub_Outer_Radius_Ro,
        category: UnitCategory.length),
    SolveQuantity('E', (l) => l.Modulus_E, category: UnitCategory.modulus),
  ],
  outputs: [
    SolveQuantity('p', (l) => l.Contact_Pressure_P,
        category: UnitCategory.stress),
    SolveQuantity('hoop', (l) => l.Hub_Hoop_Stress,
        category: UnitCategory.stress),
  ],
  evaluate: (x) {
    final r = PressFitCalculator.calculate(PressFitInput(
      interfaceRadius: requiredInput(x, 'r'),
      hubOuterRadius: requiredInput(x, 'ro'),
      diametralInterference: requiredInput(x, 'delta'),
      modulusGPa: requiredInput(x, 'E'),
      poissonsRatio: inputValue(x, 'nu', 0.3),
    ));
    return {'p': r.contactPressureMPa, 'hoop': r.hubHoopStressMPa};
  },
);

/// 712, power screw.
final powerScrewSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('F', (l) => l.Axial_Load_F, category: UnitCategory.force),
    SolveQuantity('d', (l) => l.Major_Diameter_D,
        category: UnitCategory.length),
    SolveQuantity('p', (l) => l.Screw_Pitch_P, category: UnitCategory.length),
    SolveQuantity('mu', (l) => l.Thread_Friction_Mu),
    SolveQuantity('muc', (l) => l.Collar_Friction_Muc),
    SolveQuantity('dc', (l) => l.Collar_Diameter_Dc,
        category: UnitCategory.length),
  ],
  outputs: [
    SolveQuantity('TR', (l) => l.Torque_To_Raise,
        category: UnitCategory.torque),
    SolveQuantity('TL', (l) => l.Torque_To_Lower,
        category: UnitCategory.torque, positive: false),
    SolveQuantity('e', (l) => '${l.Screw_Efficiency} (%)'),
  ],
  evaluate: (x) {
    var form = ThreadForm.acme;
    for (final candidate in ThreadForm.values) {
      if (candidate.name == x['form']) form = candidate;
    }
    final r = PowerScrewCalculator.calculate(PowerScrewInput(
      majorDiameter: requiredInput(x, 'd'),
      pitch: requiredInput(x, 'p'),
      load: requiredInput(x, 'F'),
      form: form,
      starts: int.tryParse(x['starts'] ?? '') ?? 1,
      threadFriction: inputValue(x, 'mu', 0.15),
      collarFriction: inputValue(x, 'muc', 0.15),
      collarDiameter: inputValue(x, 'dc'),
    ));
    return {
      'TR': r.torqueToRaise,
      'TL': r.torqueToLower,
      'e': r.efficiency * 100,
    };
  },
);
