import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/bearing_life_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/bearing_life_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BearingLifePage extends StatefulWidget {
  const BearingLifePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BearingLifePage> createState() => _BearingLifePageState();
}

class _BearingLifePageState extends State<BearingLifePage> {
  BearingType _type = BearingType.ball;
  double? _c;
  double? _p;
  double? _rpm;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _type = inputs['Type'] == 'roller' ? BearingType.roller : BearingType.ball;
    _c = double.tryParse(inputs['C'] ?? '');
    _p = double.tryParse(inputs['P'] ?? '');
    _rpm = double.tryParse(inputs['n'] ?? '');
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
              title: S.of(context).Bearing_L10_Life,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Bearing_Life,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<BearingType>(
                    segments: [
                      ButtonSegment(
                          value: BearingType.ball,
                          label: Text(BearingType.ball.label(context))),
                      ButtonSegment(
                          value: BearingType.roller,
                          label: Text(BearingType.roller.label(context))),
                    ],
                    selected: {_type},
                    onSelectionChanged: (s) => setState(() => _type = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: S.of(context).Dynamic_Load_Rating_C,
                      category: UnitCategory.forceStructural,
                      signed: false,
                      initialSI: _c,
                      onChangedSI: (v) => _c = v,
                    ),
                    UnitField(
                      label: S.of(context).Equivalent_Load_P,
                      category: UnitCategory.forceStructural,
                      signed: false,
                      initialSI: _p,
                      onChangedSI: (v) => _p = v,
                    ),
                    UnitField(
                      label: S.of(context).Speed_N,
                      category: UnitCategory.angularVelocity,
                      signed: false,
                      initialSI: _rpm,
                      onChangedSI: (v) => _rpm = v,
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
      final c = _c;
      final p = _p;
      final rpm = _rpm;
      if (c == null || p == null || rpm == null) {
        throw FormatException(S.of(context).Err_Enter_C_P_N);
      }

      final result = BearingLifeCalculator.calculate(
        dynamicLoadRating: c,
        equivalentLoad: p,
        type: _type,
        speedRpm: rpm,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Type': _type == BearingType.roller ? 'roller' : 'ball',
        'C': '$c',
        'P': '$p',
        'n': '$rpm',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BearingLifeResultPage(
            result: result,
            c: c,
            p: p,
            rpm: rpm,
            type: _type,
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
