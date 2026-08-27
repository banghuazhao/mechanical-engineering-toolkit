import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/fatigue_safety_factor_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FatigueSafetyFactorPage extends StatefulWidget {
  const FatigueSafetyFactorPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FatigueSafetyFactorPage> createState() =>
      _FatigueSafetyFactorPageState();
}

class _FatigueSafetyFactorPageState extends State<FatigueSafetyFactorPage> {
  double? _sigmaA;
  double? _sigmaM;
  double? _su;
  double? _se;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _sigmaA = double.tryParse(inputs['σa'] ?? '');
    _sigmaM = double.tryParse(inputs['σm'] ?? '');
    _su = double.tryParse(inputs['Su'] ?? '');
    _se = double.tryParse(inputs['Se'] ?? '');
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
              title: 'Fatigue Safety Factor',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modified-Goodman criterion for fluctuating (non-zero mean) fatigue loading. Leave the endurance limit Se blank to default to 0.5 × Su, a common rule of thumb for steel.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Alternating stress, σa',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _sigmaA,
                      onChangedSI: (v) => _sigmaA = v,
                    ),
                    UnitField(
                      label: 'Mean stress, σm',
                      category: UnitCategory.stress,
                      initialSI: _sigmaM,
                      onChangedSI: (v) => _sigmaM = v,
                    ),
                    UnitField(
                      label: 'Ultimate strength, Su',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _su,
                      onChangedSI: (v) => _su = v,
                    ),
                    UnitField(
                      label: 'Endurance limit, Se (optional)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _se,
                      onChangedSI: (v) => _se = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.ultimateStrengthSI != null) {
                        _su = preset.ultimateStrengthSI;
                      }
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: 'Description and formula',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Combines alternating and mean stress into a single factor of safety against fatigue failure, using a straight line between the endurance limit (pure alternating stress) and the ultimate strength (pure static stress) on a σa–σm diagram.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: context.tokens.space4),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'\frac{1}{n} = \frac{\sigma_a}{S_e} + \frac{\sigma_m}{S_u}',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
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
    try {
      final sigmaA = _sigmaA;
      final sigmaM = _sigmaM;
      final su = _su;
      if (sigmaA == null || sigmaM == null || su == null) {
        throw const FormatException(
            'Enter alternating stress, mean stress, and ultimate strength.');
      }
      if (sigmaA < 0 || sigmaM < 0 || su <= 0) {
        throw const FormatException(
            'Stresses must be zero or positive, and Su must be greater than zero.');
      }
      final se = (_se == null || _se == 0) ? 0.5 * su : _se!;
      if (se <= 0) {
        throw const FormatException(
            'Endurance limit must be greater than zero.');
      }

      final safetyFactor = 1 / (sigmaA / se + sigmaM / su);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'σa': '$sigmaA',
        'σm': '$sigmaM',
        'Su': '$su',
        'Se': '${_se ?? ''}',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FatigueSafetyFactorResultPage(
            toolId: widget.toolId,
            title: widget.title,
            sigmaA: sigmaA,
            sigmaM: sigmaM,
            su: su,
            se: se,
            safetyFactor: safetyFactor,
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
