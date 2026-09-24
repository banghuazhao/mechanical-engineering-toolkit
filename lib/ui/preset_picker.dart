import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_library.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';

/// A button that opens a searchable sheet of read-only presets and hands the
/// chosen one back — standard sections, pipe sizes, ideal gases: published
/// tables a user has no reason to extend.
///
/// The four material libraries, which a user can add to, go through
/// [PresetLibraryButton] in `preset_library.dart` instead. Folding an
/// editable library and a fixed table into one widget would cost more in
/// configuration flags than the list tile it saves.
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
  Widget build(BuildContext context) => PresetLibraryButton<FluidPreset>(
        library: fluidPresetLibrary,
        onSelected: onSelected,
      );
}

/// Picks a thermal conductivity by material name.
class ThermalMaterialButton extends StatelessWidget {
  const ThermalMaterialButton({super.key, required this.onSelected});

  final ValueChanged<ThermalMaterialPreset> onSelected;

  @override
  Widget build(BuildContext context) =>
      PresetLibraryButton<ThermalMaterialPreset>(
        library: thermalPresetLibrary,
        onSelected: onSelected,
      );
}

/// Picks a unidirectional lamina, handing back its elastic constants and
/// strengths together so the composite tools fill a matched set.
class LaminaPresetButton extends StatelessWidget {
  const LaminaPresetButton({super.key, required this.onSelected});

  final ValueChanged<LaminaPreset> onSelected;

  @override
  Widget build(BuildContext context) => PresetLibraryButton<LaminaPreset>(
        library: laminaPresetLibrary,
        onSelected: onSelected,
      );
}
