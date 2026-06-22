import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';

import '../../tool_setting_page.dart';

class _TwistModel {
  double? T, L, G, J;
  bool isValid() =>
      T != null && L != null && G != null && J != null && G! != 0 && J! != 0;
}

class AngleOfTwistPage extends StatefulWidget {
  final String title;
  const AngleOfTwistPage({Key? key, required this.title}) : super(key: key);

  @override
  _AngleOfTwistPageState createState() => _AngleOfTwistPageState();
}

class _AngleOfTwistPageState extends State<AngleOfTwistPage> {
  final _model = _TwistModel();
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final fields = <_FieldDef>[
      _FieldDef('T  (applied torque, N·m)', (v) => _model.T = v, () => _model.T),
      _FieldDef('L  (shaft length, m)', (v) => _model.L = v, () => _model.L),
      _FieldDef('G  (shear modulus, Pa)', (v) => _model.G = v, () => _model.G),
      _FieldDef('J  (polar moment of inertia, m⁴)', (v) => _model.J = v, () => _model.J),
    ];

    final items = [
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
                children: fields
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: f.label,
                              errorText: validate && f.getter() == null
                                  ? S.of(context).Not_a_number
                                  : null,
                            ),
                            onChanged: (v) =>
                                setState(() => f.setter(double.tryParse(v))),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Tip: For a solid circular shaft of diameter d: J = πd⁴/32\nFor hollow shaft (d_o, d_i): J = π(d_o⁴ − d_i⁴)/32',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
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
              'The angle of twist for a circular shaft under torque T:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Math.tex(
                r'''\phi = \frac{TL}{GJ}''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
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
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  void _calculate() {
    if (!_model.isValid()) return;
    final phiRad = _model.T! * _model.L! / (_model.G! * _model.J!);
    final phiDeg = phiRad * 180 / pi;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _TwistResultPage(phiRad: phiRad, phiDeg: phiDeg),
      ),
    );
  }
}

class _FieldDef {
  final String label;
  final void Function(double?) setter;
  final double? Function() getter;
  _FieldDef(this.label, this.setter, this.getter);
}

class _TwistResultPage extends StatelessWidget {
  final double phiRad;
  final double phiDeg;
  const _TwistResultPage({required this.phiRad, required this.phiDeg});

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
          itemCount: 1,
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, __) => MultipleRowResult(
            title: 'Angle of Twist',
            resultTitles: const ['φ  (radians)', 'φ  (degrees)'],
            resultValues: [phiRad, phiDeg],
          ),
        ),
      ),
    );
  }
}
