import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// Shared result page for both the Cantilever and Simple Beam
/// Deflections & Slopes tools — the two beams differ only in which load
/// cases and formulas apply, not in how the result is displayed.
class CantileverBeamDeflectionsSlopesResultPage extends StatelessWidget {
  CantileverBeamDeflectionsSlopesResultPage({
    super.key,
    required this.toolId,
    required this.toolTitle,
    required this.deflectionTitles,
    required this.deflectionValues,
    required this.slopesTitles,
    required this.slopesValues,
    this.deflectionCurve,
  });

  final int toolId;
  final String toolTitle;
  final List<String> deflectionTitles;
  final List<String> deflectionValues;
  final List<String> slopesTitles;
  final List<String> slopesValues;

  /// Numeric deflection v(x) sampled across the beam span, in mm (x) vs mm
  /// (v) — for the deflection-curve diagram. Null when not computed for the
  /// current load case.
  final List<DiagramPoint>? deflectionCurve;

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(toolId, context);
    return ResultScaffold(
      toolName: toolTitle,
      shareLines: _shareLines,
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: S.of(context).Deflection,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < deflectionTitles.length; i++)
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: context.tokens.space1),
                  child: Text(
                    '${deflectionTitles[i]} = ${deflectionValues[i]}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
        AppSectionCard(
          title: S.of(context).Slope,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < slopesTitles.length; i++)
                Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: context.tokens.space1),
                  child: Text(
                    '${slopesTitles[i]} = ${slopesValues[i]}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
            ],
          ),
        ),
        if (deflectionCurve != null) ...[
          XYDiagramCard(
            title: 'Deflection curve',
            xUnitLabel: unitLabel(UnitCategory.length, UnitSystem.si),
            yUnitLabel:
                '${unitLabel(UnitCategory.length, UnitSystem.si)} downward',
            points: deflectionCurve!,
          ),
        ],
      ],
    );
  }

  List<String> _shareLines() {
    return [
      'Deflections:',
      for (var i = 0; i < deflectionTitles.length; i++)
        '  ${deflectionTitles[i]} = ${deflectionValues[i]}',
      '',
      'Slopes:',
      for (var i = 0; i < slopesTitles.length; i++)
        '  ${slopesTitles[i]} = ${slopesValues[i]}',
    ];
  }
}
