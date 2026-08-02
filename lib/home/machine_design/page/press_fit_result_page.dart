import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/press_fit_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PressFitResultPage extends StatelessWidget {
  const PressFitResultPage({
    super.key,
    required this.result,
    required this.r,
    required this.ro,
    required this.delta,
    required this.e,
  });

  final PressFitResult result;
  final double r;
  final double ro;
  final double delta;
  final double e;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    return ResultScaffold(
      toolName: S.of(context).Press_Shrink_Fit_Interference,
      shareLines: () => _shareLines(system, precs),
      children: [
        AppSectionCard(
          title: S.of(context).Press_Shrink_Fit_Interference,
          child: Column(children: [
            AppCopyableValue(
              label: S.of(context).Contact_Pressure_P,
              valueSI: result.contactPressureMPa,
              category: UnitCategory.stress,
            ),
            AppCopyableValue(
              label: S.of(context).Hub_Hoop_Stress,
              valueSI: result.hubHoopStressMPa,
              category: UnitCategory.stress,
            ),
            AppCopyableValue(
              label: S.of(context).Shaft_Surface_Stress,
              valueSI: result.shaftStressMPa,
              category: UnitCategory.stress,
            ),
          ]),
        ),
        FormulaCard(steps: [
          'p = E·(δ/2) / ( r·[ (ro²+r²)/(ro²−r²) + 1 ] )',
          '= ${precs.formatSI(result.contactPressureMPa, UnitCategory.stress, system)}',
          'σt,hub = p·(ro²+r²)/(ro²−r²) = ${precs.formatSI(result.hubHoopStressMPa, UnitCategory.stress, system)}',
          'σshaft = −p = ${precs.formatSI(result.shaftStressMPa, UnitCategory.stress, system)}',
        ]),
        ParameterSweepCard(
          variableLabel: S.of(context).Diametral_Interference,
          variableCategory: UnitCategory.length,
          baseValueSI: delta,
          outputLabel: S.of(context).Contact_Pressure_P,
          outputCategory: UnitCategory.stress,
          compute: (variedDelta) {
            final r2 = PressFitCalculator.calculate(PressFitInput(
              interfaceRadius: r,
              hubOuterRadius: ro,
              diametralInterference: variedDelta,
              modulusGPa: e,
            ));
            return r2.contactPressureMPa;
          },
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, NumberPrecisionHelper precs) => [
        'p = ${precs.formatSI(result.contactPressureMPa, UnitCategory.stress, system)}',
        'σt,hub = ${precs.formatSI(result.hubHoopStressMPa, UnitCategory.stress, system)}',
        'σshaft = ${precs.formatSI(result.shaftStressMPa, UnitCategory.stress, system)}',
      ];
}
