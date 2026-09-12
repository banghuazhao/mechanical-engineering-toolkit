import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/model/tolerance_stackup_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/page/tolerance_stackup_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The key the chain is stored under in history and saved projects.
///
/// One key holding a JSON array rather than a key per dimension: the chain has
/// no fixed length, so there is no stable set of input labels to key by, and a
/// project saved with five dimensions must not half-restore into a tool that
/// expected three.
const stackupChainKey = 'chain';

/// The stored chain as one readable line, e.g. `bore 25 +0.1/−0.05, −12 ±0.02`.
///
/// History and saved projects summarise a calculation as its `label: value`
/// inputs, which reads well for the tools that record one number per field.
/// This tool has no fixed number of fields, so it records the whole chain as
/// JSON under [stackupChainKey] — and printed raw that is a wall of braces.
/// This is the same chain written the way a drawing writes it instead.
///
/// A dimension that subtracts is prefixed with a minus, matching the direction
/// the user chose. Returns null for a value that is not a chain this build can
/// read, so a caller can fall back rather than show nothing.
String? describeStackupChain(String raw) {
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
    final nominal = (entry['nominal'] as num?)?.toDouble();
    // A row with no size describes nothing; skip it rather than print a gap.
    if (nominal == null) continue;
    final plus = (entry['plus'] as num?)?.toDouble() ?? 0;
    final minus = (entry['minus'] as num?)?.toDouble() ?? 0;
    final label = '${entry['label'] ?? ''}'.trim();

    final buffer = StringBuffer();
    if (label.isNotEmpty) buffer.write('$label ');
    if (entry['subtracts'] == true) buffer.write('−');
    buffer.write(_trimmed(nominal));
    buffer.write(plus == minus
        ? ' ±${_trimmed(plus)}'
        : ' +${_trimmed(plus)}/−${_trimmed(minus)}');
    parts.add(buffer.toString());
  }
  return parts.isEmpty ? null : parts.join(', ');
}

