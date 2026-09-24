import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/curved_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/curved_beam_result_page.dart';
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

/// The history keys this tool records, shared with its solver so that a
/// solved value reopens the tool in the right field.
abstract final class CurvedBeamKeys {
  static const section = 'section';
  static const loading = 'loading';
  static const flangeInside = 'flangeInside';
  static const ri = 'ri';
  static const h = 'h';
  static const b = 'b';
  static const bi = 'bi';
  static const bo = 'bo';
  static const d = 'd';
  static const di = 'di';
  static const bf = 'bf';
  static const tf = 'tf';
  static const tw = 'tw';
  static const b2 = 'b2';
  static const t2 = 't2';
  static const m = 'M';
  static const n = 'N';
}

String curvedSectionLabel(BuildContext context, CurvedSection section) {
  final l10n = S.of(context);
  return switch (section) {
    CurvedSection.rectangle => l10n.Section_Rectangle,
    CurvedSection.trapezoid => l10n.Section_Trapezoid,
    CurvedSection.circle => l10n.Section_Solid_Round,
    CurvedSection.tube => l10n.Section_Round_Tube,
    CurvedSection.tSection => l10n.Section_T,
    CurvedSection.iSection => l10n.Section_I,
  };
}

/// Rebuilds the calculator input from recorded inputs — the page's own
/// history entry, or a solver varying one of them.
CurvedBeamInput curvedBeamInputFrom(Map<String, String> inputs) {
  double v(String key) => double.tryParse(inputs[key] ?? '') ?? 0;
  T named<T extends Enum>(List<T> values, String key, T fallback) {
    for (final value in values) {
      if (value.name == inputs[key]) return value;
    }
    return fallback;
  }

  return CurvedBeamInput(
    section: named(
        CurvedSection.values, CurvedBeamKeys.section, CurvedSection.rectangle),
    loading: named(CurvedBeamLoading.values, CurvedBeamKeys.loading,
        CurvedBeamLoading.moment),
    flangeInside: inputs[CurvedBeamKeys.flangeInside] != 'false',
    innerRadius: v(CurvedBeamKeys.ri),
    depth: v(CurvedBeamKeys.h),
    width: v(CurvedBeamKeys.b),
    innerWidth: v(CurvedBeamKeys.bi),
    outerWidth: v(CurvedBeamKeys.bo),
    diameter: v(CurvedBeamKeys.d),
    boreDiameter: v(CurvedBeamKeys.di),
    flangeWidth: v(CurvedBeamKeys.bf),
    flangeThickness: v(CurvedBeamKeys.tf),
    webThickness: v(CurvedBeamKeys.tw),
    outerFlangeWidth: v(CurvedBeamKeys.b2),
    outerFlangeThickness: v(CurvedBeamKeys.t2),
    moment: v(CurvedBeamKeys.m),
    normalForce: v(CurvedBeamKeys.n),
  );
}

class CurvedBeamPage extends StatefulWidget {
  const CurvedBeamPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<CurvedBeamPage> createState() => _CurvedBeamPageState();
}

class _CurvedBeamPageState extends State<CurvedBeamPage> {
  CurvedSection _section = CurvedSection.rectangle;
  CurvedBeamLoading _loading = CurvedBeamLoading.moment;
  bool _flangeInside = true;

