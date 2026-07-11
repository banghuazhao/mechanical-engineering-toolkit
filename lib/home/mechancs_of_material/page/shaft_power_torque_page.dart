import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

enum _SolveFor { torque, power }

class ShaftPowerTorquePage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const ShaftPowerTorquePage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _ShaftPowerTorquePageState createState() => _ShaftPowerTorquePageState();
}

class _ShaftPowerTorquePageState extends State<ShaftPowerTorquePage> {
  _SolveFor _mode = _SolveFor.torque;
  double? _power; // in kW
  double? _torque; // in N·m
  double? _rpm;
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      String modeStr = widget.initialInputs!["Mode"] ?? "torque";
      _mode = modeStr == "power" ? _SolveFor.power : _SolveFor.torque;
      _power = double.tryParse(widget.initialInputs!["P"] ?? "");
      _torque = double.tryParse(widget.initialInputs!["T"] ?? "");
      _rpm = double.tryParse(widget.initialInputs!["n"] ?? "");
    }
  }

  bool get _inputsReady {
    if (_mode == _SolveFor.torque)
      return _power != null && _rpm != null && _rpm! > 0;
    return _torque != null && _rpm != null && _rpm! > 0;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final items = [
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'SOLVE FOR',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const Divider(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<_SolveFor>(
                segments: const [
                  ButtonSegment(
                      value: _SolveFor.torque,
                      label: Text('Find Torque'),
                      icon: Icon(Icons.rotate_right)),
                  ButtonSegment(
                      value: _SolveFor.power,
                      label: Text('Find Power'),
                      icon: Icon(Icons.bolt)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'INPUTS',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const Divider(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  if (_mode == _SolveFor.torque)
                    _field('P  (power, kW)', validate && _power == null,
                        (v) => setState(() => _power = double.tryParse(v))),
                  if (_mode == _SolveFor.power)
                    _field('T  (torque, N·m)', validate && _torque == null,
                        (v) => setState(() => _torque = double.tryParse(v))),
                  const SizedBox(height: 12),
                  _field(
                      'n  (rotational speed, RPM)',
                      validate && (_rpm == null || _rpm == 0),
                      (v) => setState(() => _rpm = double.tryParse(v))),
                ],
              ),
            ),
          ],
        ),
      ),
      DescriptionItem(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Power–torque relationships:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Math.tex(
                r'''P = T\omega, \quad \omega = \frac{2\pi n}{60}''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''T = \frac{9550\,P}{n} \quad [P\text{ in kW, }n\text{ in RPM}]''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => validate = true);
          _calculate();
        },
        label: Text(S.of(context).Calculate),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: items.length,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  Widget _field(String label, bool showError, void Function(String) onChanged) {
    return TextField(
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        border: const OutlineInputBorder(),
        labelText: label,
        errorText: showError ? S.of(context).Not_a_number : null,
      ),
      onChanged: onChanged,
    );
  }

  void _calculate() {
    if (!_inputsReady) return;
    final omega = 2 * pi * _rpm! / 60; // rad/s
    double torque, power;
    if (_mode == _SolveFor.torque) {
      power = _power! * 1000; // W
      torque = power / omega;
    } else {
      torque = _torque!;
      power = torque * omega;
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: {
      "Mode": _mode.toString().split('.').last,
      "P": _power?.toString() ?? "",
      "T": _torque?.toString() ?? "",
      "n": _rpm!.toString(),
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PowerTorqueResultPage(
            torque: torque,
            power: power,
            omega: omega,
            rpm: _rpm!,
            mode: _mode),
      ),
    );
  }
}

class _PowerTorqueResultPage extends StatelessWidget {
  final double torque, power, omega, rpm;
  final _SolveFor mode;
  const _PowerTorqueResultPage(
      {required this.torque,
      required this.power,
      required this.omega,
      required this.rpm,
      required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              final precs =
                  Provider.of<NumberPrecisionHelper>(context, listen: false);
              final lines = mode == _SolveFor.torque
                  ? [
                      'T = ${precs.formatValue(torque)} N·m',
                      'P = ${precs.formatValue(power)} W  (${precs.formatValue(power / 1000)} kW)',
                      'ω = ${precs.formatValue(omega)} rad/s',
                      '',
                      'Calculation:',
                      'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
                      'T = P / ω = ${precs.formatValue(power)} / ${precs.formatValue(omega)} = ${precs.formatValue(torque)} N·m',
                    ]
                  : [
                      'P = ${precs.formatValue(power)} W  (${precs.formatValue(power / 1000)} kW)',
                      'T = ${precs.formatValue(torque)} N·m',
                      'ω = ${precs.formatValue(omega)} rad/s',
                      '',
                      'Calculation:',
                      'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
                      'P = T × ω = ${precs.formatValue(torque)} × ${precs.formatValue(omega)} = ${precs.formatValue(power)} W',
                    ];
              shareResult('Shaft Power & Torque', lines);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: 2,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) {
            return [
              MultipleRowResult(
                title: 'Shaft Power & Torque',
                resultTitles: const [
                  'T  (torque, N·m)',
                  'P  (power, W)',
                  'P  (power, kW)',
                  'ω  (angular velocity, rad/s)',
                ],
                resultValues: [torque, power, power / 1000, omega],
              ),
              Consumer<NumberPrecisionHelper>(
                builder: (context, precs, _) {
                  final steps = mode == _SolveFor.torque
                      ? [
                          'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
                          'T = P / ω = ${precs.formatValue(power)} / ${precs.formatValue(omega)} = ${precs.formatValue(torque)} N·m',
                        ]
                      : [
                          'ω = 2π·n / 60 = 2π × ${precs.formatValue(rpm)} / 60 = ${precs.formatValue(omega)} rad/s',
                          'P = T × ω = ${precs.formatValue(torque)} × ${precs.formatValue(omega)} = ${precs.formatValue(power)} W',
                        ];
                  return CalculationCard(steps: steps);
                },
              ),
            ][i];
          },
        ),
      ),
    );
  }
}
