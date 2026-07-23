import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/column_buckling_load_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

enum _EndCondition { pinnedPinned, fixedFree, fixedFixed, fixedPinned }

extension on _EndCondition {
  String get label => switch (this) {
        _EndCondition.pinnedPinned => 'Pinned-pinned column',
        _EndCondition.fixedFree => 'Fixed-free column',
        _EndCondition.fixedFixed => 'Fixed-fixed column',
        _EndCondition.fixedPinned => 'Fixed-pinned column',
      };

  double get c => switch (this) {
        _EndCondition.pinnedPinned => 1.0,
        _EndCondition.fixedFree => 0.25,
        _EndCondition.fixedFixed => 4.0,
        _EndCondition.fixedPinned => 2.046,
      };

  String get imageAsset => switch (this) {
        _EndCondition.pinnedPinned =>
          'images/buckling/icon_buckling_pinned_pinned.png',
        _EndCondition.fixedFree =>
          'images/buckling/icon_buckling_fixed_free.png',
        _EndCondition.fixedFixed =>
          'images/buckling/icon_buckling_fixed_fixed.png',
        _EndCondition.fixedPinned =>
          'images/buckling/icon_buckling_fixed_pinned.png',
      };

  String get formulaTex => switch (this) {
        _EndCondition.pinnedPinned => r'''P_{cr} = \frac{\pi^2 EI}{L^2}''',
        _EndCondition.fixedFree => r'''P_{cr} = \frac{\pi^2 EI}{4L^2}''',
        _EndCondition.fixedFixed => r'''P_{cr} = \frac{4\pi^2 EI}{L^2}''',
        _EndCondition.fixedPinned => r'''P_{cr} = \frac{2.046\pi^2 EI}{L^2}''',
      };
}

class ColumnBucklingLoadPage extends StatefulWidget {
  const ColumnBucklingLoadPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ColumnBucklingLoadPage> createState() => _ColumnBucklingLoadPageState();
}

class _ColumnBucklingLoadPageState extends State<ColumnBucklingLoadPage> {
  double? _e;
  double? _i;
  double? _l;
  _EndCondition _endCondition = _EndCondition.pinnedPinned;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _e = double.tryParse(inputs['E'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    final label = inputs['End Condition'];
    if (label != null) {
      _endCondition = _EndCondition.values
          .firstWhere((c) => c.label == label, orElse: () => _endCondition);
    }
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
              title: 'Buckling Load of Column',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The Euler buckling load in the fundamental mode of a slender column.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  DropdownButtonFormField<_EndCondition>(
                    initialValue: _endCondition,
                    decoration:
                        const InputDecoration(labelText: 'End condition'),
                    items: _EndCondition.values
                        .map((c) =>
                            DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (c) => setState(() => _endCondition = c!),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Image(
                      height: 140,
                      image: AssetImage(_endCondition.imageAsset),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      _endCondition.formulaTex,
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Modulus, E',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _e,
                      onChangedSI: (v) => _e = v,
                    ),
                    UnitField(
                      label: 'Moment of inertia, I',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _i,
                      onChangedSI: (v) => _i = v,
                    ),
                    UnitField(
                      label: 'Length, L',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _e = preset.elasticModulusSI;
                      }
                    }),
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
    try {
      final e = _e;
      final i = _i;
      final l = _l;
      if (e == null || i == null || l == null) {
        throw const FormatException('Enter E, I, and L.');
      }
      if (e <= 0 || i <= 0 || l <= 0) {
        throw const FormatException('E, I, and L must be positive.');
      }

      final c = _endCondition.c;
      // E is entered in GPa; the mm/N-based formula needs the numerically
      // equivalent MPa value (1 GPa = 1000 MPa) to keep Pcr in N.
      final pcr = c * pi * pi * (e * 1000) * i / (l * l);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'E': '$e',
        'I': '$i',
        'L': '$l',
        'End Condition': _endCondition.label,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ColumnBucklingLoadResultPage(
            toolId: widget.toolId,
            pcr: pcr,
            e: e,
            i: i,
            l: l,
            c: c,
            endCondition: _endCondition.label,
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
