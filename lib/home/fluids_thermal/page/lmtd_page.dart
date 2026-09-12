import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/lmtd_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class LmtdPage extends StatefulWidget {
  const LmtdPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<LmtdPage> createState() => _LmtdPageState();
}

class _LmtdPageState extends State<LmtdPage> {
  FlowArrangement _arrangement = FlowArrangement.counterFlow;
  double? _hotInlet;
  double? _hotOutlet;
  double? _coldInlet;
  double? _coldOutlet;
  double? _overallCoefficient;
  double? _heatDuty;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _arrangement = inputs['Flow'] == 'parallel'
        ? FlowArrangement.parallelFlow
        : FlowArrangement.counterFlow;
    _hotInlet = double.tryParse(inputs['Thi'] ?? '');
    _hotOutlet = double.tryParse(inputs['Tho'] ?? '');
    _coldInlet = double.tryParse(inputs['Tci'] ?? '');
    _coldOutlet = double.tryParse(inputs['Tco'] ?? '');
    _overallCoefficient = double.tryParse(inputs['U'] ?? '');
    _heatDuty = double.tryParse(inputs['Q'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
      floatingActionButton: CalculateButton(onPressed: _calculate),
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
              title: l10n.Heat_Exchanger_LMTD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Lmtd,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<FlowArrangement>(
                    segments: [
                      ButtonSegment(
                        value: FlowArrangement.counterFlow,
                        label: Text(FlowArrangement.counterFlow.label(context)),
                      ),
                      ButtonSegment(
                        value: FlowArrangement.parallelFlow,
                        label:
                            Text(FlowArrangement.parallelFlow.label(context)),
                      ),
                    ],
                    selected: {_arrangement},
                    onSelectionChanged: (selection) =>
                        setState(() => _arrangement = selection.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Hot_Inlet,
                      category: UnitCategory.temperature,
                      initialSI: _hotInlet,
                      onChangedSI: (v) => _hotInlet = v,
                    ),
                    UnitField(
                      label: l10n.Hot_Outlet,
                      category: UnitCategory.temperature,
                      initialSI: _hotOutlet,
                      onChangedSI: (v) => _hotOutlet = v,
                    ),
                    UnitField(
                      label: l10n.Cold_Inlet,
                      category: UnitCategory.temperature,
                      initialSI: _coldInlet,
                      onChangedSI: (v) => _coldInlet = v,
                    ),
                    UnitField(
                      label: l10n.Cold_Outlet,
                      category: UnitCategory.temperature,
                      initialSI: _coldOutlet,
                      onChangedSI: (v) => _coldOutlet = v,
                    ),
                    UnitField(
                      label: l10n.Overall_Coefficient_U,
                      category: UnitCategory.heatTransferCoefficient,
                      signed: false,
                      initialSI: _overallCoefficient,
                      onChangedSI: (v) => _overallCoefficient = v,
                    ),
                    UnitField(
                      label: l10n.Heat_Duty_Q,
                      category: UnitCategory.heatFlow,
                      signed: false,
                      initialSI: _heatDuty,
                      onChangedSI: (v) => _heatDuty = v,
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
      final hotInlet = _hotInlet;
      final hotOutlet = _hotOutlet;
      final coldInlet = _coldInlet;
      final coldOutlet = _coldOutlet;
      final u = _overallCoefficient;
      final duty = _heatDuty;
      if (hotInlet == null ||
          hotOutlet == null ||
          coldInlet == null ||
          coldOutlet == null ||
          u == null ||
          duty == null) {
        throw FormatException(S.of(context).Err_Enter_Lmtd_Inputs);
      }

      final result = LmtdCalculator.calculate(
        hotInlet: hotInlet,
        hotOutlet: hotOutlet,
        coldInlet: coldInlet,
        coldOutlet: coldOutlet,
        arrangement: _arrangement,
        overallCoefficient: u,
        heatDuty: duty,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Flow': _arrangement == FlowArrangement.parallelFlow
            ? 'parallel'
            : 'counter',
        'Thi': '$hotInlet',
        'Tho': '$hotOutlet',
        'Tci': '$coldInlet',
        'Tco': '$coldOutlet',
        'U': '$u',
        'Q': '$duty',
      });

      showToolResult(
        context,
        (context) => LmtdResultPage(
          result: result,
          arrangement: _arrangement,
          overallCoefficient: u,
          heatDuty: duty,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
