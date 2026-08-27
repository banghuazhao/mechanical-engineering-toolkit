import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

const _kLoadCases = [
  'Point force at middle',
  'Distributed force evenly',
  'Moment at middle',
];

UnitCategory _forceCategory(String loadCase) {
  if (loadCase.startsWith('Distributed'))
    return UnitCategory.distributedLoadSmall;
  if (loadCase.startsWith('Moment')) return UnitCategory.momentSection;
  return UnitCategory.force;
}

class SimpleBeamDeflectionsSlopesPage extends StatefulWidget {
  const SimpleBeamDeflectionsSlopesPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<SimpleBeamDeflectionsSlopesPage> createState() =>
      _SimpleBeamDeflectionsSlopesPageState();
}

class _SimpleBeamDeflectionsSlopesPageState
    extends State<SimpleBeamDeflectionsSlopesPage> {
  String _loadCase = 'Point force at middle';
  double? _e;
  double? _i;
  double? _l;
  double? _f;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _loadCase = inputs['Type'] ?? _loadCase;
    _e = double.tryParse(inputs['E'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _f = double.tryParse(inputs['f'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
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
              title: 'Deflections and Slopes of Simple Beams',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _loadCase,
                    decoration:
                        InputDecoration(labelText: S.of(context).Load_Case),
                    items: _kLoadCases
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (c) => setState(() => _loadCase = c!),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const Image(
                        height: 130,
                        image: AssetImage(
                            'images/simple_beam/icon_simple_beam.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  _formula(context),
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
                    UnitField(
                      label:
                          _loadCase.startsWith('Moment') ? 'Moment, M' : 'Load',
                      category: _forceCategory(_loadCase),
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
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

  Widget _formula(BuildContext context) {
    String tex;
    switch (_loadCase) {
      case 'Distributed force evenly':
        tex = r'''\begin{aligned}
        v &= -\frac{qx}{24EI}(L^3-2Lx^2+x^3) \\
        \delta_C &= \delta_{max} = \frac{5qL^4}{384EI} \\
        \theta_A &= \theta_B = \frac{qL^3}{24EI}
        \end{aligned}''';
      case 'Moment at middle':
        tex = r'''\begin{aligned}
        v &= -\frac{Mx}{24LEI}(L^2-4x^2) \quad (0 \leq x \leq \tfrac{L}{2})\\
        \delta_C &= 0 \\
        \theta_A &= \frac{ML}{24EI}, \quad \theta_B = -\frac{ML}{24EI}
        \end{aligned}''';
      default:
        tex = r'''\begin{aligned}
        v &= -\frac{Px}{48EI}(3L^2-4x^2) \quad (0 \leq x \leq \tfrac{L}{2})\\
        \delta_C &= \delta_{max} = \frac{PL^3}{48EI} \\
        \theta_A &= \theta_B = \frac{PL^2}{16EI}
        \end{aligned}''';
    }
    return Center(
      child: Math.tex(
        tex,
        mathStyle: MathStyle.display,
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  void _calculate() {
    try {
      final e = _e;
      final i = _i;
      final l = _l;
      final f = _f;
      if (e == null || i == null || l == null || f == null) {
        throw const FormatException('Enter E, I, L, and the load.');
      }
      if (e <= 0 || i <= 0 || l <= 0) {
        throw const FormatException('E, I, and L must be positive.');
      }

      final precs = context.read<NumberPrecisionHelper>();
      // E is entered in GPa; the mm/N-based formulas need the numerically
      // equivalent MPa value (1 GPa = 1000 MPa).
      final ei = e * 1000 * i;

      List<String> deflectionTitles = [];
      List<String> deflectionValues = [];
      List<String> slopeTitles = [];
      List<String> slopeValues = [];

      switch (_loadCase) {
        case 'Point force at middle':
          deflectionTitles = ['v', 'δ_C', 'δ_max'];
          slopeTitles = ["v'", 'θ_A', 'θ_B'];
          final first = -f / (48 * ei);
          deflectionValues = [
            '${(first * 3 * l * l).formatted(precs)}x + ${(-first * 4).formatted(precs)}x^3',
            (f * l * l * l / (48 * ei)).formatted(precs),
            (f * l * l * l / (48 * ei)).formatted(precs),
          ];
          final second = -f / (16 * ei);
          slopeValues = [
            '${(second * l * l).formatted(precs)} + ${(-second * 4).formatted(precs)}x^2',
            (f * l * l / (16 * ei)).formatted(precs),
            (f * l * l / (16 * ei)).formatted(precs),
          ];
        case 'Distributed force evenly':
          deflectionTitles = ['v', 'δ_C', 'δ_max'];
          slopeTitles = ["v'", 'θ_A', 'θ_B'];
          final first = -f / (24 * ei);
          deflectionValues = [
            '${(first * l * l * l).formatted(precs)}x + ${(-first * 2 * l).formatted(precs)}x^3 + ${(first).formatted(precs)}x^4',
            (5 * f * l * l * l * l / (384 * ei)).formatted(precs),
            (5 * f * l * l * l * l / (384 * ei)).formatted(precs),
          ];
          final second = -f / (24 * ei);
          slopeValues = [
            '${(second * l * l * l).formatted(precs)} + ${(-second * 6 * l).formatted(precs)}x^2 + ${(second * 4).formatted(precs)}x^3',
            (f * l * l * l / (24 * ei)).formatted(precs),
            (f * l * l * l / (24 * ei)).formatted(precs),
          ];
        case 'Moment at middle':
          deflectionTitles = ['v', 'δ_C'];
          slopeTitles = ["v'", 'θ_A', 'θ_B'];
          final first = -f / (24 * l * ei);
          deflectionValues = [
            '${(first * l * l).formatted(precs)} + ${(-first * 4).formatted(precs)}x^2',
            '0',
          ];
          slopeValues = [
            '${(first * l * l).formatted(precs)} + ${(-first * 12).formatted(precs)}x^2',
            (first * l * l).formatted(precs),
            (-first * l * l).formatted(precs),
          ];
      }

      final curve = _sampleDeflectionCurve(_loadCase, ei, l, f);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'E': '$e',
        'I': '$i',
        'L': '$l',
        'f': '$f',
        'Type': _loadCase,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CantileverBeamDeflectionsSlopesResultPage(
            toolId: widget.toolId,
            toolTitle: widget.title,
            deflectionTitles: deflectionTitles,
            deflectionValues: deflectionValues,
            slopesTitles: slopeTitles,
            slopesValues: slopeValues,
            deflectionCurve: curve,
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

/// Samples the deflection curve (positive downward) across [0, L] for the
/// diagram. `ei` is E (MPa-equivalent) × I (mm⁴); all lengths in mm.
List<DiagramPoint> _sampleDeflectionCurve(
    String loadCase, double ei, double l, double f) {
  double vHalf(double x) {
    switch (loadCase) {
      case 'Point force at middle':
        return -(f / (48 * ei)) * x * (3 * l * l - 4 * x * x);
      case 'Moment at middle':
        return -(f / (24 * l * ei)) * x * (l * l - 4 * x * x);
      default:
        return 0;
    }
  }

  double vAt(double x) {
    if (loadCase == 'Distributed force evenly') {
      return -(f / (24 * ei)) * x * (l * l * l - 2 * l * x * x + x * x * x);
    }
    if (loadCase == 'Moment at middle') {
      // Antisymmetric about midspan: v(L-x) = -v(x).
      return x <= l / 2 ? vHalf(x) : -vHalf(l - x);
    }
    // Symmetric about midspan (point force at middle).
    return x <= l / 2 ? vHalf(x) : vHalf(l - x);
  }

  const n = 60;
  return List.generate(n + 1, (k) {
    final x = l * k / n;
    return DiagramPoint(x, -vAt(x));
  });
}