  /// Every numeric field, by history key. Kept across a change of section so
  /// switching back and forth does not lose what was typed.
  final Map<String, double?> _values = {};

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    final restored = curvedBeamInputFrom(inputs);
    _section = restored.section;
    _loading = restored.loading;
    _flangeInside = restored.flangeInside;
    for (final entry in inputs.entries) {
      final value = double.tryParse(entry.value);
      if (value != null) _values[entry.key] = value;
    }
  }

  /// The dimension fields [_section] needs, in the order a drawing gives
  /// them: overall size first, then the parts.
  List<(String, String)> _dimensionFields(S l10n) => switch (_section) {
        CurvedSection.rectangle => [
            (CurvedBeamKeys.h, l10n.Radial_Depth_H),
            (CurvedBeamKeys.b, l10n.Section_Width_b),
          ],
        CurvedSection.trapezoid => [
            (CurvedBeamKeys.h, l10n.Radial_Depth_H),
            (CurvedBeamKeys.bi, l10n.Inner_Width_Bi),
            (CurvedBeamKeys.bo, l10n.Outer_Width_Bo),
          ],
        CurvedSection.circle => [
            (CurvedBeamKeys.d, l10n.Diameter_D),
          ],
        CurvedSection.tube => [
            (CurvedBeamKeys.d, l10n.Diameter_D),
            (CurvedBeamKeys.di, l10n.Bore_Diameter_Di),
          ],
        CurvedSection.tSection => [
            (CurvedBeamKeys.h, l10n.Radial_Depth_H),
            (CurvedBeamKeys.bf, l10n.Flange_Width_Bf),
            (CurvedBeamKeys.tf, l10n.Flange_Thickness_Tf),
            (CurvedBeamKeys.tw, l10n.Web_Thickness_Tw),
          ],
        CurvedSection.iSection => [
            (CurvedBeamKeys.h, l10n.Radial_Depth_H),
            (CurvedBeamKeys.bf, l10n.Inner_Flange_Width_B1),
            (CurvedBeamKeys.tf, l10n.Inner_Flange_Thickness_T1),
            (CurvedBeamKeys.b2, l10n.Outer_Flange_Width_B2),
            (CurvedBeamKeys.t2, l10n.Outer_Flange_Thickness_T2),
            (CurvedBeamKeys.tw, l10n.Web_Thickness_Tw),
          ],
      };

  Widget _lengthField(String key, String label) => UnitField(
        // Keyed by section as well, so a field reused at the same position by
        // another shape starts from its own value rather than the last one's.
        key: ValueKey('${_section.name}-$key'),
        label: label,
        category: UnitCategory.length,
        signed: false,
        initialSI: _values[key],
        onChangedSI: (v) => _values[key] = v,
      );

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final hook = _loading == CurvedBeamLoading.hook;
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
              title: l10n.Curved_Beam,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Curved_Beam,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'\sigma = \frac{N}{A} + \frac{M\,(r_n - r)}{A\,e\,r},'
                        r'\qquad r_n = \frac{A}{\int dA/r}',
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Section_Shape,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: context.tokens.space2,
                    runSpacing: context.tokens.space2,
                    children: [
                      for (final section in CurvedSection.values)
                        ChoiceChip(
                          key: ValueKey('section-${section.name}'),
                          label: Text(curvedSectionLabel(context, section)),
                          selected: _section == section,
                          onSelected: (_) => setState(() => _section = section),
                        ),
                    ],
                  ),
                  if (_section == CurvedSection.tSection) ...[
                    SizedBox(height: context.tokens.space3),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                            value: true, label: Text(l10n.Flange_Inside)),
                        ButtonSegment(
                            value: false, label: Text(l10n.Flange_Outside)),
                      ],
                      selected: {_flangeInside},
                      onSelectionChanged: (s) =>
                          setState(() => _flangeInside = s.first),
                    ),
                  ],
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    _lengthField(CurvedBeamKeys.ri, l10n.Inner_Radius_Ri),
                    for (final (key, label) in _dimensionFields(l10n))
                      _lengthField(key, label),
                  ]),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Section_Loading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SegmentedButton<CurvedBeamLoading>(
                    segments: [
                      ButtonSegment(
                        value: CurvedBeamLoading.moment,
                        label: Text(l10n.Loading_Moment),
                      ),
                      ButtonSegment(
                        value: CurvedBeamLoading.hook,
                        label: Text(l10n.Loading_Hook),
                      ),
                    ],
                    selected: {_loading},
                    onSelectionChanged: (s) =>
                        setState(() => _loading = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    if (!hook)
                      UnitField(
                        key: const ValueKey('curved-M'),
                        label: l10n.Bending_Moment_Straightening,
                        category: UnitCategory.momentSection,
                        initialSI: _values[CurvedBeamKeys.m],
                        onChangedSI: (v) => _values[CurvedBeamKeys.m] = v,
                      ),
                    UnitField(
                      key: ValueKey('curved-N-${_loading.name}'),
                      label: hook ? l10n.Hook_Load_F : l10n.Normal_Force_N,
                      category: UnitCategory.force,
                      initialSI: _values[CurvedBeamKeys.n],
                      onChangedSI: (v) => _values[CurvedBeamKeys.n] = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    hook
                        ? l10n.Curved_Beam_Hook_Hint
                        : l10n.Curved_Beam_Sign_Hint,
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
    final needed = [
      CurvedBeamKeys.ri,
      for (final (key, _) in _dimensionFields(l10n)) key,
    ];
    final hook = _loading == CurvedBeamLoading.hook;
    try {
      if (needed.any((key) => _values[key] == null) ||
          (hook && _values[CurvedBeamKeys.n] == null) ||
          (!hook && _values[CurvedBeamKeys.m] == null)) {
        throw FormatException(l10n.Err_Curved_Beam_Inputs);
      }

      // Only what this section and loading use is recorded, so a history row
      // and a saved project list the inputs that produced the answer.
      final inputs = <String, String>{
        CurvedBeamKeys.section: _section.name,
        CurvedBeamKeys.loading: _loading.name,
        if (_section == CurvedSection.tSection)
          CurvedBeamKeys.flangeInside: '$_flangeInside',
        for (final key in needed) key: '${_values[key]}',
        if (!hook) CurvedBeamKeys.m: '${_values[CurvedBeamKeys.m]}',
        CurvedBeamKeys.n: '${_values[CurvedBeamKeys.n] ?? 0}',
      };
      final input = curvedBeamInputFrom(inputs);
      final result = CurvedBeamCalculator.calculate(input);

      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

      showToolResult(
        context,
        (context) => CurvedBeamResultPage(
          toolId: widget.toolId,
          title: widget.title,
          input: input,
          result: result,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
