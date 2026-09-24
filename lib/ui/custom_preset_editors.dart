import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// The bottom-sheet form every custom-preset editor shares: a title, a name
/// that must be unique in its library, the library's own fields, and Save.
///
/// Each editor below only supplies its fields and how to turn them into a
/// preset; the name rules and the layout are the same for all four, so they
/// live here once.
class _PresetEditorSheet extends StatefulWidget {
  const _PresetEditorSheet({
    required this.title,
    required this.initialName,
    required this.isNameTaken,
    required this.fields,
    required this.build,
    this.hint,
  });

  final String title;
  final String initialName;
  final bool Function(String name) isNameTaken;
  final List<Widget> fields;
  final String? hint;

  /// Assembles the preset from [name], or returns an error message when the
  /// fields do not describe one yet.
  final Object Function(String name) build;

  @override
  State<_PresetEditorSheet> createState() => _PresetEditorSheetState();
}

class _PresetEditorSheetState extends State<_PresetEditorSheet> {
  late final _nameController = TextEditingController(text: widget.initialName);
  String? _nameError;
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = S.of(context);
    final name = _nameController.text.trim();
    setState(() {
      _nameError = name.isEmpty
          ? l10n.Preset_Name_Required
          : widget.isNameTaken(name)
              ? l10n.Preset_Name_Taken
              : null;
      _formError = null;
    });
    if (_nameError != null) return;
    final built = widget.build(name);
    if (built is String) {
      setState(() => _formError = built);
      return;
    }
    Navigator.pop(context, built);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text(widget.title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              key: const Key('presetName'),
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: S.of(context).Name,
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            AdaptiveFieldGrid(children: widget.fields),
            if (widget.hint != null) ...[
              const SizedBox(height: 8),
              Text(
                widget.hint!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_formError != null) ...[
              const SizedBox(height: 8),
              Text(
                _formError!,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('savePreset'),
              onPressed: _save,
              child: Text(S.of(context).Save),
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> _showEditor<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      builder: (_) => sheet,
    );

/// Poisson's ratio of a stable isotropic solid lies in (−1, 0.5].
bool _isPhysicalPoisson(double nu) => nu > -1 && nu <= 0.5;

Future<MaterialPreset?> showIsotropicMaterialEditor(
  BuildContext context, {
  MaterialPreset? initial,
  required bool Function(String name) isNameTaken,
}) {
  final l10n = S.of(context);
  double? e = initial?.elasticModulusSI;
  double? g = initial?.shearModulusSI;
  double? nu = initial?.poissonsRatio;
  double? sy = initial?.yieldStrengthSI;
  double? su = initial?.ultimateStrengthSI;
  double? rho = initial?.densitySI;
  return _showEditor<MaterialPreset>(
    context,
    _PresetEditorSheet(
      title: initial == null ? l10n.Add_Custom_Material : l10n.Edit_Preset,
      initialName: initial?.name ?? '',
      isNameTaken: isNameTaken,
      hint: l10n.Custom_Material_Hint,
      fields: [
        UnitField(
          label: l10n.E_Modulus,
          category: UnitCategory.modulus,
          signed: false,
          initialSI: e,
          onChangedSI: (v) => e = v,
        ),
        UnitField(
          label: l10n.G_Shear_Modulus,
          category: UnitCategory.modulus,
          signed: false,
          initialSI: g,
          onChangedSI: (v) => g = v,
        ),
        UnitField(
          label: l10n.Poissons_Ratio_Nu,
          category: null,
          initialSI: nu,
          onChangedSI: (v) => nu = v,
        ),
        UnitField(
          label: l10n.Yield_Strength,
          category: UnitCategory.stress,
          signed: false,
          initialSI: sy,
          onChangedSI: (v) => sy = v,
        ),
        UnitField(
          label: l10n.Ultimate_Strength,
          category: UnitCategory.stress,
          signed: false,
          initialSI: su,
          onChangedSI: (v) => su = v,
        ),
        UnitField(
          label: l10n.Density,
          category: UnitCategory.density,
          signed: false,
          initialSI: rho,
          onChangedSI: (v) => rho = v,
        ),
      ],
      build: (name) {
        if ([e, g, nu, sy, su, rho].every((v) => v == null)) {
          return l10n.Preset_Needs_A_Property;
        }
        if (nu != null && !_isPhysicalPoisson(nu!)) {
          return l10n.Err_Poisson_Range;
        }
        // An isotropic solid has only two independent elastic constants, so
        // the third is implied: fill G rather than leave the shear tools
        // without it.
        final shear =
            g ?? (e != null && nu != null ? e! / (2 * (1 + nu!)) : null);
        return MaterialPreset(
          name: name,
          category: initial?.category ?? MaterialCategory.other,
          elasticModulusSI: e,
          shearModulusSI: shear,
          poissonsRatio: nu,
          yieldStrengthSI: sy,
          ultimateStrengthSI: su,
          densitySI: rho,
          isCustom: true,
        );
      },
    ),
  );
}

Future<LaminaPreset?> showLaminaEditor(
  BuildContext context, {
  LaminaPreset? initial,
  required bool Function(String name) isNameTaken,
}) {
  final l10n = S.of(context);
  double? e1 = initial?.e1;
  double? e2 = initial?.e2;
  double? g12 = initial?.g12;
  double? nu12 = initial?.nu12;
  double? xt = initial?.xt;
  double? xc = initial?.xc;
  double? yt = initial?.yt;
  double? yc = initial?.yc;
  double? s = initial?.s;

  Widget modulus(
          String label, double? value, ValueChanged<double?> onChanged) =>
      UnitField(
        label: label,
        category: UnitCategory.modulus,
        signed: false,
        initialSI: value,
        onChangedSI: onChanged,
      );
  Widget strength(
          String label, double? value, ValueChanged<double?> onChanged) =>
      UnitField(
        label: label,
        category: UnitCategory.stress,
        signed: false,
        initialSI: value,
        onChangedSI: onChanged,
      );

  return _showEditor<LaminaPreset>(
    context,
    _PresetEditorSheet(
      title: initial == null ? l10n.Add_Custom_Lamina : l10n.Edit_Preset,
      initialName: initial?.name ?? '',
      isNameTaken: isNameTaken,
      hint: l10n.Custom_Lamina_Hint,
      fields: [
        modulus('E1', e1, (v) => e1 = v),
        modulus('E2', e2, (v) => e2 = v),
        modulus('G12', g12, (v) => g12 = v),
        UnitField(
          label: 'ν12',
          category: null,
          initialSI: nu12,
          onChangedSI: (v) => nu12 = v,
        ),
        strength(l10n.Strength_Xt, xt, (v) => xt = v),
        strength(l10n.Strength_Xc, xc, (v) => xc = v),
        strength(l10n.Strength_Yt, yt, (v) => yt = v),
        strength(l10n.Strength_Yc, yc, (v) => yc = v),
        strength(l10n.Strength_S, s, (v) => s = v),
      ],
      build: (name) {
        if (e1 == null || e2 == null || g12 == null || nu12 == null) {
          return l10n.Err_Lamina_Constants_Required;
        }
        return LaminaPreset(
          name: name,
          e1: e1!,
          e2: e2!,
          g12: g12!,
          nu12: nu12!,
          xt: xt,
          xc: xc,
          yt: yt,
          yc: yc,
          s: s,
          isCustom: true,
        );
      },
    ),
  );
}

Future<FluidPreset?> showFluidEditor(
  BuildContext context, {
  FluidPreset? initial,
  required bool Function(String name) isNameTaken,
}) {
  final l10n = S.of(context);
  double? rho = initial?.densitySI;
  double? mu = initial?.viscositySI;
  return _showEditor<FluidPreset>(
    context,
    _PresetEditorSheet(
      title: initial == null ? l10n.Add_Custom_Fluid : l10n.Edit_Preset,
      initialName: initial?.name ?? '',
      isNameTaken: isNameTaken,
      hint: l10n.Custom_Fluid_Hint,
      fields: [
        UnitField(
          label: l10n.Density_Rho,
          category: UnitCategory.density,
          signed: false,
          initialSI: rho,
          onChangedSI: (v) => rho = v,
        ),
        UnitField(
          label: l10n.Dynamic_Viscosity,
          category: UnitCategory.dynamicViscosity,
          signed: false,
          initialSI: mu,
          onChangedSI: (v) => mu = v,
        ),
      ],
      build: (name) {
        if (rho == null || mu == null || rho! <= 0 || mu! <= 0) {
          return l10n.Err_Fluid_Properties_Required;
        }
        return FluidPreset(
          name: name,
          densitySI: rho!,
          viscositySI: mu!,
          isCustom: true,
        );
      },
    ),
  );
}

Future<ThermalMaterialPreset?> showThermalMaterialEditor(
  BuildContext context, {
  ThermalMaterialPreset? initial,
  required bool Function(String name) isNameTaken,
}) {
  final l10n = S.of(context);
  double? k = initial?.conductivitySI;
  return _showEditor<ThermalMaterialPreset>(
    context,
    _ThermalGroupHolder(
      initial: initial?.group ?? ThermalMaterialGroup.metal,
      builder: (group, onGroupChanged) => _PresetEditorSheet(
        title: initial == null
            ? l10n.Add_Custom_Thermal_Material
            : l10n.Edit_Preset,
        initialName: initial?.name ?? '',
        isNameTaken: isNameTaken,
        fields: [
          UnitField(
            label: l10n.Conductivity_k,
            category: UnitCategory.thermalConductivity,
            signed: false,
            initialSI: k,
            onChangedSI: (v) => k = v,
          ),
          SegmentedButton<ThermalMaterialGroup>(
            segments: [
              ButtonSegment(
                  value: ThermalMaterialGroup.metal,
                  label: Text(l10n.Group_Metal)),
              ButtonSegment(
                  value: ThermalMaterialGroup.building,
                  label: Text(l10n.Group_Building)),
              ButtonSegment(
                  value: ThermalMaterialGroup.insulation,
                  label: Text(l10n.Group_Insulation)),
            ],
            selected: {group()},
            onSelectionChanged: (s) => onGroupChanged(s.first),
          ),
        ],
        build: (name) {
          if (k == null || k! <= 0) return l10n.Err_Conductivity_Required;
          return ThermalMaterialPreset(
            name: name,
            conductivitySI: k!,
            group: group(),
            isCustom: true,
          );
        },
      ),
    ),
  );
}

/// Holds the thermal editor's group choice, the one editor field that is a
/// selection rather than a number and so needs a rebuild when it changes.
class _ThermalGroupHolder extends StatefulWidget {
  const _ThermalGroupHolder({required this.initial, required this.builder});

  final ThermalMaterialGroup initial;
  final Widget Function(
    ThermalMaterialGroup Function() group,
    ValueChanged<ThermalMaterialGroup> onChanged,
  ) builder;

  @override
  State<_ThermalGroupHolder> createState() => _ThermalGroupHolderState();
}

class _ThermalGroupHolderState extends State<_ThermalGroupHolder> {
  late ThermalMaterialGroup _group = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(
        () => _group,
        (group) => setState(() => _group = group),
      );
}
