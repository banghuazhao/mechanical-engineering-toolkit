import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/solve/root_finder.dart';
import 'package:mechanical_engineering_toolkit/solve/solvers.dart';
import 'package:mechanical_engineering_toolkit/solve/tool_solver.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// "Solve for": pick an output, say what it should be, pick the input to
/// change, and get the input that makes it so — then reopen the tool with
/// that value filled in.
///
/// Sits on a result page beside the what-if chart. The chart shows how an
/// output moves as one input does; this answers the question the chart
/// raises, exactly, without reading it off a curve.
///
/// Draws nothing for a tool without a [ToolSolver], or when the calculation
/// on screen has no recorded inputs to start from.
class SolveForCard extends StatefulWidget {
  const SolveForCard({super.key, required this.toolId});

  final int toolId;

  @override
  State<SolveForCard> createState() => _SolveForCardState();
}

class _SolveForCardState extends State<SolveForCard> {
  ToolSolver? _solver;
  Map<String, String>? _recorded;
  Map<String, double>? _current;

  String? _outputKey;
  String? _inputKey;
  double? _target;
  SolveOutcome? _outcome;

  /// Bumped when the output changes, so the target field starts again from
  /// that output's current value.
  int _targetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final solver = toolSolvers[widget.toolId];
    if (solver == null) return;
    // The newest entry for this tool is the calculation on screen: every
    // tool records its inputs immediately before showing its result.
    Map<String, String>? recorded;
    for (final entry in context.read<ToolHistory>().entries) {
      if (entry.toolId != widget.toolId) continue;
      recorded = entry.inputs;
      break;
    }
    if (recorded == null) return;
    Map<String, double> current;
    try {
      current = solver.evaluate(recorded);
    } catch (_) {
      return;
    }
    final outputs = solver
        .outputs(recorded)
        .where((q) => current[q.key]?.isFinite ?? false)
        .toList();
    final inputs = solver
        .inputs(recorded)
        .where((q) => double.tryParse(recorded![q.key] ?? '') != null)
        .toList();
    if (outputs.isEmpty || inputs.isEmpty) return;
    _solver = solver;
    _recorded = recorded;
    _current = current;
    _outputKey = outputs.first.key;
    _inputKey = inputs.first.key;
    _target = _startingTarget(outputs.first);
  }

  /// The output's current value as a starting target, rounded to four
  /// significant figures in the reader's units — a target is a round number
  /// someone chose, not 50.70361988.
  double? _startingTarget(SolveQuantity output) {
    final value = _current![output.key];
    if (value == null || value == 0) return value;
    final category = output.category;
    final system = context.read<UnitSystemPreference>().system;
    final shown = category == null ? value : fromSI(value, category, system);
    final magnitude = (math.log(shown.abs()) / math.ln10).floor();
    final step = math.pow(10, magnitude - 3).toDouble();
    final rounded = (shown / step).round() * step;
    return category == null ? rounded : toSI(rounded, category, system);
  }

  List<SolveQuantity> get _outputs => _solver!
      .outputs(_recorded!)
      .where((q) => _current![q.key]?.isFinite ?? false)
      .toList();

  List<SolveQuantity> get _inputs => _solver!
      .inputs(_recorded!)
      .where((q) => double.tryParse(_recorded![q.key] ?? '') != null)
      .toList();

  SolveQuantity get _output => _outputs.firstWhere((q) => q.key == _outputKey);
  SolveQuantity get _input => _inputs.firstWhere((q) => q.key == _inputKey);

  void _solve() {
    final target = _target;
    if (target == null) return;
    final recorded = _recorded!;
    final input = _input;
    final start = double.parse(recorded[input.key]!);
    final outcome = solveForInput(
      start: start,
      target: target,
      positive: input.positive,
      evaluate: (x) {
        final value =
            _solver!.evaluate({...recorded, input.key: '$x'})[_outputKey];
        if (value == null) throw StateError('no output');
        return value;
      },
    );
    setState(() => _outcome = outcome);
  }

  /// Closes this result and reopens the tool with the solved value in its
  /// field, ready to calculate.
  void _apply(double value) {
    final l10n = S.of(context);
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final inputs = {..._recorded!, _inputKey!: '$value'};
    final label = _input.label(l10n);
    final navigator = Navigator.of(context);
    var foundTool = false;
    navigator.popUntil((route) {
      if (route is ToolPageRoute) {
        foundTool = true;
        return true;
      }
      return route.isFirst;
    });
    if (foundTool) navigator.pop();
    final hostContext = navigator.context;
    tool.action(hostContext, tool.title, tool.id, initialInputs: inputs);
    ScaffoldMessenger.of(hostContext)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.Solved_Value_Filled(label))));
  }

  @override
  Widget build(BuildContext context) {
    if (_solver == null) return const SizedBox.shrink();
    final l10n = S.of(context);
    if (PremiumGate.watch(context).isFeatureLocked(PremiumFeature.solveFor)) {
      return _LockedSolveCard();
    }
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final output = _output;
    final input = _input;

    String fmt(double value, UnitCategory? category) =>
        precs.formatSI(value, category, system);

    return AppSectionCard(
      title: l10n.Solve_For,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.Solve_For_Description,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: tokens.space3),
          AdaptiveFieldGrid(children: [
            DropdownButtonFormField<String>(
              key: const Key('solveOutput'),
              isExpanded: true,
              initialValue: _outputKey,
              decoration: InputDecoration(labelText: l10n.Solve_Target_Output),
              items: [
                for (final q in _outputs)
                  DropdownMenuItem(
                    value: q.key,
                    child: Text(q.label(l10n), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (key) => setState(() {
                _outputKey = key;
                _target =
                    _startingTarget(_outputs.firstWhere((q) => q.key == key));
                _targetGeneration++;
                _outcome = null;
              }),
            ),
            UnitField(
              key: ValueKey('solveTarget-$_outputKey-$_targetGeneration'),
              label: l10n.Solve_Target_Value,
              category: output.category,
              initialSI: _target,
              onChangedSI: (v) => setState(() {
                _target = v;
                _outcome = null;
              }),
            ),
            DropdownButtonFormField<String>(
              key: const Key('solveInput'),
              isExpanded: true,
              initialValue: _inputKey,
              decoration: InputDecoration(labelText: l10n.Solve_By_Changing),
              items: [
                for (final q in _inputs)
                  DropdownMenuItem(
                    value: q.key,
                    child: Text(q.label(l10n), overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (key) => setState(() {
                _inputKey = key;
                _outcome = null;
              }),
            ),
          ]),
          SizedBox(height: tokens.space1),
          Text(
            l10n.Solve_Current_Value(
              output.label(l10n),
              fmt(_current![_outputKey]!, output.category),
            ),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          SizedBox(height: tokens.space3),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              key: const Key('solveButton'),
              onPressed: _target == null ? null : _solve,
              icon: const Icon(Icons.track_changes_rounded),
              label: Text(l10n.Solve),
            ),
          ),
          if (_outcome != null) ...[
            SizedBox(height: tokens.space3),
            _OutcomeView(
              outcome: _outcome!,
              input: input,
              output: output,
              start: double.parse(_recorded![input.key]!),
              format: fmt,
              onApply: _apply,
            ),
          ],
        ],
      ),
    );
  }
}

class _OutcomeView extends StatelessWidget {
  const _OutcomeView({
    required this.outcome,
    required this.input,
    required this.output,
    required this.start,
    required this.format,
    required this.onApply,
  });

  final SolveOutcome outcome;
  final SolveQuantity input, output;
  final double start;
  final String Function(double value, UnitCategory? category) format;
  final ValueChanged<double> onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall
        ?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final value = outcome.value;

    if (value == null) {
      final low = outcome.reachableMin, high = outcome.reachableMax;
      return Text(
        low == null || high == null
            ? l10n.Solve_No_Solution(input.label(l10n))
            : l10n.Solve_No_Solution_Range(
                input.label(l10n),
                output.label(l10n),
                format(low, output.category),
                format(high, output.category),
              ),
        key: const Key('solveNoSolution'),
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: theme.colorScheme.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCopyableValue(
          key: const Key('solvedValue'),
          label: input.label(l10n),
          valueSI: value,
          category: input.category,
        ),
        Text(
          l10n.Solve_Was(format(start, input.category)),
          style: muted,
        ),
        if (outcome.solutionCount > 1)
          Padding(
            padding: EdgeInsets.only(top: context.tokens.space1),
            child: Text(
              l10n.Solve_Nearest_Of(outcome.solutionCount),
              style: muted,
            ),
          ),
        SizedBox(height: context.tokens.space2),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            key: const Key('applySolvedValue'),
            onPressed: () => onApply(value),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(l10n.Solve_Use_Value),
          ),
        ),
      ],
    );
  }
}

/// Stands in for the solver where the build holds it back, keeping the
/// heading so the page still says what it would have offered.
class _LockedSolveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = S.of(context);
    final theme = Theme.of(context);
    return AppSectionCard(
      title: strings.Solve_For,
      child: Row(
        children: [
          Icon(Icons.track_changes_rounded,
              color: theme.colorScheme.onSurfaceVariant),
          SizedBox(width: context.tokens.space3),
          Expanded(
            child: Text(
              strings.Premium_Locked_Solve,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () =>
                showLockedFeatureUpsell(context, PremiumFeature.solveFor),
            child: Text(strings.See_Premium),
          ),
        ],
      ),
    );
  }
}
