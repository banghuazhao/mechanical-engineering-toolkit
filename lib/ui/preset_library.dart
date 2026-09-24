import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/custom_preset_editors.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Opens the editor for one library's entry. [initial] pre-fills it — the
/// entry being edited, or a built-in being duplicated — and [isNameTaken]
/// answers whether a name would collide with another entry.
typedef PresetEditor<T> = Future<T?> Function(
  BuildContext context, {
  T? initial,
  required bool Function(String name) isNameTaken,
});

/// Everything the picker sheet and the My Materials page need to know about
/// one preset library: its wording, its built-ins, where its custom entries
/// live, how to describe an entry, and how to edit one.
///
/// The four libraries hold different shapes of data — an isotropic solid, a
/// lamina, a fluid, a conductivity — but are browsed, searched, extended and
/// pruned identically, so each is described once here and every screen that
/// lists presets reads from the description.
class PresetLibrary<T> {
  const PresetLibrary({
    required this.title,
    required this.buttonLabel,
    required this.addLabel,
    required this.searchHint,
    required this.emptyLabel,
    required this.icon,
    required this.builtIn,
    required this.custom,
    required this.nameOf,
    required this.subtitleOf,
    required this.editor,
    required this.duplicate,
  });

  /// Heads the picker sheet and names the tab on My Materials.
  final String title;
  final String buttonLabel;
  final String addLabel;
  final String searchHint;
  final String emptyLabel;
  final IconData icon;

  final List<T> builtIn;
  final CustomPresetList<T> Function(MaterialLibrary library) custom;
  final String Function(T preset) nameOf;

  /// The properties line under each name, in the reader's unit system.
  final String Function(BuildContext context, T preset) subtitleOf;

  final PresetEditor<T> editor;

  /// A custom copy of [preset] under a new name — the starting point when a
  /// user duplicates a built-in to adjust one value.
  final T Function(T preset, String name) duplicate;

  bool isNameTaken(MaterialLibrary library, String name, {int? exceptIndex}) =>
      MaterialLibrary.isNameTaken(
        name,
        builtIn: builtIn,
        custom: custom(library),
        exceptIndex: exceptIndex,
      );

  /// A name for a copy of [preset] that nothing in the library uses yet:
  /// "Name (copy)", then "Name (copy 2)" and so on.
  String copyName(BuildContext context, MaterialLibrary library, T preset) {
    final base = nameOf(preset);
    var candidate = S.of(context).Preset_Copy_Name(base);
    for (var n = 2; isNameTaken(library, candidate); n++) {
      candidate = S.of(context).Preset_Copy_Name_N(base, n);
    }
    return candidate;
  }

  /// Adds an entry through the editor.
  Future<T?> addNew(BuildContext context) async {
    final library = context.read<MaterialLibrary>();
    final created = await editor(
      context,
      isNameTaken: (name) => isNameTaken(library, name),
    );
    if (created != null) custom(library).add(created);
    return created;
  }

  /// Edits custom entry [index] in place.
  Future<void> edit(BuildContext context, int index) async {
    final library = context.read<MaterialLibrary>();
    final list = custom(library);
    final items = list.items;
    if (index < 0 || index >= items.length) return;
    final edited = await editor(
      context,
      initial: items[index],
      isNameTaken: (name) => isNameTaken(library, name, exceptIndex: index),
    );
    if (edited != null) list.replaceAt(index, edited);
  }

  /// Opens the editor on a copy of [preset], built-in or custom, and adds
  /// the result as a new custom entry.
  Future<T?> duplicateInto(BuildContext context, T preset) async {
    final library = context.read<MaterialLibrary>();
    final copy = duplicate(preset, copyName(context, library, preset));
    final created = await editor(
      context,
      initial: copy,
      isNameTaken: (name) => isNameTaken(library, name),
    );
    if (created != null) custom(library).add(created);
    return created;
  }

  /// Deletes custom entry [index] after asking.
  Future<void> confirmDelete(BuildContext context, int index) async {
    final library = context.read<MaterialLibrary>();
    final list = custom(library);
    final items = list.items;
    if (index < 0 || index >= items.length) return;
    final l10n = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.Delete_Preset_Question(nameOf(items[index]))),
        content: Text(l10n.Delete_Preset_Description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.Cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.Delete),
          ),
        ],
      ),
    );
    if (confirmed == true) list.removeAt(index);
  }
}

String _modulus(BuildContext context, double value) =>
    context.read<NumberPrecisionHelper>().formatSI(value, UnitCategory.modulus,
        context.read<UnitSystemPreference>().system);

String _stress(BuildContext context, double value) =>
    context.read<NumberPrecisionHelper>().formatSI(value, UnitCategory.stress,
        context.read<UnitSystemPreference>().system);

