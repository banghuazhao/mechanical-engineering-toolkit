import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

const _kLoadCases = [
  'Point force at end',
  'Point force',
  'Distributed force evenly',
  'Distributed force',
  'Moment at end',
  'Moment',
];

bool _needsA(String loadCase) =>
    loadCase == 'Point force' ||
    loadCase == 'Distributed force' ||
    loadCase == 'Moment';

UnitCategory _forceCategory(String loadCase) {
  if (loadCase.startsWith('Distributed'))
    return UnitCategory.distributedLoadSmall;
  if (loadCase.startsWith('Moment')) return UnitCategory.momentSection;
  return UnitCategory.force;
}

class CantileverBeamDeflectionsSlopesPage extends StatefulWidget {
  const CantileverBeamDeflectionsSlopesPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<CantileverBeamDeflectionsSlopesPage> createState() =>
      _CantileverBeamDeflectionsSlopesPageState();
}

class _CantileverBeamDeflectionsSlopesPageState
    extends State<CantileverBeamDeflectionsSlopesPage> {
  String _loadCase = 'Point force at end';
  double? _e;
  double? _i;
  double? _l;
  double? _f;
  double? _a;

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
    _a = double.tryParse(inputs['a'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final needsA = _needsA(_loadCase);
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
              title: 'Deflections and Slopes of Cantilever Beams',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _loadCase,
                    decoration: const InputDecoration(labelText: 'Load case'),
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
                            'images/cantilever_beam/icon_cantilever_beam.png'),
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
                    if (needsA)
                      UnitField(
                        label: 'Position, a',
                        category: UnitCategory.length,
                        signed: false,
                        initialSI: _a,
                        onChangedSI: (v) => _a = v,
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
      case 'Point force':
        tex = r'''\begin{aligned}
        v &= -\frac{Px^2}{6EI}(3a-x) \quad (0 \leq x \leq a)\\
        v &= -\frac{Pa^2}{6EI}(3x-a) \quad (a \leq x \leq L)\\
        \delta_B &= \frac{Pa^2}{3EI}(3L - a) \\
        \theta_B &= \frac{Pa^2}{2EI}
        \end{aligned}''';
      case 'Distributed force evenly':
        tex = r'''\begin{aligned}
        v &= -\frac{qx^2}{24EI}(6L^2-4Lx+x^2) \\
        \delta_B &= \frac{qL^4}{8EI} \\
        \theta_B &= \frac{qL^3}{6EI}
        \end{aligned}''';
      case 'Distributed force':
        tex = r'''\begin{aligned}
        v &= -\frac{qx^2}{24EI}(6a^2-4ax+x^2) \\ &(0 \leq x \leq a)\\
        v &= -\frac{qa^3}{24EI}(4x-a) \quad (a \leq x \leq L)\\
        \delta_B &= \frac{qa^3}{24EI}(4L - a) \\
        \theta_B &= \frac{qa^3}{6EI}
        \end{aligned}''';
      case 'Moment at end':
        tex = r'''\begin{aligned}
        v &= -\frac{Mx^2}{2EI} \\
        \delta_B &= \frac{ML^2}{2EI} \\
        \theta_B &= \frac{ML}{EI}
        \end{aligned}''';
      case 'Moment':
        tex = r'''\begin{aligned}
        v &= -\frac{Mx^2}{2EI} \quad (0 \leq x \leq a)\\
        v &= -\frac{Ma}{2EI}(2x-a) \quad (a \leq x \leq L)\\
        \delta_B &= \frac{Ma}{2EI}(2L-a) \\
        \theta_B &= \frac{Ma}{EI}
        \end{aligned}''';
      default:
        tex = r'''\begin{aligned}
        v &= -\frac{Px^2}{6EI}(3L-x) \\
        \delta_B &= \frac{PL^3}{3EI} \\
        \theta_B &= \frac{PL^2}{2EI}
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
      final needsA = _needsA(_loadCase);
      final a = needsA ? _a : 0.0;
      if (needsA && (a == null || a < 0 || a > l)) {
        throw const FormatException('Position a must be between 0 and L.');
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
        case 'Point force at end':
          deflectionTitles = ['v', 'δ_B'];
          slopeTitles = ["v'", 'θ_B'];
          final first = -f / (6 * ei);
          deflectionValues = [
            '${(first * 3 * l).formatted(precs)}x^2 + ${(-first).formatted(precs)}x^3',
            (f * l * l * l / (3 * ei)).formatted(precs),
          ];
          final second = -f / (2 * ei);
          slopeValues = [
            '${(second * 2 * l).formatted(precs)}x + ${(-second).formatted(precs)}x^2',
            (f * l * l / (2 * ei)).formatted(precs),
          ];
        case 'Point force':
          deflectionTitles = ['v (0<=x<=a)', 'v (a<=x<=L)', 'δ_B'];
          slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", 'θ_B'];
          final first = -f / (6 * ei);
          deflectionValues = [
            '${(first * 3 * a!).formatted(precs)}x^2 + ${(-first).formatted(precs)}x^3',
            '${(first * 3 * a * a).formatted(precs)}x + ${(-first * a * a * a).formatted(precs)}',
            (f * a * a / (6 * ei) * (3 * l - a)).formatted(precs),
          ];
          final second = -f / (2 * ei);
          slopeValues = [
            '${(second * 2 * a).formatted(precs)}x + ${(second).formatted(precs)}x^2',
            (second * a * a).formatted(precs),
            (f * a * a / (2 * ei)).formatted(precs),
          ];
        case 'Distributed force evenly':
          deflectionTitles = ['v', 'δ_B'];
          slopeTitles = ["v'", 'θ_B'];
          final first = -f / (24 * ei);
          deflectionValues = [
            '${(first * 6 * l * l).formatted(precs)}x^2 + ${(-first * 4 * l).formatted(precs)}x^3 + ${(first).formatted(precs)}x^4',
            (f * l * l * l * l / (8 * ei)).formatted(precs),
          ];
          final second = -f / (6 * ei);
          slopeValues = [
            '${(second * 3 * l * l).formatted(precs)}x + ${(-second * 3 * l).formatted(precs)}x^2 + ${(second).formatted(precs)}x^3',
            (f * l * l * l / (6 * ei)).formatted(precs),
          ];
        case 'Distributed force':
          deflectionTitles = ['v (0<=x<=a)', 'v (a<=x<=L)', 'δ_B'];
          slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", 'θ_B'];
          final first = -f / (24 * ei);
          deflectionValues = [
            '${(first * 6 * a! * a).formatted(precs)}x^2 + ${(-first * 4 * a).formatted(precs)}x^3 + ${(first).formatted(precs)}x^4',
            '${(first * 4 * a * a * a).formatted(precs)}x + ${(-first * a * a * a * a).formatted(precs)}',
            (-first * a * a * a * (4 * l - a)).formatted(precs),
          ];
          final second = -f / (6 * ei);
          slopeValues = [
            '${(second * 3 * a * a).formatted(precs)}x + ${(-second * 3 * a).formatted(precs)}x^2 + ${(second).formatted(precs)}x^3',
            (second * a * a * a).formatted(precs),
            (f * a * a * a / (6 * ei)).formatted(precs),
          ];
        case 'Moment at end':
          deflectionTitles = ['v', 'δ_B'];
          slopeTitles = ["v'", 'θ_B'];
          final first = -f / (2 * ei);
          deflectionValues = [
            '${(first).formatted(precs)}x^2',
            (-first * l * l).formatted(precs)
          ];
          final second = -f / ei;
          slopeValues = [
            '${(second).formatted(precs)}x',
            (-second * l).formatted(precs)
          ];
        case 'Moment':
          deflectionTitles = ['v (0<=x<=a)', 'v (a<=x<=L)', 'δ_B'];
          slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", 'θ_B'];
          final first = -f / (2 * ei);
          deflectionValues = [
            '${(first).formatted(precs)}x^2',
            '${(first * 2 * a!).formatted(precs)}x + ${(-first * a * a).formatted(precs)}',
            (-first * a * (2 * l - a)).formatted(precs),
          ];
          final second = -f / ei;
          slopeValues = [
            '${(second).formatted(precs)}x',
            (second * a).formatted(precs),
            (-second * a).formatted(precs),
          ];
      }

      final curve = _sampleDeflectionCurve(_loadCase, ei, l, f, a ?? 0);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'E': '$e',
        'I': '$i',
        'L': '$l',
        'f': '$f',
        'a': '${a ?? ''}',
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
    String loadCase, double ei, double l, double f, double a) {
  double vAt(double x) {
    switch (loadCase) {
      case 'Point force at end':
        return -(f / (6 * ei)) * x * x * (3 * l - x);
      case 'Point force':
        return x <= a
            ? -(f / (6 * ei)) * x * x * (3 * a - x)
            : -(f / (6 * ei)) * a * a * (3 * x - a);
      case 'Distributed force evenly':
        return -(f / (24 * ei)) * x * x * (6 * l * l - 4 * l * x + x * x);
      case 'Distributed force':
        return x <= a
            ? -(f / (24 * ei)) * x * x * (6 * a * a - 4 * a * x + x * x)
            : -(f / (24 * ei)) * a * a * a * (4 * x - a);
      case 'Moment at end':
        return -(f / (2 * ei)) * x * x;
      case 'Moment':
        return x <= a
            ? -(f / (2 * ei)) * x * x
            : -(f / (2 * ei)) * a * (2 * x - a);
      default:
        return 0;
    }
  }

  const n = 60;
  return List.generate(n + 1, (k) {
    final x = l * k / n;
    return DiagramPoint(x, -vAt(x));
  });
}
