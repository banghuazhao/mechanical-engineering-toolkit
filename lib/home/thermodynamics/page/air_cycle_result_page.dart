import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/air_standard_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_page.dart';
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

class AirCycleResultPage extends StatelessWidget {
  const AirCycleResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.input,
    required this.result,
  });

  final int toolId;
  final String title;
  final AirCycleInput input;
  final AirCycleResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final r = result;
    final k = input.k;
    final cv = input.cp / k;

    String f(double value, UnitCategory? category) =>
        precs.formatSI(value, category, system);
    String pct(double fraction) => '${precs.formatValue(fraction * 100)} %';

    const columns = [
      StateColumn('T', UnitCategory.temperature),
      StateColumn('p', UnitCategory.pressure),
      StateColumn('v', UnitCategory.specificVolume),
      StateColumn('s − s₁', UnitCategory.specificEntropy),
    ];
    final rows = [
      for (var i = 0; i < r.states.length; i++)
        StateRow('${i + 1}', [
          r.states[i].t - 273.15,
          r.states[i].p,
          r.states[i].v,
          r.states[i].s,
        ]),
    ];

    final s = r.states;
    final steps = <String>[
      ...switch (r.cycle) {
        AirCycle.otto => [
            'T2 = T1·r^(k−1) = ${f(s[1].t - 273.15, UnitCategory.temperature)}',
            'q_in = cv·(T3 − T2) = ${f(r.heatIn, UnitCategory.specificEnergy)}',
            'T4 = T3 / r^(k−1) = ${f(s[3].t - 273.15, UnitCategory.temperature)}',
            'q_out = cv·(T4 − T1) = ${f(r.heatOut, UnitCategory.specificEnergy)}',
            'η = 1 − 1/r^(k−1) = ${pct(r.efficiency)}',
          ],
        AirCycle.diesel => [
            'T2 = T1·r^(k−1) = ${f(s[1].t - 273.15, UnitCategory.temperature)}',
            'T3 = T2·rc = ${f(s[2].t - 273.15, UnitCategory.temperature)}',
            'q_in = cp·(T3 − T2) = ${f(r.heatIn, UnitCategory.specificEnergy)}',
            'T4 = T3·(rc/r)^(k−1) = ${f(s[3].t - 273.15, UnitCategory.temperature)}',
            'q_out = cv·(T4 − T1) = ${f(r.heatOut, UnitCategory.specificEnergy)}',
            'η = 1 − (1/r^(k−1))·(rc^k − 1)/(k·(rc − 1)) = ${pct(r.efficiency)}',
          ],
        AirCycle.brayton => [
            'T2 = T1 + T1·(rp^((k−1)/k) − 1)/ηc = ${f(s[1].t - 273.15, UnitCategory.temperature)}',
            'T4 = T3 − ηt·T3·(1 − rp^((1−k)/k)) = ${f(s[3].t - 273.15, UnitCategory.temperature)}',
            'w_c = cp·(T2 − T1) = ${f(r.compressionWork, UnitCategory.specificEnergy)}',
            'w_t = cp·(T3 − T4) = ${f(r.expansionWork, UnitCategory.specificEnergy)}',
            'q_in = cp·(T3 − T2) = ${f(r.heatIn, UnitCategory.specificEnergy)}',
            'η = (w_t − w_c)/q_in = ${pct(r.efficiency)}',
          ],
      },
      'w_net = q_in − q_out = ${f(r.netWork, UnitCategory.specificEnergy)}',
      'cv = cp/k = ${f(cv, UnitCategory.specificEntropy)}',
    ];

    final performance = ResultSection(title: l10n.Cycle_Performance, values: [
      ResultValue(label: l10n.Thermal_Efficiency, valueSI: r.efficiency * 100),
      ResultValue(label: l10n.Carnot_Efficiency, valueSI: r.carnotEfficiency * 100),
      ResultValue(
          label: l10n.Net_Work, valueSI: r.netWork, category: UnitCategory.specificEnergy),
      ResultValue(
          label: l10n.Heat_Added_Qin, valueSI: r.heatIn, category: UnitCategory.specificEnergy),
      ResultValue(
        label: l10n.Heat_Rejected_Qout,
        valueSI: r.heatOut,
        category: UnitCategory.specificEnergy,
      ),
      ResultValue(
        label: l10n.Compression_Work,
        valueSI: r.compressionWork,
        category: UnitCategory.specificEnergy,
      ),
      ResultValue(
        label: l10n.Expansion_Work,
        valueSI: r.expansionWork,
        category: UnitCategory.specificEnergy,
      ),
      if (r.cycle == AirCycle.brayton)
        ResultValue(label: l10n.Back_Work_Ratio, valueSI: r.backWorkRatio * 100),
      if (r.meanEffectivePressure case final mep?)
        ResultValue(
          label: l10n.Mean_Effective_Pressure,
          valueSI: mep,
          category: UnitCategory.pressure,
        ),
    ]);

    Offset pv(double v, double p) => plotPoint(
        v, UnitCategory.specificVolume, p, UnitCategory.pressure, system);
    Offset ts(double sValue, double tK) => plotPoint(sValue,
        UnitCategory.specificEntropy, tK - 273.15, UnitCategory.temperature, system);
    final markersPv = [
      for (var i = 0; i < s.length; i++) PlotMarker(pv(s[i].v, s[i].p), '${i + 1}'),
    ];
    final markersTs = [
      for (var i = 0; i < s.length; i++) PlotMarker(ts(s[i].s, s[i].t), '${i + 1}'),
    ];
    final cycleName = airCycleLabel(context, r.cycle);

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        performance,
        ...stateTableSections(columns, rows),
      ],
      children: [
        StateTableCard(
          title: '${l10n.Cycle_States} · $cycleName',
          columns: columns,
          rows: rows,
        ),
        FormulaCard(steps: steps, tex: airCycleTex(r.cycle)),
        LinePlotCard(
          title: l10n.Pv_Diagram,
          xAxisLabel: axisLabel('v', UnitCategory.specificVolume, system),
          yAxisLabel: axisLabel('p', UnitCategory.pressure, system),
          // Pinned at zero: a cycle floating mid-chart hides how much of the
          // pressure is the compression and how much the combustion.
          xMin: 0,
          yMin: 0,
          series: [
            PlotSeries(
              points: [for (final p in r.pv) pv(p.v, p.p)],
              width: 2.5,
              label: cycleName,
            ),
          ],
          markers: markersPv,
        ),
        LinePlotCard(
          title: l10n.Ts_Diagram,
          xAxisLabel: axisLabel('s − s₁', UnitCategory.specificEntropy, system),
          yAxisLabel: axisLabel('T', UnitCategory.temperature, system),
          series: [
            PlotSeries(
              points: [for (final p in r.ts) ts(p.s, p.t)],
              width: 2.5,
              label: cycleName,
            ),
          ],
          markers: markersTs,
        ),
        ResultFootnote(l10n.Air_Cycle_Note),
      ],
    );
  }
}