/// A stored millimetre value without the trailing zeros a fixed number of
/// decimals would leave — `25`, not `25.000`.
String _trimmed(double value) {
  final text = value.toStringAsFixed(3);
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// A dimension being edited. Mutable and identified, unlike the immutable
/// [StackupContributor] the calculator takes: rows are reordered and deleted,
/// and a [UnitField]'s state has to follow its row rather than its position.
class _DimensionDraft {
  _DimensionDraft({
    this.nominal,
    this.plusTolerance,
    this.minusTolerance,
    this.direction = StackupDirection.adds,
    String label = '',
  }) : labelController = TextEditingController(text: label);

  static int _nextId = 0;
  final int id = _nextId++;

  final TextEditingController labelController;
  double? nominal;
  double? plusTolerance;
  double? minusTolerance;
  StackupDirection direction;

  void dispose() => labelController.dispose();

  Map<String, dynamic> toJson() => {
        'label': labelController.text,
        'nominal': nominal,
        'plus': plusTolerance,
        'minus': minusTolerance,
        'subtracts': direction == StackupDirection.subtracts,
      };

  /// Tolerant by design: a row that cannot be read comes back blank rather
  /// than taking the whole saved chain down with it.
  static _DimensionDraft fromJson(Map<String, dynamic> json) => _DimensionDraft(
        label: json['label'] as String? ?? '',
        nominal: (json['nominal'] as num?)?.toDouble(),
        plusTolerance: (json['plus'] as num?)?.toDouble(),
        minusTolerance: (json['minus'] as num?)?.toDouble(),
        direction: json['subtracts'] == true
            ? StackupDirection.subtracts
            : StackupDirection.adds,
      );
}

class ToleranceStackupPage extends StatefulWidget {
  const ToleranceStackupPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ToleranceStackupPage> createState() => _ToleranceStackupPageState();
}

class _ToleranceStackupPageState extends State<ToleranceStackupPage> {
  late List<_DimensionDraft> _rows;

  @override
  void initState() {
    super.initState();
    _rows = _restore(widget.initialInputs) ??
        // A stack-up of one dimension is not a stack-up; two is the smallest
        // chain that says anything, so that is what an empty tool opens with.
        [_DimensionDraft(), _DimensionDraft()];
  }

  static List<_DimensionDraft>? _restore(Map<String, String>? inputs) {
    final raw = inputs?[stackupChainKey];
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List || decoded.isEmpty) return null;
      return [
        for (final entry in decoded)
          if (entry is Map<String, dynamic>) _DimensionDraft.fromJson(entry),
      ];
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addRow() => setState(() => _rows.add(_DimensionDraft()));

  void _removeRow(_DimensionDraft row) {
    setState(() => _rows.remove(row));
    // Disposed after the frame that removed it, so the field being torn down
    // is not reading a dead controller while it animates out.
    WidgetsBinding.instance.addPostFrameCallback((_) => row.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
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
              title: l10n.Stackup_Dimensions,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Tolerance_Stackup,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  for (var i = 0; i < _rows.length; i++)
                    _DimensionRow(
                      // Keyed by row identity, not index: deleting the middle
                      // row must not hand its typed text to the one below.
                      key: ValueKey(_rows[i].id),
                      row: _rows[i],
                      ordinal: i + 1,
                      // Two is the working minimum, so the last pair keeps its
                      // rows rather than offering a delete that would be
                      // refused at calculate time.
                      onRemove: _rows.length > 2
                          ? () => _removeRow(_rows[i])
                          : null,
                      onChanged: () => setState(() {}),
                    ),
                  SizedBox(height: context.tokens.space2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('addStackupDimension'),
                      onPressed: _addRow,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(l10n.Add_Dimension),
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
      if (_rows.length < 2) throw FormatException(l10n.Err_Stackup_Two_Rows);

      final contributors = <StackupContributor>[];
      for (final row in _rows) {
        final nominal = row.nominal;
        final plus = row.plusTolerance;
        final minus = row.minusTolerance;
        if (nominal == null || plus == null || minus == null) {
          throw FormatException(l10n.Err_Stackup_Dimension);
        }
        contributors.add(StackupContributor(
          label: row.labelController.text.trim(),
          nominal: nominal,
          plusTolerance: plus,
          minusTolerance: minus,
          direction: row.direction,
        ));
      }

      final result = ToleranceStackupCalculator.calculate(contributors);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        stackupChainKey:
            jsonEncode([for (final row in _rows) row.toJson()]),
      });

      showToolResult(
        context,
        (context) => ToleranceStackupResultPage(
          result: result,
          contributors: contributors,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({
    super.key,
    required this.row,
    required this.ordinal,
    required this.onChanged,
    this.onRemove,
  });

  final _DimensionDraft row;
  final int ordinal;
  final VoidCallback onChanged;

  /// Null while the chain is at its two-row minimum.
  final VoidCallback? onRemove;

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
                  l10n.Stackup_Dimension_N('$ordinal'),
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
                  tooltip: l10n.Remove_Dimension,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          TextField(
            controller: row.labelController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.Name,
              isDense: true,
            ),
          ),
          SizedBox(height: context.tokens.space3),
          SegmentedButton<StackupDirection>(
            segments: [
              for (final direction in StackupDirection.values)
                ButtonSegment(
                  value: direction,
                  label: Text(direction.label(context)),
                ),
            ],
            selected: {row.direction},
            onSelectionChanged: (selected) {
              row.direction = selected.first;
              onChanged();
            },
          ),
          SizedBox(height: context.tokens.space3),
          AdaptiveFieldGrid(children: [
            UnitField(
              label: l10n.Nominal_Size,
              category: UnitCategory.length,
              signed: false,
              initialSI: row.nominal,
              onChangedSI: (v) => row.nominal = v,
            ),
            UnitField(
              label: l10n.Plus_Tolerance,
              category: UnitCategory.length,
              // Magnitudes: the sign is carried by which field it is in, so a
              // typed minus here would double-negate the lower limit.
              signed: false,
              initialSI: row.plusTolerance,
              onChangedSI: (v) => row.plusTolerance = v,
            ),
            UnitField(
              label: l10n.Minus_Tolerance,
              category: UnitCategory.length,
              signed: false,
              initialSI: row.minusTolerance,
              onChangedSI: (v) => row.minusTolerance = v,
            ),
          ]),
        ],
      ),
    );
  }
}
