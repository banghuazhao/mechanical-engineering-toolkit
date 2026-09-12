import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/rankine_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/rankine_page.dart';
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

/// Below this turbine-exit quality the moisture erodes the last-stage blades;
/// 0.88 is the figure textbooks and turbine makers quote.
const double _minimumExitQuality = 0.88;

class RankineResultPage extends StatelessWidget {
  const RankineResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.result,
  });

  final int toolId;
  final String title;
  final RankineResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final r = result;
    final s = r.states;

    String e(double value) =>
        precs.formatSI(value, UnitCategory.specificEnergy, system);

    const columns = [
      StateColumn('p', UnitCategory.pressure),
      StateColumn('T', UnitCategory.temperature),
      StateColumn('h', UnitCategory.specificEnergy),
      StateColumn('s', UnitCategory.specificEntropy),
      StateColumn('x', null),
    ];
    final labels = [
      l10n.Rankine_State_1,
      l10n.Rankine_State_2,
      l10n.Rankine_State_3,
      l10n.Rankine_State_4,
    ];
    final rows = [
      for (var i = 0; i < 4; i++)
        StateRow(labels[i], [
          s[i].p,
          s[i].t - 273.15,
          s[i].h,
          s[i].s,
          s[i].quality,
        ]),
    ];

    final steps = [
      'w_p = v1·(p2 − p1)/ηp = ${e(r.pumpWork)}',
      'h2 = h1 + w_p = ${e(s[0].h)} + ${e(r.pumpWork)} = ${e(s[1].h)}',
      'h4 = h3 − ηt·(h3 − h4s) = ${e(s[3].h)}',
      'w_t = h3 − h4 = ${e(s[2].h)} − ${e(s[3].h)} = ${e(r.turbineWork)}',
      'q_in = h3 − h2 = ${e(r.heatIn)}',
      'q_out = h4 − h1 = ${e(r.heatOut)}',
      'η = (w_t − w_p)/q_in = ${precs.formatValue(r.efficiency * 100)} %',
    ];

    final exitQuality = r.exitQuality;
    final performance = ResultSection(title: l10n.Cycle_Performance, values: [
      ResultValue(label: l10n.Thermal_Efficiency, valueSI: r.efficiency * 100),
      ResultValue(
          label: l10n.Net_Work, valueSI: r.netWork, category: UnitCategory.specificEnergy),
      ResultValue(
          label: l10n.Turbine_Work,
          valueSI: r.turbineWork,
          category: UnitCategory.specificEnergy),
      ResultValue(
          label: l10n.Pump_Work, valueSI: r.pumpWork, category: UnitCategory.specificEnergy),
      ResultValue(
          label: l10n.Heat_Added_Qin, valueSI: r.heatIn, category: UnitCategory.specificEnergy),
      ResultValue(
        label: l10n.Heat_Rejected_Qout,
        valueSI: r.heatOut,
        category: UnitCategory.specificEnergy,
      ),
      ResultValue(label: l10n.Back_Work_Ratio, valueSI: r.backWorkRatio * 100),
      exitQuality == null
          ? ResultValue(label: l10n.Exit_Quality, value: l10n.Superheated_Exhaust)
          : ResultValue(label: l10n.Exit_Quality, valueSI: exitQuality),
      if (r.netPower case final power?)
        ResultValue(label: l10n.Net_Power, valueSI: power, category: UnitCategory.power),
      if (r.heatInputRate case final rate?)
        ResultValue(
            label: l10n.Heat_Input_Rate, valueSI: rate, category: UnitCategory.power),
    ]);

    Offset ts(double sValue, double tK) => plotPoint(sValue,
        UnitCategory.specificEntropy, tK - 273.15, UnitCategory.temperature, system);

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        performance,
        ...stateTableSections(columns, rows),
      ],
      children: [
        if (exitQuality != null && exitQuality < _minimumExitQuality)
          ResultWarningCard(message: l10n.Rankine_Wet_Exhaust),
        StateTableCard(title: l10n.Cycle_States, columns: columns, rows: rows),
        FormulaCard(steps: steps, tex: rankineTex),
        LinePlotCard(
          title: l10n.Ts_Diagram,
          xAxisLabel: axisLabel('s', UnitCategory.specificEntropy, system),
          yAxisLabel: axisLabel('T', UnitCategory.temperature, system),
          series: [
            PlotSeries(
              points: [for (final p in r.dome) ts(p.s, p.t)],
              tone: PlotTone.muted,
              width: 1.5,
              label: l10n.Saturation_Dome,
            ),
            PlotSeries(
              points: [for (final p in r.cyclePath) ts(p.s, p.t)],
              width: 2.5,
              label: l10n.Cycle_Label,
            ),
          ],
          markers: [
            for (var i = 0; i < 4; i++) PlotMarker(ts(s[i].s, s[i].t), '${i + 1}'),
          ],
        ),
        ResultFootnote(l10n.Rankine_Note),
      ],
    );
  }
}
