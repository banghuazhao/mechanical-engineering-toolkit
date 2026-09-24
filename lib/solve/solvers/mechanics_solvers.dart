import 'dart:math' as math;

import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

// These tools compute on their input page rather than in a model class, so
// each solver restates the page's one-line formula — with the same unit
// handling: E and G are entered in GPa and used as MPa (× 1000) so that mm,
// N and MPa stay consistent. The labels are the page's own, which are not
// yet localized.

/// 100, σ = F / A.
final generalStressSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('A', (_) => 'Area, A', category: UnitCategory.area),
    SolveQuantity('F', (_) => 'Force, F',
        category: UnitCategory.force, positive: false),
  ],
  outputs: [
    SolveQuantity('sigma', (_) => 'Stress, σ',
        category: UnitCategory.stress, positive: false),
  ],
  evaluate: (x) {
    final a = requiredInput(x, 'A');
    if (a <= 0) throw const FormatException('area');
    return {'sigma': requiredInput(x, 'F') / a};
  },
);

/// 101, δ = F·L / (E·A).
final barForceDisplacementSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('A', (_) => 'Area, A', category: UnitCategory.area),
    SolveQuantity('L', (_) => 'Length, L', category: UnitCategory.length),
    SolveQuantity('F', (_) => 'Force, F',
        category: UnitCategory.force, positive: false),
    SolveQuantity('E', (_) => 'Modulus, E', category: UnitCategory.modulus),
  ],
  outputs: [
    SolveQuantity('delta', (_) => 'Displacement, δ',
        category: UnitCategory.length, positive: false),
  ],
  evaluate: (x) {
    final l = requiredInput(x, 'L'), e = requiredInput(x, 'E');
    final a = requiredInput(x, 'A');
    if (l <= 0 || e <= 0 || a <= 0) throw const FormatException('positive');
    return {'delta': requiredInput(x, 'F') * l / (e * 1000 * a)};
  },
);

/// 103, τ = T·r / Ip.
final torsionFormulaSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('r', (_) => 'Radius, r', category: UnitCategory.length),
    SolveQuantity('Ip', (_) => 'Polar moment, Ip',
        category: UnitCategory.momentOfInertia),
    SolveQuantity('T', (_) => 'Torque, T',
        category: UnitCategory.momentSection, positive: false),
  ],
  outputs: [
    SolveQuantity('tau', (_) => 'Maximum shear stress, τ_max',
        category: UnitCategory.stress, positive: false),
  ],
  evaluate: (x) {
    final r = requiredInput(x, 'r'), ip = requiredInput(x, 'Ip');
    if (r <= 0 || ip <= 0) throw const FormatException('positive');
    return {'tau': requiredInput(x, 'T') * r / ip};
  },
);

/// 104, σ = −M·y / I, at the distance y the user gave.
final flexureSolver = ToolSolver(
  inputs: (recorded) => [
    SolveQuantity('I', (_) => 'Moment of inertia, I',
        category: UnitCategory.momentOfInertia),
    SolveQuantity('M', (_) => 'Moment, M',
        category: UnitCategory.momentSection, positive: false),
    SolveQuantity('y', (_) => 'Distance, y (optional)',
        category: UnitCategory.length, positive: false),
  ],
  outputs: (recorded) => [
    SolveQuantity('sigma', (_) => 'Stress, σ(y)',
        category: UnitCategory.stress, positive: false),
  ],
  evaluate: (x) {
    final i = requiredInput(x, 'I');
    if (i <= 0) throw const FormatException('positive');
    final y = double.tryParse(x['y'] ?? '');
    if (y == null) return const {};
    return {'sigma': -requiredInput(x, 'M') * y / i};
  },
);

/// The effective-length factors the buckling page stores by label.
const _bucklingC = {
  'Pinned-pinned column': 1.0,
  'Fixed-free column': 0.25,
  'Fixed-fixed column': 4.0,
  'Fixed-pinned column': 2.046,
};

