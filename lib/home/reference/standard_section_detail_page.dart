import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_section_data.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// Full property sheet for one rolled shape.
///
/// Built on [ResultScaffold] rather than a plain page so a looked-up section
/// leaves the app the same ways a calculated one does — text, CSV, PDF or
/// image — which is what makes it usable in a submittal rather than only on
/// screen.
class StandardSectionDetailPage extends StatelessWidget {
  const StandardSectionDetailPage({super.key, required this.section});

  final StandardSection section;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return ResultScaffold(
      title: section.designation,
      toolName: '${l10n.Standard_Sections} — ${section.designation}',
      formulaSteps: const [
        'Zx = Ix / (d/2), Zy = Iy / (b/2)',
        'rx = √(Ix/A), ry = √(Iy/A)',
      ],
      results: [
        ResultSection(
          title: l10n.Section_Dimensions,
          values: [
            ResultValue(
              label: l10n.Section_Designation,
              value: section.designation,
            ),
            ResultValue(
              label: l10n.Section_Depth_d,
              valueSI: section.depth,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Section_Width_b,
              valueSI: section.width,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Section_Web_tw,
              valueSI: section.webThickness,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Section_Flange_tf,
              valueSI: section.flangeThickness,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Area_A,
              valueSI: section.area,
              category: UnitCategory.area,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Strong_Axis,
          values: [
            ResultValue(
              label: l10n.Second_Moment_Ix,
              valueSI: section.ix,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: l10n.Section_Modulus_Zx,
              valueSI: section.zx,
              category: UnitCategory.sectionModulus,
            ),
            ResultValue(
              label: l10n.Radius_Gyration_rx,
              valueSI: section.rx,
              category: UnitCategory.length,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Weak_Axis,
          values: [
            ResultValue(
              label: l10n.Second_Moment_Iy,
              valueSI: section.iy,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: l10n.Section_Modulus_Zy,
              valueSI: section.zy,
              category: UnitCategory.sectionModulus,
            ),
            ResultValue(
              label: l10n.Radius_Gyration_ry,
              valueSI: section.ry,
              category: UnitCategory.length,
            ),
          ],
        ),
      ],
      children: [
        Text(
          l10n.Sections_Footnote,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
