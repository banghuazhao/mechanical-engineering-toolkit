import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/mohrs_circle_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class MohrsCirclePage extends StatefulWidget {
  const MohrsCirclePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<MohrsCirclePage> createState() => _MohrsCirclePageState();
}

class _MohrsCirclePageState extends State<MohrsCirclePage> {
  double? _sx;
  double? _sy;
  double? _txy;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _sx = double.tryParse(inputs['σ_x'] ?? '');
    _sy = double.tryParse(inputs['σ_y'] ?? '');
    _txy = double.tryParse(inputs['τ_xy'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_rounded),
        label: Text(S.of(context).Calculate),
      ),
      body: AppContent(
        padding: EdgeInsets.zero,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            context.tokens.space4,
            context.tokens.space4,
            context.tokens.space4,
            100,
          ),
          children: [
            ToolResultHeader(tool: tool),
            AppSectionCard(
              title: "Mohr's Circle for Plane Stress",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mohr's circle plots the state of stress on every possible plane through a point, given σx, σy and τxy, and reads off the principal stresses, maximum in-plane shear, and orientation.",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'σx',
                      category: UnitCategory.stress,
                      initialSI: _sx,
                      onChangedSI: (v) => _sx = v,
                    ),
                    UnitField(
                      label: 'σy',
                      category: UnitCategory.stress,
                      initialSI: _sy,
                      onChangedSI: (v) => _sy = v,
                    ),
                    UnitField(
                      label: 'τxy',
                      category: UnitCategory.stress,
                      initialSI: _txy,
                      onChangedSI: (v) => _txy = v,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    try {
      final sx = _sx;
      final sy = _sy;
      final txy = _txy;
      if (sx == null || sy == null || txy == null) {
        throw const FormatException('Enter σx, σy, and τxy.');
      }

      final result = PrincipalStressCalculator.calculate(
        sigmaX: sx,
        sigmaY: sy,
        tauXY: txy,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'σ_x': '$sx',
        'σ_y': '$sy',
        'τ_xy': '$txy',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MohrsCircleResultPage(
            toolId: widget.toolId,
            title: widget.title,
            sigmaX: sx,
            sigmaY: sy,
            tauXY: txy,
            result: result,
          ),
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
