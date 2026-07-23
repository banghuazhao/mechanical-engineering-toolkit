import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/belt_drive_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeltDrivePage extends StatefulWidget {
  const BeltDrivePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeltDrivePage> createState() => _BeltDrivePageState();
}

class _BeltDrivePageState extends State<BeltDrivePage> {
  double? _d1;
  double? _d2;
  double? _c;
  double? _n1;
  double? _power;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _d1 = double.tryParse(inputs['d1'] ?? '');
    _d2 = double.tryParse(inputs['d2'] ?? '');
    _c = double.tryParse(inputs['C'] ?? '');
    _n1 = double.tryParse(inputs['n1'] ?? '');
    _power = double.tryParse(inputs['P'] ?? '');
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
              title: 'Belt / Chain Drive',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Open-belt (or roller-chain, using pitch diameters) drive geometry: speed ratio, approximate belt length, and pulley wrap angles.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Small pulley diameter, d1',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d1,
                      onChangedSI: (v) => _d1 = v,
                    ),
                    UnitField(
                      label: 'Large pulley diameter, d2',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d2,
                      onChangedSI: (v) => _d2 = v,
                    ),
                    UnitField(
                      label: 'Center distance, C',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _c,
                      onChangedSI: (v) => _c = v,
                    ),
                    UnitField(
                      label: 'Input speed, n1',
                      category: UnitCategory.angularVelocity,
                      signed: false,
                      initialSI: _n1,
                      onChangedSI: (v) => _n1 = v,
                    ),
                    UnitField(
                      label: 'Power (optional)',
                      category: UnitCategory.power,
                      signed: false,
                      initialSI: _power,
                      onChangedSI: (v) => _power = v,
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
      final d1 = _d1;
      final d2 = _d2;
      final c = _c;
      final n1 = _n1;
      if (d1 == null || d2 == null || c == null || n1 == null) {
        throw const FormatException('Enter d1, d2, C, and n1.');
      }

      final result = BeltDriveCalculator.calculate(BeltDriveInput(
        smallPulleyDiameter: d1,
        largePulleyDiameter: d2,
        centerDistance: c,
        inputSpeedRpm: n1,
        powerW: _power == null ? null : _power! * 1000,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'd1': '$d1',
        'd2': '$d2',
        'C': '$c',
        'n1': '$n1',
        'P': _power == null ? '' : '$_power',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeltDriveResultPage(
            result: result,
            d1: d1,
            d2: d2,
            c: c,
            n1: n1,
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
