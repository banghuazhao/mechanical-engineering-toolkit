import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class PlaneStressRow extends StatefulWidget {
  final PlaneStress planeStress;
  final bool validate;

  const PlaneStressRow(
      {Key? key, required this.planeStress, required this.validate})
      : super(key: key);

  @override
  _PlaneStressRowState createState() => _PlaneStressRowState();
}

class _PlaneStressRowState extends State<PlaneStressRow> {
  validateForce(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
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
                S.of(context).Plane_Stresses,
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
                          label: "σx",
                          category: UnitCategory.stress,
                          initialSI: widget.planeStress.sigma11,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.planeStress.sigma11 = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UnitField(
                          label: "σy",
                          category: UnitCategory.stress,
                          initialSI: widget.planeStress.sigma22,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.planeStress.sigma22 = value;
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
                          label: "𝛕xy",
                          category: UnitCategory.stress,
                          initialSI: widget.planeStress.sigma12,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.planeStress.sigma12 = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ));
  }
}
