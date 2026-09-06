import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/fastener_grade_data.dart';
import 'package:mechanical_engineering_toolkit/ui/reference_table_page.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Browsable table of [boltSpecs]: every thread size crossed with every
/// strength grade, and the clamp load and tightening torque each pair implies.
///
/// The question this answers is the one asked at the bench — "what do I torque
/// an M10 10.9 to?" — which is why size and grade are one row rather than two
/// tables to cross-reference by hand.
class FastenerGradesPage extends StatelessWidget {
  const FastenerGradesPage({
    super.key,
    this.title,
    this.toolId,
    this.initialInputs,
  });

  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;

  /// A bare number is read as a metric size — typing "10" should find M10
  /// rather than every row whose torque happens to contain "10". Anything
  /// else falls back to a substring match, which is what makes "10.9", "sae
  /// 8" and "1/2-13" work.
  bool _matches(BoltSpec spec, String query) {
    final size = double.tryParse(query);
    if (size != null) {
      return spec.size.isMetric && spec.size.diameterMm == size;
    }
    return spec.searchText.toLowerCase().contains(query);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    String value(double valueSI, UnitCategory category) =>
        precs.formatValue(fromSI(valueSI, category, system));

    final grades = [...metricGrades, ...inchGrades];

    return ReferenceTablePage<BoltSpec>(
      title: title ?? l10n.Bolt_Grades_Torque,
      toolId: toolId,
      rows: boltSpecs,
      searchHint: l10n.Search_Bolt_Size_Grade,
      footnote: l10n.Bolt_Grades_Footnote,
      searchText: (spec) => spec.searchText,
      matcher: _matches,
      filters: [
        for (final grade in grades)
          ReferenceFilter<BoltSpec>(
            label: grade.designation,
            test: (spec) => spec.grade.designation == grade.designation,
          ),
      ],
      columns: [
        ReferenceColumn(
          label: l10n.Bolt_Size,
          value: (spec) => spec.size.designation,
          secondary: (spec) => spec.size.threadLabel,
          width: 80,
          mono: false,
        ),
        ReferenceColumn(
          label: l10n.Grade_Class,
          // The marking under the designation is what identifies a bolt
          // already in a joint, where nobody can read a drawing off it. A
          // metric class is stamped with its own number, so there the second
          // line would only repeat the first.
          value: (spec) => spec.grade.designation,
          secondary: (spec) => spec.grade.headMarking == spec.grade.designation
              ? null
              : spec.grade.headMarking,
          width: 86,
          mono: false,
        ),
        ReferenceColumn(
          label: '${l10n.Stress_Area_As} (${unitLabel(UnitCategory.area, system)})',
          value: (spec) => value(spec.size.stressAreaMm2, UnitCategory.area),
          width: 84,
        ),
        ReferenceColumn(
          label: '${l10n.Proof_Strength_Sp} (${unitLabel(UnitCategory.stress, system)})',
          value: (spec) => value(spec.band.proofStrength, UnitCategory.stress),
          width: 78,
        ),
        ReferenceColumn(
          label: '${l10n.Clamp_Load_Fi} (${unitLabel(UnitCategory.force, system)})',
          value: (spec) => value(spec.clampLoad, UnitCategory.force),
          width: 90,
        ),
        ReferenceColumn(
          label: '${l10n.Torque_T} (${unitLabel(UnitCategory.torque, system)})',
          value: (spec) => value(spec.tighteningTorque, UnitCategory.torque),
          width: 84,
        ),
      ],
    );
  }
}