/// 111, Pcr = C·π²·E·I / L².
final bucklingSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('I', (_) => 'Moment of inertia, I',
        category: UnitCategory.momentOfInertia),
    SolveQuantity('L', (_) => 'Length, L', category: UnitCategory.length),
    SolveQuantity('E', (_) => 'Modulus, E', category: UnitCategory.modulus),
  ],
  outputs: [
    SolveQuantity('Pcr', (_) => 'Buckling load, Pcr',
        category: UnitCategory.force),
  ],
  evaluate: (x) {
    final e = requiredInput(x, 'E'), i = requiredInput(x, 'I');
    final l = requiredInput(x, 'L');
    if (e <= 0 || i <= 0 || l <= 0) throw const FormatException('positive');
    final c = _bucklingC[x['End Condition']] ?? 1.0;
    return {'Pcr': c * math.pi * math.pi * (e * 1000) * i / (l * l)};
  },
);

/// 114, φ = T·L / (G·J).
final angleOfTwistSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('J', (_) => 'Polar moment, J',
        category: UnitCategory.momentOfInertia),
    SolveQuantity('L', (_) => 'Length, L', category: UnitCategory.length),
    SolveQuantity('T', (_) => 'Torque, T',
        category: UnitCategory.momentSection, positive: false),
    SolveQuantity('G', (_) => 'Shear modulus, G',
        category: UnitCategory.modulus),
  ],
  outputs: [
    SolveQuantity('phi', (_) => 'Angle, φ (degrees)',
        category: UnitCategory.angle, positive: false),
  ],
  evaluate: (x) {
    final g = requiredInput(x, 'G'), j = requiredInput(x, 'J');
    if (g == 0 || j == 0) throw const FormatException('nonzero');
    final phi = requiredInput(x, 'T') * requiredInput(x, 'L') / (g * 1000 * j);
    return {'phi': phi * 180 / math.pi};
  },
);

/// 115, P = T·ω, in whichever direction the page was run.
final shaftPowerTorqueSolver = ToolSolver(
  inputs: (recorded) => [
    if (recorded['Mode'] == 'power')
      SolveQuantity('T', (_) => 'Torque, T', category: UnitCategory.torque)
    else
      SolveQuantity('P', (_) => 'Power, P', category: UnitCategory.power),
    SolveQuantity('n', (_) => 'Rotational speed, n',
        category: UnitCategory.angularVelocity),
  ],
  outputs: (recorded) => [
    if (recorded['Mode'] == 'power')
      SolveQuantity('P', (_) => 'Power, P', category: UnitCategory.power)
    else
      SolveQuantity('T', (_) => 'Torque, T', category: UnitCategory.torque),
  ],
  evaluate: (x) {
    final rpm = requiredInput(x, 'n');
    if (rpm <= 0) throw const FormatException('speed');
    final omega = 2 * math.pi * rpm / 60;
    if (x['Mode'] == 'power') {
      // Output in kW, the power category's SI display unit.
      return {'P': requiredInput(x, 'T') * omega / 1000};
    }
    return {'T': requiredInput(x, 'P') * 1000 / omega};
  },
);

/// 119, modified Goodman: n = 1 / (σa/Se + σm/Su).
final fatigueSafetyFactorSolver = ToolSolver.fixed(
  inputs: [
    SolveQuantity('σa', (_) => 'Alternating stress, σa',
        category: UnitCategory.stress),
    SolveQuantity('σm', (_) => 'Mean stress, σm',
        category: UnitCategory.stress),
    SolveQuantity('Su', (_) => 'Ultimate strength, Su',
        category: UnitCategory.stress),
    SolveQuantity('Se', (_) => 'Endurance limit, Se (optional)',
        category: UnitCategory.stress),
  ],
  outputs: [
    SolveQuantity('n', (_) => 'Factor of safety, n'),
  ],
  evaluate: (x) {
    final sa = requiredInput(x, 'σa'), sm = requiredInput(x, 'σm');
    final su = requiredInput(x, 'Su');
    if (sa < 0 || sm < 0 || su <= 0) throw const FormatException('range');
    final given = double.tryParse(x['Se'] ?? '');
    final se = (given == null || given == 0) ? 0.5 * su : given;
    if (se <= 0) throw const FormatException('Se');
    return {'n': 1 / (sa / se + sm / su)};
  },
);
