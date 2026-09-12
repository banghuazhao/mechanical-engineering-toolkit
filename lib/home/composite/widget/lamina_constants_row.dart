import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class LaminaContantsRow extends StatefulWidget {
  final TransverselyIsotropicMaterial material;
  final bool validate;
  final bool isPlaneStress;
  final String? title;

  const LaminaContantsRow(
      {Key? key,
      required this.material,
      required this.validate,
      required this.isPlaneStress,
      this.title})
      : super(key: key);

  @override
  _LaminaContantsRowState createState() => _LaminaContantsRowState();
}

class _LaminaContantsRowState extends State<LaminaContantsRow> {
  late TextEditingController _nu12Controller;
  late TextEditingController _nu23Controller;

  /// Re-keys the modulus fields when a preset lands, so each re-reads its
  /// initial value instead of keeping whatever was typed before.
  int _presetGeneration = 0;

  void _applyPreset(LaminaPreset preset) {
    setState(() {
      widget.material
        ..e1 = preset.e1
        ..e2 = preset.e2
        ..g12 = preset.g12
        ..nu12 = preset.nu12;
      _nu12Controller.text = preset.nu12.toString();
      _presetGeneration++;
    });
  }

  @override
  void initState() {
    super.initState();
    _nu12Controller =
        TextEditingController(text: widget.material.nu12?.toString() ?? '');
    _nu23Controller =
        TextEditingController(text: widget.material.nu23?.toString() ?? '');
  }

  @override
  void dispose() {
    _nu12Controller.dispose();
    _nu23Controller.dispose();
    super.dispose();
  }

  validateModulus(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0) {
      return "Not > 0";
    } else {
      return null;
    }
  }

  validatePoissonRatio(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0 || value >= 0.5) {
      return "Not in (0, 0.5)";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                widget.title ?? S.of(context).Lamina_Constants,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: UnitField(
                          key: ValueKey('E1$_presetGeneration'),
                          label: "E1",
                          category: UnitCategory.modulus,
                          initialSI: widget.material.e1,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: widget.validate
                              ? (si) => validateModulus(si)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.material.e1 = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UnitField(
                          key: ValueKey('E2$_presetGeneration'),
                          label: "E2",
                          category: UnitCategory.modulus,
                          initialSI: widget.material.e2,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: widget.validate
                              ? (si) => validateModulus(si)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.material.e2 = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: UnitField(
                          key: ValueKey('G12$_presetGeneration'),
                          label: "G12",
                          category: UnitCategory.modulus,
                          initialSI: widget.material.g12,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: widget.validate
                              ? (si) => validateModulus(si)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.material.g12 = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _nu12Controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "ν12",
                              errorText: widget.validate
                                  ? validatePoissonRatio(widget.material.nu12)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.material.nu12 = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  widget.isPlaneStress
                      ? Container()
                      : const SizedBox(height: 12),
                  widget.isPlaneStress
                      ? Container()
                      : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nu23Controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(12),
                                    border: const OutlineInputBorder(),
                                    labelText: "ν23",
                                    errorText: widget.validate
                                        ? validatePoissonRatio(
                                            widget.material.nu23)
                                        : null,
                                    errorStyle: const TextStyle(fontSize: 10)),
                                onChanged: (value) {
                                  widget.material.nu23 = double.tryParse(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Container()),
                          ],
                        ),
                  const SizedBox(height: 8),
                  LaminaPresetButton(onSelected: _applyPreset),
                  Text(
                    S.of(context).Lamina_Preset_Note,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ));
  }
}
