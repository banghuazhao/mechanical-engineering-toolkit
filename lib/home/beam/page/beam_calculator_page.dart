import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_solver.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/standard_section_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// History key holding the load list as a JSON array.
///
/// One key rather than a key per field, for the reason the tolerance stack-up
/// uses one: the list has no fixed length, so there is no stable set of input
/// labels to key by, and a project saved with four loads must not half-restore
/// into a tool expecting one.
const beamLoadsKey = 'loads';

/// The scalar history keys, unchanged from the versions of this tool that
/// only ever analysed a simply supported beam. Old projects and history
/// entries still open — see [_LoadDraft.legacy].
const _spanKey = 'Span (m)';
const _modulusKey = 'Elastic modulus (GPa)';
const _secondMomentKey = 'Second moment (mm4)';
const beamSupportCaseKey = 'Support case';
const _leftSupportKey = 'Left support (m)';
const _rightSupportKey = 'Right support (m)';
const _extremeFibreKey = 'Extreme fibre (mm)';
const _legacyPointLoadKey = 'Point load (kN)';
const _legacyPointPositionKey = 'Point position (m)';
const _legacyUdlKey = 'UDL (kN/m)';

/// The saved chain read back as a line of prose, for the one-line summary
/// History and saved projects show under a calculation.
///
/// Returns null for anything this build cannot read, so a caller can fall back
/// to its own wording rather than print a wall of JSON.
String? describeBeamLoads(String raw) {
  final List<dynamic> decoded;
  try {
    final parsed = jsonDecode(raw);
    if (parsed is! List) return null;
    decoded = parsed;
  } catch (_) {
    return null;
  }

  final parts = <String>[];
  for (final entry in decoded) {
    if (entry is! Map) continue;
    switch (entry['type']) {
      case 'point':
        final p = (entry['magnitude'] as num?)?.toDouble();
        final x = (entry['position'] as num?)?.toDouble();
        if (p == null || x == null) continue;
        parts.add('${_trimmed(p)} kN @ ${_trimmed(x)} m');
      case 'distributed':
        final w1 = (entry['startIntensity'] as num?)?.toDouble();
        final w2 = (entry['endIntensity'] as num?)?.toDouble();
        final a = (entry['start'] as num?)?.toDouble();
        final b = (entry['end'] as num?)?.toDouble();
        if (w1 == null || w2 == null || a == null || b == null) continue;
        final intensity =
            w1 == w2 ? _trimmed(w1) : '${_trimmed(w1)}–${_trimmed(w2)}';
        parts.add('$intensity kN/m over ${_trimmed(a)}–${_trimmed(b)} m');
      case 'couple':
        final m = (entry['magnitude'] as num?)?.toDouble();
        final x = (entry['position'] as num?)?.toDouble();
        if (m == null || x == null) continue;
        parts.add('${_trimmed(m)} kN·m @ ${_trimmed(x)} m');
    }
  }
  return parts.isEmpty ? null : parts.join(', ');
}

