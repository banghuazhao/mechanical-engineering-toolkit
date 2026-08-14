import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_section_data.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Picks a rolled shape from the standard section library.
///
/// Which of the shape's numbers the caller uses is up to the caller: a tool
/// that computes properties from dimensions takes d, b, tw and tf, while one
/// that wants a second moment takes the published Ix directly and skips the
/// geometry entirely — the published value already includes the root fillets
/// that a dimensions-only calculation cannot see.
class StandardSectionButton extends StatelessWidget {
  const StandardSectionButton({super.key, required this.onSelected});

  final ValueChanged<StandardSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return PresetPickerButton<StandardSection>(
      buttonLabel: S.of(context).Pick_Standard_Section,
      sheetTitle: S.of(context).Standard_Sections,
      searchHint: S.of(context).Search_Section,
      emptyLabel: S.of(context).No_Sections_Found,
      icon: Icons.view_week_outlined,
      presets: standardSections,
      nameOf: (section) => section.designation,
      subtitleOf: (context, section) {
        final system = context.read<UnitSystemPreference>().system;
        final precs = context.read<NumberPrecisionHelper>();
        final depth = precs.formatSI(section.depth, UnitCategory.length, system);
        final area = precs.formatSI(section.area, UnitCategory.area, system);
        final ix = precs.formatSI(
            section.ix, UnitCategory.momentOfInertia, system);
        return 'd = $depth · A = $area · Ix = $ix';
      },
      onSelected: onSelected,
    );
  }
}
