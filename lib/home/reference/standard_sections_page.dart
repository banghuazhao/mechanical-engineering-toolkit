import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_section_data.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_section_detail_page.dart';
import 'package:mechanical_engineering_toolkit/ui/reference_table_page.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Browsable table of the rolled shapes in [standardSections]. Tapping a row
/// opens its full property sheet rather than copying the row, because the
/// table can only show a handful of the properties at a phone's width.
class StandardSectionsPage extends StatelessWidget {
  const StandardSectionsPage({
    super.key,
    this.title,
    this.toolId,
    this.initialInputs,
  });

  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    String value(double valueSI, UnitCategory category) =>
        precs.formatValue(fromSI(valueSI, category, system));

    return ReferenceTablePage<StandardSection>(
      title: title ?? l10n.Standard_Sections,
      toolId: toolId,
      rows: standardSections,
      searchHint: l10n.Search_Section,
      footnote: l10n.Sections_Footnote,
      searchText: (section) => section.designation,
      // Beside the table on a wide window, so the list stays in view while
      // one shape after another is looked up.
      onRowTap: (section) => showToolResult(
        context,
        (context) => StandardSectionDetailPage(section: section),
      ),
      filters: [
        for (final family in SectionFamily.values)
          ReferenceFilter<StandardSection>(
            label: family.label(context),
            test: (section) => section.family == family,
          ),
      ],
      // Column headers are the standard symbols rather than words: they are
      // the same notation on a drawing in every language this app ships in,
      // and spelling them out would not fit the width anyway. The unit each
      // one carries follows the reader's unit-system setting.
      columns: [
        ReferenceColumn(
          label: l10n.Section_Designation,
          value: (section) => section.designation,
          width: 96,
          mono: false,
        ),
        ReferenceColumn(
          label: 'd (${unitLabel(UnitCategory.length, system)})',
          value: (section) => value(section.depth, UnitCategory.length),
          width: 66,
        ),
        ReferenceColumn(
          label: 'b (${unitLabel(UnitCategory.length, system)})',
          value: (section) => value(section.width, UnitCategory.length),
          width: 66,
        ),
        ReferenceColumn(
          label: 'A (${unitLabel(UnitCategory.area, system)})',
          value: (section) => value(section.area, UnitCategory.area),
          width: 78,
        ),
        ReferenceColumn(
          label: 'Ix (${unitLabel(UnitCategory.momentOfInertia, system)})',
          value: (section) =>
              value(section.ix, UnitCategory.momentOfInertia),
          width: 96,
        ),
        ReferenceColumn(
          label: 'Zx (${unitLabel(UnitCategory.sectionModulus, system)})',
          value: (section) => value(section.zx, UnitCategory.sectionModulus),
          width: 90,
        ),
      ],
    );
  }
}