String _trimmed(double value) {
  final text = value.toStringAsFixed(3);
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

enum _LoadKind { point, distributed, couple }

/// One load being edited. Mutable and identified, unlike the immutable
/// [BeamLoad] the solver takes: rows are added and deleted, and a field's
/// state has to follow its row rather than its position in the list.
class _LoadDraft {
  _LoadDraft({
    this.kind = _LoadKind.point,
    this.position,
    this.magnitude,
    this.start,
    this.end,
    this.startIntensity,
    this.endIntensity,
  });

  static int _nextId = 0;
  final int id = _nextId++;

  _LoadKind kind;

  /// Point load and couple: where it acts, m.
  double? position;

  /// Point load, kN down; couple, kN·m counter-clockwise.
  double? magnitude;

  /// Distributed load: the loaded length, m, and its intensities, kN/m down.
  double? start;
  double? end;
  double? startIntensity;
  double? endIntensity;

  Map<String, dynamic> toJson() => switch (kind) {
        _LoadKind.point => {
            'type': 'point',
            'position': position,
            'magnitude': magnitude,
          },
        _LoadKind.distributed => {
            'type': 'distributed',
            'start': start,
            'end': end,
            'startIntensity': startIntensity,
            'endIntensity': endIntensity,
          },
        _LoadKind.couple => {
            'type': 'couple',
            'position': position,
            'magnitude': magnitude,
          },
      };

  /// Tolerant by design: a row that cannot be read comes back blank rather
  /// than taking the whole saved set of loads down with it.
  static _LoadDraft fromJson(Map<String, dynamic> json) => _LoadDraft(
        kind: switch (json['type']) {
          'distributed' => _LoadKind.distributed,
          'couple' => _LoadKind.couple,
          _ => _LoadKind.point,
        },
        position: (json['position'] as num?)?.toDouble(),
        magnitude: (json['magnitude'] as num?)?.toDouble(),
        start: (json['start'] as num?)?.toDouble(),
        end: (json['end'] as num?)?.toDouble(),
        startIntensity: (json['startIntensity'] as num?)?.toDouble(),
        endIntensity: (json['endIntensity'] as num?)?.toDouble(),
      );

  /// The loads a pre-1.12 entry recorded: one point load and one full-span
  /// UDL, in their own keys. A zero in either meant "not used", so a zero row
  /// is dropped rather than carried across as a load of nothing.
  static List<_LoadDraft> legacy(Map<String, String> inputs, double span) {
    final loads = <_LoadDraft>[];
    final point = double.tryParse(inputs[_legacyPointLoadKey] ?? '');
    if (point != null && point != 0) {
      loads.add(_LoadDraft(
        kind: _LoadKind.point,
        magnitude: point,
        position: double.tryParse(inputs[_legacyPointPositionKey] ?? '') ?? 0,
      ));
    }
    final udl = double.tryParse(inputs[_legacyUdlKey] ?? '');
    if (udl != null && udl != 0) {
      loads.add(_LoadDraft(
        kind: _LoadKind.distributed,
        start: 0,
        end: span,
        startIntensity: udl,
        endIntensity: udl,
      ));
    }
    return loads;
  }

  /// The immutable load the solver takes, or null when a field is still blank.
  BeamLoad? toLoad() {
    switch (kind) {
      case _LoadKind.point:
        if (position == null || magnitude == null) return null;
        return BeamPointLoad(position: position!, magnitude: magnitude!);
      case _LoadKind.couple:
        if (position == null || magnitude == null) return null;
        return BeamAppliedMoment(position: position!, magnitude: magnitude!);
      case _LoadKind.distributed:
        if (start == null ||
            end == null ||
            startIntensity == null ||
            endIntensity == null) {
          return null;
        }
        return BeamDistributedLoad(
          start: start!,
          end: end!,
          startIntensity: startIntensity!,
          endIntensity: endIntensity!,
        );
    }
  }
}

String supportCaseLabel(BuildContext context, BeamSupportCase value) {
  final l10n = S.of(context);
  return switch (value) {
    BeamSupportCase.simplySupported => l10n.Support_Simply_Supported,
    BeamSupportCase.cantileverLeft => l10n.Support_Cantilever_Left,
    BeamSupportCase.cantileverRight => l10n.Support_Cantilever_Right,
    BeamSupportCase.overhang => l10n.Support_Overhang,
    BeamSupportCase.proppedCantilever => l10n.Support_Propped_Cantilever,
    BeamSupportCase.fixedFixed => l10n.Support_Fixed_Fixed,
  };
}

class BeamCalculatorPage extends StatefulWidget {
  const BeamCalculatorPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeamCalculatorPage> createState() => _BeamCalculatorPageState();
}

class _BeamCalculatorPageState extends State<BeamCalculatorPage> {
  double? _span = 4;
  double? _elasticModulus = 200;
  double? _secondMoment = 100000000;
  double? _extremeFibre;
  BeamSupportCase _supportCase = BeamSupportCase.simplySupported;
  double? _leftSupport;
  double? _rightSupport;
  late List<_LoadDraft> _loads;

  /// Bumped when a preset overwrites E or I, so those fields rebuild with the
  /// new value rather than keeping the text last typed into them.
  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs != null) _restore(inputs);
    _loads = _restoreLoads(inputs) ??
        [_LoadDraft(kind: _LoadKind.point, position: 2, magnitude: 10)];
    _leftSupport ??= (_span ?? 4) * 0.2;
    _rightSupport ??= (_span ?? 4) * 0.8;
  }

  void _restore(Map<String, String> inputs) {
    _span = double.tryParse(inputs[_spanKey] ?? '') ?? _span;
    _elasticModulus =
        double.tryParse(inputs[_modulusKey] ?? '') ?? _elasticModulus;
    _secondMoment =
        double.tryParse(inputs[_secondMomentKey] ?? '') ?? _secondMoment;
    _extremeFibre = double.tryParse(inputs[_extremeFibreKey] ?? '');
    _leftSupport = double.tryParse(inputs[_leftSupportKey] ?? '');
    _rightSupport = double.tryParse(inputs[_rightSupportKey] ?? '');
    final saved = inputs[beamSupportCaseKey];
    if (saved != null) {
      for (final value in BeamSupportCase.values) {
        if (value.name == saved) _supportCase = value;
      }
    }
  }

  List<_LoadDraft>? _restoreLoads(Map<String, String>? inputs) {
    if (inputs == null) return null;
    final raw = inputs[beamLoadsKey];
    if (raw == null) {
      final legacy = _LoadDraft.legacy(inputs, _span ?? 0);
      return legacy.isEmpty ? null : legacy;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) return null;
      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>) _LoadDraft.fromJson(entry),
      ];
    } catch (_) {
      return null;
    }
  }

  void _addLoad() => setState(() => _loads.add(_LoadDraft()));

  void _removeLoad(_LoadDraft load) => setState(() => _loads.remove(load));

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
              title: l10n.Beam_And_Supports,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Beam_Supports,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  // A dropdown rather than the segmented button the two- and
                  // three-way choices elsewhere use: six arrangements with
                  // names this long do not fit across a phone.
                  DropdownButtonFormField<BeamSupportCase>(
                    key: const Key('beamSupportCase'),
                    initialValue: _supportCase,
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.Support_Arrangement),
                    items: [
                      for (final value in BeamSupportCase.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(supportCaseLabel(context, value)),
                        ),
                    ],
                    onChanged: (value) => setState(
                        () => _supportCase = value ?? _supportCase),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Span_L,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _span,
                      onChangedSI: (v) => _span = v,
                    ),
                    // Only the overhang lets the supports move; everywhere
                    // else they are at the ends by definition, and offering
                    // the fields would imply otherwise.
                    if (_supportCase == BeamSupportCase.overhang) ...[
                      UnitField(
                        label: l10n.Left_Support_Position,
                        category: UnitCategory.span,
                        signed: false,
                        initialSI: _leftSupport,
                        onChangedSI: (v) => _leftSupport = v,
                      ),
                      UnitField(
                        label: l10n.Right_Support_Position,
                        category: UnitCategory.span,
                        signed: false,
                        initialSI: _rightSupport,
                        onChangedSI: (v) => _rightSupport = v,
                      ),
                    ],
                    UnitField(
                      key: ValueKey('E$_presetGeneration'),
                      label: l10n.Elastic_Modulus_E,
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _elasticModulus,
                      onChangedSI: (v) => _elasticModulus = v,
                    ),
                    UnitField(
                      key: ValueKey('I$_presetGeneration'),
                      label: l10n.Second_Moment_I,
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _secondMoment,
                      onChangedSI: (v) => _secondMoment = v,
                    ),
                    UnitField(
                      key: ValueKey('c$_presetGeneration'),
                      label: l10n.Extreme_Fibre_C,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _extremeFibre,
                      onChangedSI: (v) => _extremeFibre = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    l10n.Extreme_Fibre_Hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _elasticModulus = preset.elasticModulusSI;
                        _presetGeneration++;
                      }
                    }),
                  ),
                  StandardSectionButton(
                    // Takes the published Ix straight across rather than
                    // recomputing it from the shape's dimensions: the table
                    // value includes the root fillets. Half the depth is the
                    // extreme fibre of a symmetric rolled section, which is
                    // what turns the moment into a stress.
                    onSelected: (section) => setState(() {
                      _secondMoment = section.ix;
                      _extremeFibre = section.depth / 2;
                      _presetGeneration++;
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Beam_Loads,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _loads.length; i++)
                    _LoadRow(
                      // Keyed by row identity, not index: deleting the middle
                      // row must not hand its typed text to the one below.
                      key: ValueKey(_loads[i].id),
                      load: _loads[i],
                      ordinal: i + 1,
                      // The last load keeps its row rather than offering a
                      // delete that calculating would immediately refuse.
                      onRemove:
                          _loads.length > 1 ? () => _removeLoad(_loads[i]) : null,
                      onChanged: () => setState(() {}),
                    ),
                  SizedBox(height: context.tokens.space2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('addBeamLoad'),
                      onPressed: _addLoad,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.Add_Load),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Description_and_Formulas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Beam_Analysis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: context.tokens.space4),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'''\begin{aligned}
\mathbf{K}\mathbf{d}&=\mathbf{F}\\
\frac{dV}{dx}&=-w(x),\qquad \frac{dM}{dx}=V(x)\\
EI\frac{d^2v}{dx^2}&=M(x)\\
\sigma&=\frac{Mc}{I}
\end{aligned}''',
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
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
    final l10n = S.of(context);
    try {
      final loads = <BeamLoad>[];
      for (final draft in _loads) {
        final load = draft.toLoad();
        if (load == null) throw FormatException(l10n.Err_Beam_Load_Incomplete);
        loads.add(load);
      }

      final span = _span ?? 0;
      final input = BeamInput(
        span: span,
        supports: supportsFor(_supportCase, span,
            leftSupport: _leftSupport, rightSupport: _rightSupport),
        loads: loads,
        elasticModulus: _elasticModulus ?? 0,
        secondMoment: _secondMoment ?? 0,
        extremeFibreDistance: _extremeFibre,
      );
      final result = BeamSolver.solve(input);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        _spanKey: '${_span ?? ''}',
        beamSupportCaseKey: _supportCase.name,
        if (_supportCase == BeamSupportCase.overhang) ...{
          _leftSupportKey: '${_leftSupport ?? ''}',
          _rightSupportKey: '${_rightSupport ?? ''}',
        },
        _modulusKey: '${_elasticModulus ?? ''}',
        _secondMomentKey: '${_secondMoment ?? ''}',
        if (_extremeFibre != null) _extremeFibreKey: '$_extremeFibre',
        beamLoadsKey: jsonEncode([for (final load in _loads) load.toJson()]),
      });

      showToolResult(
        context,
        (context) => BeamCalculatorResultPage(
          toolId: widget.toolId,
          title: widget.title,
          input: input,
          result: result,
          supportCase: _supportCase,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _LoadRow extends StatelessWidget {
  const _LoadRow({
    super.key,
    required this.load,
    required this.ordinal,
    required this.onChanged,
    this.onRemove,
  });

  final _LoadDraft load;
  final int ordinal;
  final VoidCallback onChanged;

  /// Null while the beam is down to its last load.
  final VoidCallback? onRemove;

  String _kindLabel(BuildContext context, _LoadKind kind) {
    final l10n = S.of(context);
    return switch (kind) {
      _LoadKind.point => l10n.Load_Type_Point,
      _LoadKind.distributed => l10n.Load_Type_Distributed,
      _LoadKind.couple => l10n.Load_Type_Couple,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: context.tokens.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.Beam_Load_N('$ordinal'),
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: scheme.primary),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  tooltip: l10n.Remove_Load,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          SegmentedButton<_LoadKind>(
            segments: [
              for (final kind in _LoadKind.values)
                ButtonSegment(
                  value: kind,
                  label: Text(_kindLabel(context, kind)),
                ),
            ],
            selected: {load.kind},
            onSelectionChanged: (selected) {
              load.kind = selected.first;
              onChanged();
            },
          ),
          SizedBox(height: context.tokens.space3),
          AdaptiveFieldGrid(children: [
            if (load.kind == _LoadKind.distributed) ...[
              UnitField(
                label: l10n.Load_Starts_At,
                category: UnitCategory.span,
                signed: false,
                initialSI: load.start,
                onChangedSI: (v) => load.start = v,
              ),
              UnitField(
                label: l10n.Load_Ends_At,
                category: UnitCategory.span,
                signed: false,
                initialSI: load.end,
                onChangedSI: (v) => load.end = v,
              ),
              // Signed: an uplift, a wind suction or a counterweight is a
              // negative intensity, and the solver has no trouble with one.
              UnitField(
                label: l10n.Load_Intensity_Start,
                category: UnitCategory.distributedLoadStructural,
                initialSI: load.startIntensity,
                onChangedSI: (v) => load.startIntensity = v,
              ),
              UnitField(
                label: l10n.Load_Intensity_End,
                category: UnitCategory.distributedLoadStructural,
                initialSI: load.endIntensity,
                onChangedSI: (v) => load.endIntensity = v,
              ),
            ] else ...[
              UnitField(
                label: l10n.Load_Position_X,
                category: UnitCategory.span,
                signed: false,
                initialSI: load.position,
                onChangedSI: (v) => load.position = v,
              ),
              UnitField(
                label: load.kind == _LoadKind.point
                    ? l10n.Load_Magnitude_P
                    : l10n.Load_Couple_M,
                category: load.kind == _LoadKind.point
                    ? UnitCategory.forceStructural
                    : UnitCategory.momentStructural,
                initialSI: load.magnitude,
                onChangedSI: (v) => load.magnitude = v,
              ),
            ],
          ]),
        ],
      ),
    );
  }
}
