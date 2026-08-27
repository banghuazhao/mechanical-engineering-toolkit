import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/pipe_schedule_data.dart';
import 'package:mechanical_engineering_toolkit/ui/reference_table_page.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Browsable table of [pipeSpecs] — every size and schedule pair, with the
/// bore and flow area the fluids tools actually need.
///
/// Rows copy on tap rather than opening a detail sheet: unlike a rolled
/// section, a pipe has only these few numbers, so the row already says
/// everything there is to say.
class PipeSchedulesPage extends StatelessWidget {
  const PipeSchedulesPage({
    super.key,
    this.title,
    this.toolId,
    this.initialInputs,
  });

  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;

  /// A bare number is read as a size and matches NPS or DN exactly — typing
  /// "50" should find DN 50 rather than every row whose OD happens to contain
  /// "50". Anything else, including fractional sizes like "1 1/2" and text
  /// like "sch 80" or "std", falls back to a substring match.
  bool _matches(PipeSpec spec, String query) {
    final size = double.tryParse(query);
    if (size != null) return spec.size.nps == size || spec.size.dn == size;
    return spec.searchText.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    String value(double valueSI, UnitCategory category) =>
        precs.formatValue(fromSI(valueSI, category, system));

    return ReferenceTablePage<PipeSpec>(
      title: title ?? l10n.Pipe_Schedules,
      toolId: toolId,
      rows: pipeSpecs,
      searchHint: l10n.Search_Pipe_Size,
      footnote: l10n.Pipes_Footnote,
      searchText: (spec) => spec.searchText,
      matcher: _matches,
      filters: [
        for (final schedule in PipeSchedule.values)
          ReferenceFilter<PipeSpec>(
            label: schedule.label,
            test: (spec) => spec.schedule == schedule,
          ),
      ],
      columns: [
        ReferenceColumn(
          label: l10n.Pipe_Size_NPS,
          value: (spec) => spec.size.npsLabel,
          // Both naming systems on one row: a drawing may call out either.
          secondary: (spec) => 'DN ${spec.size.dn}',
          width: 74,
          mono: false,
        ),
        ReferenceColumn(
          label: l10n.Pipe_Schedule,
          value: (spec) => spec.schedule.label,
          secondary: (spec) => spec.weightClass,
          width: 78,
          mono: false,
        ),
        ReferenceColumn(
          label: 'OD (${unitLabel(UnitCategory.length, system)})',
          value: (spec) => value(spec.outsideDiameter, UnitCategory.length),
          width: 74,
        ),
        ReferenceColumn(
          label: 't (${unitLabel(UnitCategory.length, system)})',
          value: (spec) => value(spec.wallThickness, UnitCategory.length),
          width: 66,
        ),
        ReferenceColumn(
          label: 'ID (${unitLabel(UnitCategory.length, system)})',
          value: (spec) => value(spec.insideDiameter, UnitCategory.length),
          width: 74,
        ),
        ReferenceColumn(
          label: 'A (${unitLabel(UnitCategory.area, system)})',
          value: (spec) => value(spec.flowArea, UnitCategory.area),
          width: 86,
        ),
      ],
    );
  }
}
