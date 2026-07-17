import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class IsotropicMaterialRow extends StatefulWidget {
  final String title;
  final IsotropicMaterial material;
  final bool validate;

  const IsotropicMaterialRow(
      {Key? key,
      required this.title,
      required this.material,
      required this.validate})
      : super(key: key);

  @override
  _IsotropicMaterialRowState createState() => _IsotropicMaterialRowState();
}

class _IsotropicMaterialRowState extends State<IsotropicMaterialRow> {
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
                widget.title,
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
                          label: "E1",
                          category: UnitCategory.modulus,
                          initialSI: widget.material.e,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: widget.validate
                              ? (si) => validateModulus(si)
                              : null,
                          onChangedSI: (value) {
                            widget.material.e = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "ν",
                              errorText: widget.validate
                                  ? validatePoissonRatio(widget.material.nu)
                                  : null),
                          onChanged: (value) {
                            widget.material.nu = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ));
  }
}
