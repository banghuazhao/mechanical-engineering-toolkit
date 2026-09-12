import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/line_plot_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The modified-Goodman diagram for one fluctuating stress state: the
/// failure line, the design line the factor of safety scales it to, and the
/// load line from the origin through the operating point.
///
/// The picture answers the question the single number n cannot — how the
/// margin splits between the alternating and the mean stress, and so which
/// one a redesign should attack.
class GoodmanDiagramCard extends StatelessWidget {
  const GoodmanDiagramCard({
    super.key,
    required this.alternatingStress,
    required this.meanStress,
    required this.enduranceLimit,
    required this.ultimateStrength,
    required this.safetyFactor,
  });

  /// All in MPa, the app's SI display unit for stress.
  final double alternatingStress;
  final double meanStress;
  final double enduranceLimit;
  final double ultimateStrength;
  final double safetyFactor;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    double d(double mpa) => fromSI(mpa, UnitCategory.stress, system);

    final se = enduranceLimit, su = ultimateStrength, n = safetyFactor;
    final sa = alternatingStress, sm = meanStress;
    final unit = unitLabel(UnitCategory.stress, system);
    return LinePlotCard(
      title: l10n.Goodman_Diagram,
      xAxisLabel: 'σm ($unit)',
      yAxisLabel: 'σa ($unit)',
      xMin: 0,
      yMin: 0,
      series: [
        PlotSeries(
          points: [Offset(0, d(se)), Offset(d(su), 0)],
          tone: PlotTone.danger,
          width: 2.5,
          label: l10n.Goodman_Line,
        ),
        if (n.isFinite && n > 0)
          PlotSeries(
            points: [Offset(0, d(se / n)), Offset(d(su / n), 0)],
            dashed: true,
            label: l10n.Design_Line,
          ),
        // From the origin, through the operating point, to failure: the
        // stresses scaled together by n land exactly on the Goodman line.
        if (n.isFinite && n > 0)
          PlotSeries(
            points: [Offset.zero, Offset(d(sm * n), d(sa * n))],
            tone: PlotTone.muted,
            dashed: true,
            width: 1.5,
            label: l10n.Load_Line,
          ),
      ],
      markers: [
        PlotMarker(
          Offset(d(sm), d(sa)),
          'n = ${precs.formatValue(n)}',
          tone: n >= 1 ? PlotTone.primary : PlotTone.danger,
        ),
      ],
      caption: l10n.Goodman_Caption,
    );
  }
}
