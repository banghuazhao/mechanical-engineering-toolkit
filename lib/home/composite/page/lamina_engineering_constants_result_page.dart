import 'dart:math';

import 'package:composite_calculator/composite_calculator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/thermal_constants_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class LaminaEngineeringConstantsResultPage extends StatefulWidget {
  final int toolId;
  final TransverselyIsotropicMaterial material;
  final AnalysisType analysisType;
  final ThermalConstants thermalConstants;

  const LaminaEngineeringConstantsResultPage({
    Key? key,
    required this.toolId,
    required this.material,
    required this.analysisType,
    required this.thermalConstants,
  }) : super(key: key);

  @override
  _LaminaEngineeringConstantsResultPageState createState() =>
      _LaminaEngineeringConstantsResultPageState();
}

class _LaminaEngineeringConstantsResultPageState
    extends State<LaminaEngineeringConstantsResultPage> {
  double layupAngle = 0.0;
  LaminaEngineeringConstantsOutput? _current;

  // per-property chart data
  final Map<String, List<FlSpot>> _chartData = {};

  @override
  void initState() {
    super.initState();
    _buildChartData();
    _updateCurrent();
  }

  LaminaEngineeringConstantsInput _inputFor(double angle) =>
      LaminaEngineeringConstantsInput(
        analysisType: widget.analysisType,
        E1: widget.material.e1!,
        E2: widget.material.e2!,
        G12: widget.material.g12!,
        nu12: widget.material.nu12!,
        layupAngle: angle,
        alpha11: widget.thermalConstants.alpha11 ?? 0,
        alpha22: widget.thermalConstants.alpha22 ?? 0,
        alpha12: widget.thermalConstants.alpha12 ?? 0,
      );

  void _buildChartData() {
    for (final key in [
      'Ex',
      'Ey',
      'Gxy',
      'νxy',
      'η₁',
      'η₂',
      if (widget.analysisType == AnalysisType.thermalElastic) 'α₁₁',
      'α₂₂',
      'α₁₂'
    ]) {
      _chartData[key] = [];
    }
    for (int i = -90; i <= 90; i++) {
      final o = LaminaEngineeringConstantsCalculator.calculate(
          _inputFor(i.toDouble()));
      _chartData['Ex']!.add(FlSpot(i.toDouble(), o.E1));
      _chartData['Ey']!.add(FlSpot(i.toDouble(), o.E2));
      _chartData['Gxy']!.add(FlSpot(i.toDouble(), o.G12));
      _chartData['νxy']!.add(FlSpot(i.toDouble(), o.nu12));
      _chartData['η₁']!.add(FlSpot(i.toDouble(), o.eta1_12));
      _chartData['η₂']!.add(FlSpot(i.toDouble(), o.eta2_12));
      if (widget.analysisType == AnalysisType.thermalElastic) {
        _chartData['α₁₁']!.add(FlSpot(i.toDouble(), o.alpha_11));
        _chartData['α₂₂']!.add(FlSpot(i.toDouble(), o.alpha_22));
        _chartData['α₁₂']!.add(FlSpot(i.toDouble(), o.alpha_12));
      }
    }
  }

  void _updateCurrent() {
    _current =
        LaminaEngineeringConstantsCalculator.calculate(_inputFor(layupAngle));
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final isThermal = widget.analysisType == AnalysisType.thermalElastic;
    final elasticRows = <(String, double?, UnitCategory?)>[
      ('Ex', _current?.E1, UnitCategory.modulus),
      ('Ey', _current?.E2, UnitCategory.modulus),
      ('Gxy', _current?.G12, UnitCategory.modulus),
      ('νxy', _current?.nu12, null),
      ('η₁', _current?.eta1_12, null),
      ('η₂', _current?.eta2_12, null),
    ];
    final thermalRows = <(String, double?, UnitCategory?)>[
      ('α₁₁', _current?.alpha_11, null),
      ('α₂₂', _current?.alpha_22, null),
      ('α₁₂', _current?.alpha_12, null),
    ];
    final allRows = [...elasticRows, if (isThermal) ...thermalRows];

    final chartItems = allRows
        .where((r) => _chartData.containsKey(r.$1))
        .map((r) => _ConstantRow(
              label: r.$1,
              value: r.$2 ?? 0,
              category: r.$3,
              chartData: _chartData[r.$1]!,
              currentAngle: layupAngle,
            ))
        .toList();

    return ResultScaffold(
      toolName: 'Lamina Engineering Constants',
      // The constants vary with the slider, so the export describes the angle
      // currently shown rather than the whole sweep behind the charts.
      results: [
        ResultSection(
          title: 'Layup angle ${doubleToString(layupAngle, keepDecimal: 0)}°',
          values: [
            for (final (label, value, category) in allRows)
              ResultValue(
                label: label,
                valueSI: value ?? 0,
                category: category,
              ),
          ],
        ),
      ],
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: 2 + chartItems.length,
          staggeredTileBuilder: (i) => StaggeredTile.fit(
              i == 0 ? 8 : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) {
            if (i == 0) return ToolResultHeader(tool: tool);
            if (i == 1) return _angleSlider();
            return chartItems[i - 2];
          },
        ),
      ),
    );
  }

  Widget _angleSlider() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              'Layup Angle: ${doubleToString(layupAngle, keepDecimal: 0)}°',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Slider(
            value: layupAngle,
            min: -90,
            max: 90,
            divisions: 180,
            onChanged: (v) => setState(() {
              layupAngle = v;
              _updateCurrent();
            }),
          ),
        ],
      ),
    );
  }
}

class _ConstantRow extends StatelessWidget {
  final String label;
  final double value;
  final UnitCategory? category;
  final List<FlSpot> chartData;
  final double currentAngle;

  const _ConstantRow({
    required this.label,
    required this.value,
    this.category,
    required this.chartData,
    required this.currentAngle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    double minY = chartData.map((s) => s.y).reduce(min);
    double maxY = chartData.map((s) => s.y).reduce(max);
    if (minY == maxY) {
      minY -= 1;
      maxY += 1;
    }
    final system = context.watch<UnitSystemPreference>().system;
    final displayValue =
        category == null ? value : fromSI(value, category!, system);
    final unitSuffix =
        category == null ? '' : ' ${unitLabel(category!, system)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // label + value
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Consumer<NumberPrecisionHelper>(
                    builder: (_, precs, __) => Text(
                      '${precs.formatValue(displayValue)}$unitSuffix',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 80,
                child: LineChart(
                  LineChartData(
                    extraLinesData: ExtraLinesData(verticalLines: [
                      VerticalLine(
                          x: currentAngle, color: primary, strokeWidth: 1),
                    ]),
                    lineTouchData: const LineTouchData(enabled: false),
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(
                      show: false,
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: -90,
                    maxX: 90,
                    minY: minY,
                    maxY: maxY,
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartData,
                        isCurved: true,
                        color: primary,
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: primary.withAlpha(25),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
