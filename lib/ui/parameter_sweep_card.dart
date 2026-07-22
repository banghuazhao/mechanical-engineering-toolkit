import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/number.dart';
import '../util/unit_system.dart';
import '../util/units.dart';
import 'app_components.dart';
import 'app_theme.dart';

/// A "what-if" mini chart: sweeps one input across a range around its base
/// value and plots the effect on a computed output, using the tool's own
/// pure calculation function. Drag along the chart to read the exact output
/// at any sampled input.
///
/// For a static position-vs-quantity diagram (e.g. a beam moment diagram),
/// see [XYDiagramCard] instead.
class ParameterSweepCard extends StatefulWidget {
  const ParameterSweepCard({
    super.key,
    required this.variableLabel,
    required this.variableCategory,
    required this.baseValueSI,
    required this.outputLabel,
    required this.outputCategory,
    required this.compute,
    this.minSI,
    this.maxSI,
    this.sampleCount = 30,
  });

  final String variableLabel;
  final UnitCategory? variableCategory;
  final double baseValueSI;
  final String outputLabel;
  final UnitCategory? outputCategory;

  /// Given a varied value of the swept input (in its SI display unit),
  /// returns the output (in the output category's SI display unit). Should
  /// be a pure function of the input — reuses the tool's existing formula.
  /// May throw for invalid sample points (e.g. a formula undefined at that
  /// x) — such samples are simply skipped.
  final double Function(double variedValueSI) compute;

  /// Sweep range bounds, in the variable's SI display unit. Defaults to
  /// ±50% of [baseValueSI] (or ±1 unit if the base value is ~zero).
  final double? minSI;
  final double? maxSI;
  final int sampleCount;

  @override
  State<ParameterSweepCard> createState() => _ParameterSweepCardState();
}

class _ParameterSweepCardState extends State<ParameterSweepCard> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    final base = widget.baseValueSI;
    final span = base.abs() > 1e-9 ? base.abs() * 0.5 : 1.0;
    final min = widget.minSI ?? base - span;
    final max = widget.maxSI ?? base + span;
    if (max <= min) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (var i = 0; i < widget.sampleCount; i++) {
      final x = min + (max - min) * i / (widget.sampleCount - 1);
      try {
        final y = widget.compute(x);
        if (y.isFinite) spots.add(FlSpot(x, y));
      } catch (_) {
        // Skip sample points where the formula isn't defined.
      }
    }
    if (spots.length < 2) return const SizedBox.shrink();

    final minY = spots.map((s) => s.y).reduce(math.min);
    final maxY = spots.map((s) => s.y).reduce(math.max);
    final yPad = (maxY - minY).abs() < 1e-9 ? 1.0 : (maxY - minY) * 0.1;
    final primary = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outlineVariant;

    final touchIndex = (_touchedIndex ?? spots.length ~/ 2).clamp(0, spots.length - 1);
    final touched = spots[touchIndex];
    final varUnit =
        widget.variableCategory == null ? '' : unitLabel(widget.variableCategory!, system);
    final outUnit =
        widget.outputCategory == null ? '' : unitLabel(widget.outputCategory!, system);

    String fv(double siValue, UnitCategory? category) {
      final display = category == null ? siValue : fromSI(siValue, category, system);
      return precs.formatValue(display);
    }

    return AppSectionCard(
      title: 'What if: ${widget.variableLabel}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.variableLabel} = ${fv(touched.x, widget.variableCategory)} $varUnit  →  '
            '${widget.outputLabel} = ${fv(touched.y, widget.outputCategory)} $outUnit',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: primary, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.tokens.space2),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minY: minY - yPad,
                maxY: maxY + yPad,
                gridData: const FlGridData(show: true),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(color: outline),
                    bottom: BorderSide(color: outline),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) =>
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    getTooltipItems: (touchedSpots) => touchedSpots
                        .map(
                          (spot) => LineTooltipItem(
                            '${widget.variableLabel} = '
                            '${fv(spot.x, widget.variableCategory)} $varUnit\n'
                            '→ ${widget.outputLabel} = '
                            '${fv(spot.y, widget.outputCategory)} $outUnit',
                            TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  touchCallback: (event, response) {
                    final bars = response?.lineBarSpots;
                    if (bars != null && bars.isNotEmpty) {
                      setState(() => _touchedIndex = bars.first.spotIndex);
                    }
                  },
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: primary,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: primary.withValues(alpha: 0.08)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.tokens.space1),
          Text(
            'Drag along the line to explore other values of ${widget.variableLabel}.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
