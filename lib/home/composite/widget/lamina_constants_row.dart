import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';

class LaminaContantsRow extends StatefulWidget {
  final TransverselyIsotropicMaterial material;
  final bool validate;
  final bool isPlaneStress;

  const LaminaContantsRow(
      {Key? key,
      required this.material,
      required this.validate,
      required this.isPlaneStress})
      : super(key: key);

  @override
  _LaminaContantsRowState createState() => _LaminaContantsRowState();
}

class _LaminaContantsRowState extends State<LaminaContantsRow> {
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
                S.of(context).Lamina_Constants,
                style: Theme.of(context).textTheme.headline6,
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
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "E1",
                              errorText: widget.validate
                                  ? validateModulus(widget.material.e1)
                                  : null),
                          onChanged: (value) {
                            widget.material.e1 = double.tryParse(value);
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
                              labelText: "E2",
                              errorText: widget.validate
                                  ? validateModulus(widget.material.e2)
                                  : null),
                          onChanged: (value) {
                            widget.material.e2 = double.tryParse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "G12",
                              errorText: widget.validate
                                  ? validateModulus(widget.material.g12)
                                  : null),
                          onChanged: (value) {
                            widget.material.g12 = double.tryParse(value);
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
                              labelText: "ν12",
                              errorText: widget.validate
                                  ? validatePoissonRatio(widget.material.nu12)
                                  : null),
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
                                        : null),
                                onChanged: (value) {
                                  widget.material.nu23 = double.tryParse(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Container()),
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
