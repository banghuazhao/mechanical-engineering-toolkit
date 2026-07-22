import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../util/material_library.dart';
import '../util/unit_field.dart';
import '../util/unit_system.dart';
import '../util/units.dart';
import 'app_components.dart';

/// A small button that opens a bottom sheet of built-in + custom isotropic
/// material presets (E, G, yield, ultimate strength, density, ν). Selecting
/// one invokes [onSelected] — callers copy over whichever fields they use
/// and call setState.
///
/// Not for composite lamina properties (E1/E2/G12/ν12) — those are a
/// different data shape and aren't covered by this picker.
class MaterialPresetButton extends StatelessWidget {
  const MaterialPresetButton({super.key, required this.onSelected});

  final ValueChanged<MaterialPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _openPicker(context),
        icon: const Icon(Icons.science_outlined, size: 18),
        label: const Text('Pick material'),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final preset = await showModalBottomSheet<MaterialPreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _MaterialPickerSheet(),
    );
    if (preset != null) onSelected(preset);
  }
}

class _MaterialPickerSheet extends StatefulWidget {
  const _MaterialPickerSheet();

  @override
  State<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends State<_MaterialPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final library = context.watch<MaterialLibrary>();
    final system = context.watch<UnitSystemPreference>().system;
    final all = library.all
        .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('Material presets',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: 'Add custom material',
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => _openAddCustomSheet(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search materials',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: all.isEmpty
                ? const Center(child: Text('No materials found'))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: all.length,
                    itemBuilder: (context, i) {
                      final m = all[i];
                      return ListTile(
                        title: Text(m.name),
                        subtitle: Text(_subtitle(m, system)),
                        trailing: m.isCustom
                            ? IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => context
                                    .read<MaterialLibrary>()
                                    .removeCustom(m.name),
                              )
                            : null,
                        onTap: () => Navigator.pop(context, m),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _subtitle(MaterialPreset m, UnitSystem system) {
    final parts = <String>[];
    if (m.elasticModulusSI != null) {
      parts.add(
          'E=${_f(fromSI(m.elasticModulusSI!, UnitCategory.modulus, system))}${unitLabel(UnitCategory.modulus, system)}');
    }
    if (m.yieldStrengthSI != null) {
      parts.add(
          'σy=${_f(fromSI(m.yieldStrengthSI!, UnitCategory.stress, system))}${unitLabel(UnitCategory.stress, system)}');
    }
    if (m.densitySI != null) {
      parts.add(
          'ρ=${_f(fromSI(m.densitySI!, UnitCategory.density, system))}${unitLabel(UnitCategory.density, system)}');
    }
    return parts.join(' · ');
  }

  String _f(double v) => v >= 100 ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  Future<void> _openAddCustomSheet(BuildContext context) async {
    final library = context.read<MaterialLibrary>();
    final result = await showModalBottomSheet<MaterialPreset>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddCustomMaterialSheet(),
    );
    if (result != null) library.addCustom(result);
  }
}

class _AddCustomMaterialSheet extends StatefulWidget {
  const _AddCustomMaterialSheet();

  @override
  State<_AddCustomMaterialSheet> createState() =>
      _AddCustomMaterialSheetState();
}

class _AddCustomMaterialSheetState extends State<_AddCustomMaterialSheet> {
  final _nameController = TextEditingController();
  double? _e, _g, _yield, _ultimate, _density;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add custom material',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            AdaptiveFieldGrid(children: [
              UnitField(
                label: 'E (modulus)',
                category: UnitCategory.modulus,
                signed: false,
                initialSI: _e,
                onChangedSI: (v) => _e = v,
              ),
              UnitField(
                label: 'G (shear modulus)',
                category: UnitCategory.modulus,
                signed: false,
                initialSI: _g,
                onChangedSI: (v) => _g = v,
              ),
              UnitField(
                label: 'Yield strength',
                category: UnitCategory.stress,
                signed: false,
                initialSI: _yield,
                onChangedSI: (v) => _yield = v,
              ),
              UnitField(
                label: 'Ultimate strength',
                category: UnitCategory.stress,
                signed: false,
                initialSI: _ultimate,
                onChangedSI: (v) => _ultimate = v,
              ),
              UnitField(
                label: 'Density',
                category: UnitCategory.density,
                signed: false,
                initialSI: _density,
                onChangedSI: (v) => _density = v,
              ),
            ]),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(
                  context,
                  MaterialPreset(
                    name: name,
                    category: MaterialCategory.other,
                    elasticModulusSI: _e,
                    shearModulusSI: _g,
                    yieldStrengthSI: _yield,
                    ultimateStrengthSI: _ultimate,
                    densitySI: _density,
                    isCustom: true,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