/// Isotropic solids: E, G, ν, strengths and density.
PresetLibrary<MaterialPreset> isotropicPresetLibrary(BuildContext context) {
  final l10n = S.of(context);
  return PresetLibrary<MaterialPreset>(
    title: l10n.Material_Presets,
    buttonLabel: l10n.Pick_Material,
    addLabel: l10n.Add_Custom_Material,
    searchHint: l10n.Search_Materials,
    emptyLabel: l10n.No_Materials_Found,
    icon: Icons.science_outlined,
    builtIn: builtInMaterials,
    custom: (library) => library.isotropic,
    nameOf: (m) => m.name,
    subtitleOf: (context, m) {
      final system = context.read<UnitSystemPreference>().system;
      final precs = context.read<NumberPrecisionHelper>();
      return [
        if (m.elasticModulusSI != null)
          'E = ${_modulus(context, m.elasticModulusSI!)}',
        if (m.poissonsRatio != null)
          'ν = ${precs.formatValue(m.poissonsRatio!)}',
        if (m.yieldStrengthSI != null)
          'σy = ${_stress(context, m.yieldStrengthSI!)}',
        if (m.densitySI != null)
          'ρ = ${precs.formatSI(m.densitySI!, UnitCategory.density, system)}',
      ].join(' · ');
    },
    editor: showIsotropicMaterialEditor,
    duplicate: (m, name) => m.copyWith(name: name),
  );
}

/// Unidirectional laminae: E1, E2, G12, ν12 and, optionally, strengths.
PresetLibrary<LaminaPreset> laminaPresetLibrary(BuildContext context) {
  final l10n = S.of(context);
  return PresetLibrary<LaminaPreset>(
    title: l10n.Lamina_Presets,
    buttonLabel: l10n.Pick_Lamina,
    addLabel: l10n.Add_Custom_Lamina,
    searchHint: l10n.Search_Materials,
    emptyLabel: l10n.No_Materials_Found,
    icon: Icons.layers_outlined,
    builtIn: builtInLaminae,
    custom: (library) => library.laminae,
    nameOf: (l) => l.name,
    subtitleOf: (context, l) {
      final precs = context.read<NumberPrecisionHelper>();
      return 'E1 = ${_modulus(context, l.e1)} · E2 = ${_modulus(context, l.e2)}'
          ' · G12 = ${_modulus(context, l.g12)}'
          ' · ν12 = ${precs.formatValue(l.nu12)}';
    },
    editor: showLaminaEditor,
    duplicate: (l, name) => l.copyWith(name: name),
  );
}

/// Working fluids: density and dynamic viscosity at one temperature.
PresetLibrary<FluidPreset> fluidPresetLibrary(BuildContext context) {
  final l10n = S.of(context);
  return PresetLibrary<FluidPreset>(
    title: l10n.Fluid_Presets,
    buttonLabel: l10n.Pick_Fluid,
    addLabel: l10n.Add_Custom_Fluid,
    searchHint: l10n.Search_Fluids,
    emptyLabel: l10n.No_Fluids_Found,
    icon: Icons.water_drop_outlined,
    builtIn: builtInFluids,
    custom: (library) => library.fluids,
    nameOf: (f) => f.name,
    subtitleOf: (context, fluid) {
      final system = context.read<UnitSystemPreference>().system;
      final precs = context.read<NumberPrecisionHelper>();
      final density =
          precs.formatSI(fluid.densitySI, UnitCategory.density, system);
      // Small-value form, or every water preset reads as a flat "0.001".
      final viscosity = precs.formatSmallSI(
          fluid.viscositySI, UnitCategory.dynamicViscosity, system);
      return 'ρ = $density · μ = $viscosity';
    },
    editor: showFluidEditor,
    duplicate: (f, name) => f.copyWith(name: name),
  );
}

String thermalGroupLabel(BuildContext context, ThermalMaterialGroup group) =>
    switch (group) {
      ThermalMaterialGroup.metal => S.of(context).Group_Metal,
      ThermalMaterialGroup.building => S.of(context).Group_Building,
      ThermalMaterialGroup.insulation => S.of(context).Group_Insulation,
    };

/// Thermal conductivities for the conduction and fin tools.
PresetLibrary<ThermalMaterialPreset> thermalPresetLibrary(
    BuildContext context) {
  final l10n = S.of(context);
  return PresetLibrary<ThermalMaterialPreset>(
    title: l10n.Thermal_Material_Presets,
    buttonLabel: l10n.Pick_Thermal_Material,
    addLabel: l10n.Add_Custom_Thermal_Material,
    searchHint: l10n.Search_Materials,
    emptyLabel: l10n.No_Materials_Found,
    icon: Icons.thermostat_rounded,
    builtIn: builtInThermalMaterials,
    custom: (library) => library.thermal,
    nameOf: (t) => t.name,
    subtitleOf: (context, material) {
      final system = context.read<UnitSystemPreference>().system;
      final precs = context.read<NumberPrecisionHelper>();
      final k = precs.formatSI(
          material.conductivitySI, UnitCategory.thermalConductivity, system);
      return '${thermalGroupLabel(context, material.group)} · k = $k';
    },
    editor: showThermalMaterialEditor,
    duplicate: (t, name) => t.copyWith(name: name),
  );
}

