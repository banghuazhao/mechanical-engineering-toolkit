import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

enum _SolveFor { torque, power }

class ShaftPowerTorquePage extends StatefulWidget {
  const ShaftPowerTorquePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ShaftPowerTorquePage> createState() => _ShaftPowerTorquePageState();
}

class _ShaftPowerTorquePageState extends State<ShaftPowerTorquePage> {
  _SolveFor _mode = _SolveFor.torque;
  double? _power; // kW
  double? _torque; // N·m
  double? _rpm;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _mode = inputs['Mode'] == 'power' ? _SolveFor.power : _SolveFor.torque;
    _power = double.tryParse(inputs['P'] ?? '');
    _torque = double.tryParse(inputs['T'] ?? '');
    _rpm = double.tryParse(inputs['n'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
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
            AppSectionCard(
              title: 'Shaft Power & Torque',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<_SolveFor>(
                    segments: [
                      ButtonSegment(
                          value: _SolveFor.torque,
                          label: Text(S.of(context).Find_Torque),
                          icon: const Icon(Icons.rotate_right)),
                      ButtonSegment(
                          value: _SolveFor.power,
                          label: Text(S.of(context).Find_Power),
                          icon: const Icon(Icons.bolt)),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() => _mode = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  Center(
                    child: Math.tex(
                      r'''P = T\omega, \quad \omega = \frac{2\pi n}{60}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    if (_mode == _SolveFor.torque)
                      UnitField(
                        label: 'Power, P',
                        category: UnitCategory.power,
                        signed: false,
                        initialSI: _power,
                        onChangedSI: (v) => _power = v,
                      ),
                    if (_mode == _SolveFor.power)
                      UnitField(
                        label: 'Torque, T',
                        category: UnitCategory.torque,
                        signed: false,
                        initialSI: _torque,
                        onChangedSI: (v) => _torque = v,
                      ),
                    UnitField(
                      label: 'Rotational speed, n',
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
      final rpm = _rpm;
      if (rpm == null || rpm <= 0) {
        throw const FormatException('Enter a rotational speed n > 0.');
      }
      double torque;
      double power;
      if (_mode == _SolveFor.torque) {
        final p = _power;
        if (p == null) throw const FormatException('Enter power P.');
        power = p * 1000;
        final omega = 2 * pi * rpm / 60;
        torque = power / omega;
      } else {
        final t = _torque;
        if (t == null) throw const FormatException('Enter torque T.');
        torque = t;
        final omega = 2 * pi * rpm / 60;
        power = torque * omega;
      }
      final omega = 2 * pi * rpm / 60;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Mode': _mode == _SolveFor.power ? 'power' : 'torque',
        'P': _power == null ? '' : '$_power',
        'T': _torque == null ? '' : '$_torque',
        'n': '$rpm',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _ShaftPowerTorqueResultPage(
            toolId: widget.toolId,
            torque: torque,
            power: power,
            omega: omega,
            rpm: rpm,
            mode: _mode,
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

class _ShaftPowerTorqueResultPage extends StatelessWidget {
  _ShaftPowerTorqueResultPage({
    required this.toolId,
    required this.torque,
    required this.power,
    required this.omega,
    required this.rpm,
    required this.mode,
  });

  final int toolId;
  final double torque;
  final double power;
  final double omega;
  final double rpm;
  final _SolveFor mode;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final steps = mode == _SolveFor.torque
        ? [
            'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
            'T = P / ω = ${precs.formatValue(power)} / ${precs.formatValue(omega)} = ${precs.formatSI(torque, UnitCategory.torque, system)}',
          ]
        : [
            'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
            'P = T × ω = ${precs.formatSI(torque, UnitCategory.torque, system)} × ${precs.formatValue(omega)} = ${precs.formatValue(power)} W',
          ];

    return ResultScaffold(
      toolName: 'Shaft Power & Torque',
      shareLines: () => _shareLines(system, precs),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'Shaft Power & Torque',
          child: Column(children: [
            AppCopyableValue(
              label: 'Torque, T',
              valueSI: torque,
              category: UnitCategory.torque,
            ),
            AppCopyableValue(
              label: 'Power, P',
              valueSI: power / 1000,
              category: UnitCategory.power,
            ),
            AppCopyableValue(
              label: 'Angular velocity, ω',
              value: '${precs.formatValue(omega)} rad/s',
            ),
          ]),
        ),
        AppSectionCard(
          title: S.of(context).Formula,
          child: Text(steps.join('\n'),
              style: Theme.of(context).textTheme.bodyMedium),
        ),
        ParameterSweepCard(
          variableLabel: 'Speed, n',
          variableCategory: UnitCategory.angularVelocity,
          baseValueSI: rpm,
          outputLabel: mode == _SolveFor.torque ? 'T' : 'P (W)',
          outputCategory: mode == _SolveFor.torque ? UnitCategory.torque : null,
          compute: (variedRpm) {
            final w = 2 * pi * variedRpm / 60;
            return mode == _SolveFor.torque ? power / w : torque * w;
          },
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, NumberPrecisionHelper precs) {
    return mode == _SolveFor.torque
        ? [
            'T = ${precs.formatSI(torque, UnitCategory.torque, system)}',
            'P = ${precs.formatValue(power)} W (${precs.formatSI(power / 1000, UnitCategory.power, system)})',
            'ω = ${precs.formatValue(omega)} rad/s',
          ]
        : [
            'P = ${precs.formatValue(power)} W (${precs.formatSI(power / 1000, UnitCategory.power, system)})',
            'T = ${precs.formatSI(torque, UnitCategory.torque, system)}',
            'ω = ${precs.formatValue(omega)} rad/s',
          ];
  }
}
