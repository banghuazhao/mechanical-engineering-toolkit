import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/bar_force_displacement_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class BarForceDisplacementRow extends StatefulWidget {
  final BarTorsionFormulaModel barForceDisplacementModel;
  final bool validate;

  const BarForceDisplacementRow(
      {Key? key,
      required this.barForceDisplacementModel,
      required this.validate})
      : super(key: key);

  @override
  _LaminaContantsRowState createState() => _LaminaContantsRowState();
}

class _LaminaContantsRowState extends State<BarForceDisplacementRow> {
  validateModulus(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0) {
      return "Not > 0";
    } else {
      return null;
    }
  }

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
                S.of(context).Inputs,
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
                          label: "P",
                          category: UnitCategory.force,
                          initialSI: widget.barForceDisplacementModel.p,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.barForceDisplacementModel.p = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UnitField(
                          label: "L",
                          category: UnitCategory.length,
                          initialSI: widget.barForceDisplacementModel.l,
                          signed: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateModulus(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.barForceDisplacementModel.l = value;
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
                          label: "E",
                          category: UnitCategory.stress,
                          initialSI: widget.barForceDisplacementModel.e,
                          signed: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateModulus(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.barForceDisplacementModel.e = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UnitField(
                          label: "Area",
                          category: UnitCategory.area,
                          initialSI: widget.barForceDisplacementModel.area,
                          signed: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateModulus(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.barForceDisplacementModel.area = value;
                          },
                        ),
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
