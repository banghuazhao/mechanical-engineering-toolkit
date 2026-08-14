import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// A button that opens a searchable sheet of read-only presets and hands the
/// chosen one back.
///
/// Deliberately not shared with `MaterialPresetButton` in
/// `material_preset_picker.dart`: that one also adds, persists and deletes
/// user-defined entries, and folding an editable library and a fixed one into
/// a single widget would cost more in configuration flags than the list tile
/// it saves.
class PresetPickerButton<T> extends StatelessWidget {
  const PresetPickerButton({
    super.key,
    required this.buttonLabel,
    required this.sheetTitle,
    required this.searchHint,
    required this.emptyLabel,
    required this.presets,
    required this.nameOf,
    required this.subtitleOf,
    required this.onSelected,
    this.icon = Icons.science_outlined,
  });

  final String buttonLabel;
  final String sheetTitle;
  final String searchHint;

  /// Shown when the query matches nothing.
  final String emptyLabel;

  final List<T> presets;
  final String Function(T preset) nameOf;

  /// The properties line under each name. Takes a context so it can format
  /// values in the reader's unit system.
  final String Function(BuildContext context, T preset) subtitleOf;

  final ValueChanged<T> onSelected;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: Icon(icon, size: 18),
        label: Text(buttonLabel),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final chosen = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _PresetSheet<T>(
        title: sheetTitle,
        searchHint: searchHint,
        emptyLabel: emptyLabel,
        presets: presets,
        nameOf: nameOf,
        subtitleOf: subtitleOf,
      ),
    );
    if (chosen != null) onSelected(chosen);
  }
}

class _PresetSheet<T> extends StatefulWidget {
  const _PresetSheet({
    required this.title,
    required this.searchHint,
    required this.emptyLabel,
    required this.presets,
    required this.nameOf,
    required this.subtitleOf,
  });

  final String title;
  final String searchHint;
  final String emptyLabel;
  final List<T> presets;
  final String Function(T preset) nameOf;
  final String Function(BuildContext context, T preset) subtitleOf;

  @override
  State<_PresetSheet<T>> createState() => _PresetSheetState<T>();
}

class _PresetSheetState<T> extends State<_PresetSheet<T>> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final matches = [
      for (final preset in widget.presets)
        if (query.isEmpty ||
            widget.nameOf(preset).toLowerCase().contains(query))
          preset,
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              widget.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: matches.isEmpty
                ? Center(child: Text(widget.emptyLabel))
                : ListView.builder(
                    controller: scrollController,
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      final preset = matches[index];
                      return ListTile(
                        title: Text(widget.nameOf(preset)),
                        subtitle: Text(widget.subtitleOf(context, preset)),
                        onTap: () => Navigator.pop(context, preset),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Picks a working fluid, filling density and dynamic viscosity together —
/// the two always belong to the same fluid at the same temperature, so
/// offering them as a pair stops a stale μ being left beside a new ρ.
class FluidPresetButton extends StatelessWidget {
  const FluidPresetButton({super.key, required this.onSelected});

  final ValueChanged<FluidPreset> onSelected;

  @override
  Widget build(BuildContext context) {
    return PresetPickerButton<FluidPreset>(
      buttonLabel: S.of(context).Pick_Fluid,
      sheetTitle: S.of(context).Fluid_Presets,
      searchHint: S.of(context).Search_Fluids,
      emptyLabel: S.of(context).No_Fluids_Found,
      icon: Icons.water_drop_outlined,
      presets: builtInFluids,
      nameOf: (fluid) => fluid.name,
      subtitleOf: (context, fluid) {
        final system = context.read<UnitSystemPreference>().system;
        final precs = context.read<NumberPrecisionHelper>();
        final density = precs.formatSI(
            fluid.densitySI, UnitCategory.density, system);
        // Small-value form, or every water preset reads as a flat "0.001".
        final viscosity = precs.formatSmallSI(
            fluid.viscositySI, UnitCategory.dynamicViscosity, system);
        return 'ρ = $density · μ = $viscosity';
      },
      onSelected: onSelected,
    );
  }
}

/// Picks a thermal conductivity by material name, grouped metals first.
class ThermalMaterialButton extends StatelessWidget {
  const ThermalMaterialButton({super.key, required this.onSelected});

  final ValueChanged<ThermalMaterialPreset> onSelected;

  String _groupLabel(BuildContext context, ThermalMaterialGroup group) =>
      switch (group) {
        ThermalMaterialGroup.metal => S.of(context).Group_Metal,
        ThermalMaterialGroup.building => S.of(context).Group_Building,
        ThermalMaterialGroup.insulation => S.of(context).Group_Insulation,
      };

  @override
  Widget build(BuildContext context) {
    return PresetPickerButton<ThermalMaterialPreset>(
      buttonLabel: S.of(context).Pick_Thermal_Material,
      sheetTitle: S.of(context).Thermal_Material_Presets,
      searchHint: S.of(context).Search_Materials,
      emptyLabel: S.of(context).No_Materials_Found,
      icon: Icons.thermostat_rounded,
      presets: builtInThermalMaterials,
      nameOf: (material) => material.name,
      subtitleOf: (context, material) {
        final system = context.read<UnitSystemPreference>().system;
        final precs = context.read<NumberPrecisionHelper>();
        final k = precs.formatSI(
            material.conductivitySI, UnitCategory.thermalConductivity, system);
        return '${_groupLabel(context, material.group)} · k = $k';
      },
      onSelected: onSelected,
    );
  }
}
