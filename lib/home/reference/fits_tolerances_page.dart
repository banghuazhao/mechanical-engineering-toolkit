import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/iso_fit_data.dart';
import 'package:mechanical_engineering_toolkit/ui/reference_table_page.dart';

class FitsTolerancesPage extends StatelessWidget {
  const FitsTolerancesPage({
    super.key,
    this.title,
    this.toolId,
    this.initialInputs,
  });

  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;

  /// A bare number is read as a diameter and matches the band containing it;
  /// anything else falls back to matching the fit name.
  bool _matches(FitEntry entry, String query) {
    final diameter = double.tryParse(query);
    if (diameter != null) return entry.band.contains(diameter);
    return '${entry.fit.name} ${entry.band.label}'
        .toLowerCase()
        .contains(query);
  }

  @override
  Widget build(BuildContext context) {
    return ReferenceTablePage<FitEntry>(
      title: title ?? S.of(context).Fits_Tolerances,
      toolId: toolId,
      rows: fitEntries,
      searchHint: S.of(context).Search_Size_Or_Fit,
      footnote: S.of(context).Fits_Footnote,
      searchText: (entry) => '${entry.fit.name} ${entry.band.label}',
      matcher: _matches,
      filters: [
        for (final fit in preferredFits)
          ReferenceFilter<FitEntry>(
            label: fit.name,
            test: (entry) => entry.fit.name == fit.name,
          ),
      ],
      // Every limit is µm from the nominal size, upper over lower — the way
      // limits are written on a drawing.
      columns: [
        ReferenceColumn(
          label: S.of(context).Nominal_Size_mm,
          value: (entry) => entry.band.label,
          width: 74,
        ),
        ReferenceColumn(
          label: S.of(context).Fit,
          value: (entry) => entry.fit.name,
          width: 64,
        ),
        ReferenceColumn(
          label: S.of(context).Hole_um,
          value: (entry) => formatMicrons(entry.holeUpper),
          secondary: (entry) => formatMicrons(entry.holeLower),
          width: 58,
        ),
        ReferenceColumn(
          label: S.of(context).Shaft_um,
          value: (entry) => formatMicrons(entry.shaftUpper),
          secondary: (entry) => formatMicrons(entry.shaftLower),
          width: 62,
        ),
        ReferenceColumn(
          label: S.of(context).Clearance_um,
          value: (entry) => formatMicrons(entry.maxClearance),
          secondary: (entry) => formatMicrons(entry.minClearance),
          width: 66,
        ),
      ],
    );
  }
}
