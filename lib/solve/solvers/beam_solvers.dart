import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/curved_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/curved_beam_page.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// Curved beam: any dimension of the section, the inner radius, or the load,
/// against either fibre stress.
final curvedBeamSolver = ToolSolver(
  inputs: (recorded) {
    final input = curvedBeamInputFrom(recorded);
    SolveQuantity length(String key, String Function(S l) label) =>
        SolveQuantity(key, label, category: UnitCategory.length);
    return [
      length(CurvedBeamKeys.ri, (l) => l.Inner_Radius_Ri),
      ...switch (input.section) {
        CurvedSection.rectangle => [
            length(CurvedBeamKeys.h, (l) => l.Radial_Depth_H),
            length(CurvedBeamKeys.b, (l) => l.Section_Width_b),
          ],
        CurvedSection.trapezoid => [
            length(CurvedBeamKeys.h, (l) => l.Radial_Depth_H),
            length(CurvedBeamKeys.bi, (l) => l.Inner_Width_Bi),
            length(CurvedBeamKeys.bo, (l) => l.Outer_Width_Bo),
          ],
        CurvedSection.circle => [length(CurvedBeamKeys.d, (l) => l.Diameter_D)],
        CurvedSection.tube => [
            length(CurvedBeamKeys.d, (l) => l.Diameter_D),
            length(CurvedBeamKeys.di, (l) => l.Bore_Diameter_Di),
          ],
        CurvedSection.tSection => [
            length(CurvedBeamKeys.h, (l) => l.Radial_Depth_H),
            length(CurvedBeamKeys.bf, (l) => l.Flange_Width_Bf),
            length(CurvedBeamKeys.tf, (l) => l.Flange_Thickness_Tf),
            length(CurvedBeamKeys.tw, (l) => l.Web_Thickness_Tw),
          ],
        CurvedSection.iSection => [
            length(CurvedBeamKeys.h, (l) => l.Radial_Depth_H),
            length(CurvedBeamKeys.bf, (l) => l.Inner_Flange_Width_B1),
            length(CurvedBeamKeys.tf, (l) => l.Inner_Flange_Thickness_T1),
            length(CurvedBeamKeys.b2, (l) => l.Outer_Flange_Width_B2),
            length(CurvedBeamKeys.t2, (l) => l.Outer_Flange_Thickness_T2),
            length(CurvedBeamKeys.tw, (l) => l.Web_Thickness_Tw),
          ],
      },
      if (input.loading == CurvedBeamLoading.moment)
        SolveQuantity(CurvedBeamKeys.m, (l) => l.Bending_Moment_Straightening,
            category: UnitCategory.momentSection, positive: false),
      SolveQuantity(
        CurvedBeamKeys.n,
        (l) => input.loading == CurvedBeamLoading.hook
            ? l.Hook_Load_F
            : l.Normal_Force_N,
        category: UnitCategory.force,
        positive: false,
      ),
    ];
  },
  outputs: (_) => [
    SolveQuantity('sigmaI', (l) => l.Inner_Fibre_Stress,
        category: UnitCategory.stress, positive: false),
    SolveQuantity('sigmaO', (l) => l.Outer_Fibre_Stress,
        category: UnitCategory.stress, positive: false),
    SolveQuantity('e', (l) => l.Eccentricity_E, category: UnitCategory.length),
  ],
  evaluate: (inputs) {
    final result = CurvedBeamCalculator.calculate(curvedBeamInputFrom(inputs));
    return {
      'sigmaI': result.inner.total,
      'sigmaO': result.outer.total,
      'e': result.eccentricity,
    };
  },
);
