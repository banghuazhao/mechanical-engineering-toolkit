import 'package:mechanical_engineering_toolkit/solve/solvers/beam_solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers/machine_design_solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers/mechanics_solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers/thermodynamics_solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers/vibration_fluids_solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';

/// Every tool that can be solved backwards, by tool id.
///
/// A tool missing from here simply shows no Solve For card. Left out on
/// purpose: tools whose inputs are lists (a truss, a frame, a beam's loads,
/// a laminate's layup, a tolerance chain), which have no single number to
/// vary; lookups (the reference tables, steam tables); and the tensor tools,
/// whose answer is a matrix rather than a quantity to aim at.
final Map<int, ToolSolver> toolSolvers = {
  // Mechanics of Material
  100: generalStressSolver,
  101: barForceDisplacementSolver,
  103: torsionFormulaSolver,
  104: flexureSolver,
  111: bucklingSolver,
  114: angleOfTwistSolver,
  115: shaftPowerTorqueSolver,
  119: fatigueSafetyFactorSolver,
  // Beam Engineering
  122: curvedBeamSolver,
  // Machine Design
  701: springSolver,
  702: spurGearSolver,
  703: shaftFatigueSolver,
  704: bearingLifeSolver,
  705: beltDriveSolver,
  706: boltPreloadSolver,
  707: filletWeldSolver,
  708: pressFitSolver,
  709: shaftCriticalSpeedSolver,
  710: beamNaturalFrequencySolver,
  711: torsionalFrequencySolver,
  712: powerScrewSolver,
  // Fluids & Thermal
  800: reynoldsSolver,
  801: pipePressureDropSolver,
  802: pumpPowerSolver,
  811: finSolver,
  812: lmtdSolver,
  // Thermodynamics
  902: airCycleSolver,
  903: rankineSolver,
};
