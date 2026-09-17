import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:flutter/services.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/converter_catalog.dart';

/// The chip glyph for each catalogue category.
///
/// Kept here rather than in the catalogue so that
/// [converter_catalog.dart] stays free of any Flutter import — the Swift
/// generator behind the Shortcuts action imports it from a plain Dart script,
/// which cannot resolve `package:flutter`.
const _categoryIcons = <String, IconData>{
  'length': Icons.straighten_rounded,
  'force': Icons.arrow_downward_rounded,
  'pressure': Icons.compress_rounded,
  'mass': Icons.scale_rounded,
  'temperature': Icons.thermostat_rounded,
  'torque': Icons.rotate_right_rounded,
  'power': Icons.bolt_rounded,
  'angularVelocity': Icons.settings_rounded,
  'angle': Icons.architecture_rounded,
};

class UnitConverterPage extends StatefulWidget {
  final String? title;
  final int? toolId;
  final Map<String, String>? initialInputs;
  const UnitConverterPage(
      {Key? key, this.title, this.toolId, this.initialInputs})
      : super(key: key);

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  int _catIndex = 0;
  int _fromIndex = 0;
  int _toIndex = 1;

  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();
  bool _updating = false;

  ConverterCategory get _cat => converterCategories[_catIndex];

  void _selectCategory(int i) {
    setState(() {
      _catIndex = i;
      _fromIndex = 0;
      _toIndex = _cat.units.length > 1 ? 1 : 0;
      _fromCtrl.clear();
      _toCtrl.clear();
    });
  }

  void _convert({required bool fromChanged}) {
    if (_updating) return;
    _updating = true;
    final units = _cat.units;
    if (fromChanged) {
      final v = double.tryParse(_fromCtrl.text);
      if (v != null) {
        final base = units[_fromIndex].toBase(v);
        final result = units[_toIndex].fromBase(base);
        _toCtrl.text = formatConverterValue(result);
      } else {
        _toCtrl.clear();
      }
    } else {
      final v = double.tryParse(_toCtrl.text);
      if (v != null) {
        final base = units[_toIndex].toBase(v);
        final result = units[_fromIndex].fromBase(base);
        _fromCtrl.text = formatConverterValue(result);
      } else {
        _fromCtrl.clear();
      }
    }
    _updating = false;
    // Rebuild so Copy result enables/disables with the current result text.
    setState(() {});
  }

  @override
  void dispose() {
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final units = _cat.units;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Unit_Converter),
        actions: [
          if (widget.toolId != null)
            ToolHelpButton(
              toolId: widget.toolId!,
              toolTitle: S.of(context).Unit_Converter,
            ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: converterCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == _catIndex;
                return ChoiceChip(
                  label: Text(converterCategories[i].name),
                  avatar: Icon(_categoryIcons[converterCategories[i].id], size: 16),
                  selected: selected,
                  selectedColor: primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontSize: 13,
                  ),
                  onSelected: (_) => _selectCategory(i),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _UnitField(
                    label: S.of(context).From,
                    controller: _fromCtrl,
                    unitLabels: units.map((u) => u.label).toList(),
                    selectedUnit: _fromIndex,
                    onUnitChanged: (i) {
                      setState(() => _fromIndex = i);
                      _convert(fromChanged: true);
                    },
                    onChanged: (_) => _convert(fromChanged: true),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: IconButton(
                      icon: Icon(Icons.swap_vert_rounded,
                          color: primary, size: 32),
                      tooltip: S.of(context).Swap,
                      onPressed: () {
                        setState(() {
                          final tmp = _fromIndex;
                          _fromIndex = _toIndex;
                          _toIndex = tmp;
                          final tmpText = _fromCtrl.text;
                          _fromCtrl.text = _toCtrl.text;
                          _toCtrl.text = tmpText;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _UnitField(
                    label: 'To',
                    controller: _toCtrl,
                    unitLabels: units.map((u) => u.label).toList(),
                    selectedUnit: _toIndex,
                    onUnitChanged: (i) {
                      setState(() => _toIndex = i);
                      _convert(fromChanged: false);
                    },
                    onChanged: (_) => _convert(fromChanged: false),
                  ),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(S.of(context).Copy_Result),
                    onPressed: _toCtrl.text.isNotEmpty
                        ? () {
                            Clipboard.setData(ClipboardData(
                                text:
                                    '${_toCtrl.text} ${units[_toIndex].label}'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(S.of(context).Result_Copied),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final List<String> unitLabels;
  final int selectedUnit;
  final ValueChanged<int> onUnitChanged;
  final ValueChanged<String> onChanged;

  const _UnitField({
    required this.label,
    required this.controller,
    required this.unitLabels,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: const InputDecoration(hintText: '0'),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<int>(
              value: selectedUnit,
              underline: const SizedBox.shrink(),
              items: unitLabels
                  .asMap()
                  .entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) onUnitChanged(v);
              },
            ),
          ],
        ),
      ],
    );
  }
}
