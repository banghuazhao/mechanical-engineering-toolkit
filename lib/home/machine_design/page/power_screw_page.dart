import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/power_screw_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/power_screw_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

String threadFormLabel(BuildContext context, ThreadForm form) {
  final l10n = S.of(context);
  return switch (form) {
    ThreadForm.square => l10n.Thread_Form_Square,
    ThreadForm.acme => l10n.Thread_Form_ACME,
    ThreadForm.trapezoidal => l10n.Thread_Form_Trapezoidal,
  };
}

class PowerScrewPage extends StatefulWidget {
  const PowerScrewPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<PowerScrewPage> createState() => _PowerScrewPageState();
}

class _PowerScrewPageState extends State<PowerScrewPage> {
  double? _majorDiameter;
  double? _pitch;
  double? _load;
  int _starts = 1;
  ThreadForm _form = ThreadForm.acme;
  double _threadFriction = 0.15;
  double _collarFriction = 0.15;
  double? _collarDiameter = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _majorDiameter = double.tryParse(inputs['d'] ?? '');
    _pitch = double.tryParse(inputs['p'] ?? '');
    _load = double.tryParse(inputs['F'] ?? '');
    _starts = int.tryParse(inputs['starts'] ?? '') ?? 1;
    _threadFriction = double.tryParse(inputs['mu'] ?? '') ?? _threadFriction;
    _collarFriction = double.tryParse(inputs['muc'] ?? '') ?? _collarFriction;
    _collarDiameter = double.tryParse(inputs['dc'] ?? '') ?? 0;
    final savedForm = inputs['form'];
    if (savedForm != null) {
      for (final form in ThreadForm.values) {
        if (form.name == savedForm) _form = form;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_rounded),
        label: Text(l10n.Calculate),
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
              title: l10n.Power_Screw,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Power_Screw,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'T_R = \frac{F d_m}{2}\left(\frac{l + \pi \mu d_m \sec\alpha}'
                        r'{\pi d_m - \mu l \sec\alpha}\right) + \frac{F \mu_c d_c}{2}',
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<ThreadForm>(
                    segments: [
                      for (final form in ThreadForm.values)
                        ButtonSegment(
                          value: form,
                          label: Text(threadFormLabel(context, form)),
                        ),
                    ],
                    selected: {_form},
                    onSelectionChanged: (s) => setState(() => _form = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Major_Diameter_D,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _majorDiameter,
                      onChangedSI: (v) => _majorDiameter = v,
                    ),
                    UnitField(
                      label: l10n.Screw_Pitch_P,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _pitch,
                      onChangedSI: (v) => _pitch = v,
                    ),
                    TextFormField(
                      initialValue: _starts.toString(),
                      keyboardType: TextInputType.number,
                      decoration:
                          InputDecoration(labelText: l10n.Thread_Starts),
                      onChanged: (v) => _starts = int.tryParse(v) ?? _starts,
                    ),
                    UnitField(
                      label: l10n.Axial_Load_F,
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _load,
                      onChangedSI: (v) => _load = v,
                    ),
                    // Dimensionless, so no unit category and no conversion.
                    TextFormField(
                      initialValue: _threadFriction.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: l10n.Thread_Friction_Mu),
                      onChanged: (v) =>
                          _threadFriction = double.tryParse(v) ?? _threadFriction,
                    ),
                    TextFormField(
                      initialValue: _collarFriction.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: l10n.Collar_Friction_Muc),
                      onChanged: (v) =>
                          _collarFriction = double.tryParse(v) ?? _collarFriction,
                    ),
                    UnitField(
                      label: l10n.Collar_Diameter_Dc,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _collarDiameter,
                      onChangedSI: (v) => _collarDiameter = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    l10n.Collar_Hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    final l10n = S.of(context);
    try {
      final d = _majorDiameter;
      final p = _pitch;
      final f = _load;
      if (d == null || p == null || f == null) {
        throw FormatException(l10n.Err_Power_Screw_Inputs);
      }

      final input = PowerScrewInput(
        majorDiameter: d,
        pitch: p,
        load: f,
        form: _form,
        starts: _starts,
        threadFriction: _threadFriction,
        collarFriction: _collarFriction,
        collarDiameter: _collarDiameter ?? 0,
      );
      final result = PowerScrewCalculator.calculate(input);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'd': '$d',
        'p': '$p',
        'F': '$f',
        'starts': '$_starts',
        'form': _form.name,
        'mu': '$_threadFriction',
        'muc': '$_collarFriction',
        'dc': '${_collarDiameter ?? 0}',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PowerScrewResultPage(
            toolId: widget.toolId,
            title: widget.title,
            input: input,
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
