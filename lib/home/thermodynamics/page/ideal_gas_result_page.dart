import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/ideal_gas_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/ideal_gas_page.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/thermo_widgets.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/line_plot_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class IdealGasResultPage extends StatelessWidget {
  const IdealGasResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.process,
    required this.input,
    required this.result,
  });

  final int toolId;
  final String title;
  final GasProcess process;
  final IdealGasProcessInput input;
  final IdealGasProcessResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final r = result;
    final m = r.mass;

    String f(double value, UnitCategory? category) =>
        precs.formatSI(value, category, system);
    String t(double kelvin) => f(kelvin - 273.15, UnitCategory.temperature);

    ResultSection state(String name, double p, double tK, double v, double vTotal) =>
        ResultSection(title: name, values: [
          ResultValue(label: l10n.Pressure_P, valueSI: p, category: UnitCategory.pressure),
          ResultValue(
            label: l10n.Temperature_T,
            valueSI: tK - 273.15,
            category: UnitCategory.temperature,
          ),
          ResultValue(
            label: l10n.Specific_Volume_V,
            valueSI: v,
            category: UnitCategory.specificVolume,
            smallMagnitude: true,
          ),
          ResultValue(
            label: l10n.Volume_V,
            valueSI: vTotal,
            category: UnitCategory.volume,
            smallMagnitude: true,
          ),
        ]);

    final workStep = switch (process) {
      // T must be absolute in this product, so rather than print a °C or °F
      // figure that does not multiply out, the step shows the ratio that
      // carries the process and the result.
      GasProcess.isothermal =>
        'W = m·R·T1·ln(v2/v1), v2/v1 = ${precs.formatValue(r.v2 / r.v1)}'
            ' → W = ${f(m * r.work, UnitCategory.energy)}',
      GasProcess.isobaric =>
        'W = p·(V2 − V1) = ${f(r.p1, UnitCategory.pressure)} × (${f(r.volume2, UnitCategory.volume)}'
            ' − ${f(r.volume1, UnitCategory.volume)}) = ${f(m * r.work, UnitCategory.energy)}',
      GasProcess.isochoric => 'W = 0 (V2 = V1)',
      GasProcess.isentropic =>
        'T2 = T1·(p2/p1)^((k−1)/k) = ${t(r.t2)}, k = ${precs.formatValue(r.k)}',
      GasProcess.polytropic =>
        'T2 = T1·(p2/p1)^((n−1)/n) = ${t(r.t2)}, n = ${precs.formatValue(input.n!)}',
    };
    final steps = [
      'v1 = R·T1/p1 = ${precs.formatSmallSI(r.v1, UnitCategory.specificVolume, system)}',
      'v2 = R·T2/p2 = ${precs.formatSmallSI(r.v2, UnitCategory.specificVolume, system)}',
      workStep,
      if (process == GasProcess.isentropic || process == GasProcess.polytropic)
        'W = ${f(m * r.work, UnitCategory.energy)}',
      'ΔU = m·cv·(T2 − T1) = ${f(m * r.deltaU, UnitCategory.energy)}',
      'Q = ΔU + W = ${f(m * r.heat, UnitCategory.energy)}',
      'ΔS = m·[cp·ln(T2/T1) − R·ln(p2/p1)] = ${f(m * r.deltaS, UnitCategory.entropy)}',
    ];

    final sections = [
      state(l10n.State_Numbered('1'), r.p1, r.t1, r.v1, r.volume1),
      state(l10n.State_Numbered('2'), r.p2, r.t2, r.v2, r.volume2),
      ResultSection(title: l10n.Process_Totals, values: [
        ResultValue(
            label: l10n.Boundary_Work_W, valueSI: m * r.work, category: UnitCategory.energy),
        ResultValue(
            label: l10n.Heat_Transfer_Q, valueSI: m * r.heat, category: UnitCategory.energy),
        ResultValue(
          label: l10n.Internal_Energy_Change,
          valueSI: m * r.deltaU,
          category: UnitCategory.energy,
        ),
        ResultValue(
          label: l10n.Enthalpy_Change,
          valueSI: m * r.deltaH,
          category: UnitCategory.energy,
        ),
        ResultValue(
          label: l10n.Entropy_Change,
          valueSI: m * r.deltaS,
          category: UnitCategory.entropy,
        ),
      ]),
      ResultSection(title: l10n.Per_Unit_Mass, values: [
        ResultValue(
            label: 'w', valueSI: r.work, category: UnitCategory.specificEnergy),
        ResultValue(
            label: 'q', valueSI: r.heat, category: UnitCategory.specificEnergy),
        ResultValue(
            label: 'Δu', valueSI: r.deltaU, category: UnitCategory.specificEnergy),
        ResultValue(
            label: 'Δh', valueSI: r.deltaH, category: UnitCategory.specificEnergy),
        ResultValue(
            label: 'Δs', valueSI: r.deltaS, category: UnitCategory.specificEntropy),
        ResultValue(label: l10n.Specific_Heat_Ratio_K, valueSI: r.k),
      ]),
    ];

    Offset pv(double v, double p) => plotPoint(
        v, UnitCategory.specificVolume, p, UnitCategory.pressure, system);

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: sections,
      children: [
        FormulaCard(steps: steps, tex: gasProcessTex(process)),
        LinePlotCard(
          title: l10n.Pv_Diagram,
          xAxisLabel: axisLabel('v', UnitCategory.specificVolume, system),
          yAxisLabel: axisLabel('p', UnitCategory.pressure, system),
          series: [
            PlotSeries(
              points: [for (final point in r.path) pv(point.v, point.p)],
              width: 2.5,
              label: gasProcessLabel(context, process),
            ),
          ],
          markers: [
            PlotMarker(pv(r.v1, r.p1), '1'),
            PlotMarker(pv(r.v2, r.p2), '2'),
          ],
        ),
        ResultFootnote(l10n.Ideal_Gas_Note),
      ],
    );
  }
}