/// A button that opens [library]'s picker and hands the chosen preset back.
class PresetLibraryButton<T> extends StatelessWidget {
  const PresetLibraryButton({
    super.key,
    required this.library,
    required this.onSelected,
  });

  final PresetLibrary<T> Function(BuildContext context) library;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final description = library(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _open(context),
        icon: Icon(description.icon, size: 18),
        label: Text(description.buttonLabel),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final chosen = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _PresetLibrarySheet<T>(library: library),
    );
    if (chosen != null) onSelected(chosen);
  }
}

/// The searchable picker: the user's own entries first, then the built-ins.
///
/// Adding, editing, duplicating and deleting all happen here as well as on
/// My Materials, because the moment someone discovers the preset they need
/// is missing is the moment they are looking at this list.
class _PresetLibrarySheet<T> extends StatefulWidget {
  const _PresetLibrarySheet({required this.library});

  final PresetLibrary<T> Function(BuildContext context) library;

  @override
  State<_PresetLibrarySheet<T>> createState() => _PresetLibrarySheetState<T>();
}

class _PresetLibrarySheetState<T> extends State<_PresetLibrarySheet<T>> {
  String _query = '';

  bool _matches(String name) =>
      _query.trim().isEmpty ||
      name.toLowerCase().contains(_query.trim().toLowerCase());

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final description = widget.library(context);
    // Watched so an add, edit or delete made from this sheet redraws it.
    final store = context.watch<MaterialLibrary>();
    final customItems = description.custom(store).items;
    final customRows = [
      for (var i = 0; i < customItems.length; i++)
        if (_matches(description.nameOf(customItems[i]))) i,
    ];
    final builtInRows = [
      for (final preset in description.builtIn)
        if (_matches(description.nameOf(preset))) preset,
    ];

    Widget header(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(description.title,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                IconButton(
                  key: const Key('addCustomPreset'),
                  tooltip: description.addLabel,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  onPressed: () => description.addNew(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: description.searchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: customRows.isEmpty && builtInRows.isEmpty
                ? Center(child: Text(description.emptyLabel))
                : ListView(
                    controller: scrollController,
                    children: [
                      if (customRows.isNotEmpty) ...[
                        header(l10n.My_Presets),
                        for (final index in customRows)
                          ListTile(
                            title: Text(description.nameOf(customItems[index])),
                            subtitle: Text(description.subtitleOf(
                                context, customItems[index])),
                            trailing: PresetRowMenu(
                              onEdit: () => description.edit(context, index),
                              onDuplicate: () => description.duplicateInto(
                                  context, customItems[index]),
                              onDelete: () =>
                                  description.confirmDelete(context, index),
                            ),
                            onTap: () =>
                                Navigator.pop(context, customItems[index]),
                          ),
                      ],
                      if (builtInRows.isNotEmpty) ...[
                        if (customRows.isNotEmpty)
                          header(l10n.Built_In_Presets),
                        for (final preset in builtInRows)
                          ListTile(
                            title: Text(description.nameOf(preset)),
                            subtitle:
                                Text(description.subtitleOf(context, preset)),
                            trailing: PresetRowMenu(
                              onDuplicate: () =>
                                  description.duplicateInto(context, preset),
                            ),
                            onTap: () => Navigator.pop(context, preset),
                          ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// The ⋮ menu on a preset row. A built-in offers only a copy to adjust; a
/// custom entry can also be edited or deleted.
class PresetRowMenu extends StatelessWidget {
  const PresetRowMenu({
    super.key,
    this.onEdit,
    required this.onDuplicate,
    this.onDelete,
  });

  final VoidCallback? onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return PopupMenuButton<VoidCallback>(
      tooltip: l10n.More_Actions,
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: (action) => action(),
      itemBuilder: (context) => [
        if (onEdit != null)
          PopupMenuItem(
            value: onEdit,
            child: ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.Edit),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        PopupMenuItem(
          value: onDuplicate,
          child: ListTile(
            leading: const Icon(Icons.copy_rounded),
            title:
                Text(onEdit == null ? l10n.Duplicate_And_Edit : l10n.Duplicate),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (onDelete != null)
          PopupMenuItem(
            value: onDelete,
            child: ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: Text(l10n.Delete),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}
