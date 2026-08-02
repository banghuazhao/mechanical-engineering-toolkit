import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/drill_tap_data.dart';
import 'package:mechanical_engineering_toolkit/ui/reference_table_page.dart';

class DrillTapChartPage extends StatelessWidget {
  const DrillTapChartPage({
    super.key,
    this.title,
    this.toolId,
    this.initialInputs,
  });

  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;

  String _seriesLabel(BuildContext context, ThreadSeries series) {
    switch (series) {
      case ThreadSeries.metricCoarse:
        return S.of(context).Metric_Coarse;
      case ThreadSeries.metricFine:
        return S.of(context).Metric_Fine;
      case ThreadSeries.unifiedCoarse:
        return S.of(context).Unified_Coarse;
      case ThreadSeries.unifiedFine:
        return S.of(context).Unified_Fine;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReferenceTablePage<ThreadEntry>(
      title: title ?? S.of(context).Drill_Tap_Chart,
      rows: threadEntries,
      searchHint: S.of(context).Search_Thread_Size,
      footnote: S.of(context).Drill_Tap_Footnote,
      filters: [
        for (final series in ThreadSeries.values)
          ReferenceFilter<ThreadEntry>(
            label: _seriesLabel(context, series),
            test: (entry) => entry.series == series,
          ),
      ],
      // Metric sizes are searchable as typed ("m8") and with the pitch, inch
      // sizes by number or fraction ("1/4", "#10").
      searchText: (entry) => '${entry.size} ${entry.pitch}',
      // Inch drills lead with the designation stocked in a drill index and
      // carry the millimetre equivalent underneath; metric rows are just mm.
      columns: [
        ReferenceColumn(
          label: S.of(context).Thread,
          value: (entry) => entry.size,
          width: 76,
        ),
        ReferenceColumn(
          label: S.of(context).Pitch_TPI,
          value: (entry) => entry.pitch,
          width: 68,
        ),
        ReferenceColumn(
          label: S.of(context).Tap_Drill,
          value: (entry) => entry.tapDrill.headline,
          secondary: (entry) => entry.tapDrill.subline,
          width: 72,
        ),
        ReferenceColumn(
          label: S.of(context).Clearance_Close,
          value: (entry) => entry.clearanceClose.headline,
          secondary: (entry) => entry.clearanceClose.subline,
          width: 72,
        ),
        ReferenceColumn(
          label: S.of(context).Clearance_Free,
          value: (entry) => entry.clearanceFree.headline,
          secondary: (entry) => entry.clearanceFree.subline,
          width: 72,
        ),
      ],
    );
  }
}
