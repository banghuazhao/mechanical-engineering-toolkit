import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/pipe_schedule_data.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Picks a pipe size and schedule from the standard schedule library.
///
/// Hands back the whole [PipeSpec] rather than just a bore, so a caller that
/// also wants the wall or the flow area does not have to look the row up
/// again. What a flow calculation needs is the inside diameter — the bore the
/// fluid actually sees, which is the OD less two walls and never the size in
/// the pipe's name.
class PipeSizeButton extends StatelessWidget {
  const PipeSizeButton({super.key, required this.onSelected});

  final ValueChanged<PipeSpec> onSelected;

  @override
  Widget build(BuildContext context) {
    return PresetPickerButton<PipeSpec>(
      buttonLabel: S.of(context).Pick_Pipe_Size,
      sheetTitle: S.of(context).Pipe_Schedules,
      searchHint: S.of(context).Search_Pipe_Size,
      emptyLabel: S.of(context).No_Pipes_Found,
      icon: Icons.circle_outlined,
      presets: pipeSpecs,
      nameOf: (spec) => spec.designation,
      subtitleOf: (context, spec) {
        final system = context.read<UnitSystemPreference>().system;
        final precs = context.read<NumberPrecisionHelper>();
        String length(double v) =>
            precs.formatSI(v, UnitCategory.length, system);
        return 'ID = ${length(spec.insideDiameter)} · '
            'OD = ${length(spec.outsideDiameter)} · '
            't = ${length(spec.wallThickness)}';
      },
      onSelected: onSelected,
    );
  }
}
