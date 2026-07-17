import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_flexure_formula_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class BeamFlexureFormulaRow extends StatefulWidget {
  final BeamFlexureFormulaModel beamFlexureFormulaModel;
  final bool validate;

  const BeamFlexureFormulaRow(
      {Key? key, required this.beamFlexureFormulaModel, required this.validate})
      : super(key: key);

  @override
  _LaminaContantsRowState createState() => _LaminaContantsRowState();
}

class _LaminaContantsRowState extends State<BeamFlexureFormulaRow> {
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
                          label: "M",
                          category: UnitCategory.momentSection,
                          initialSI: widget.beamFlexureFormulaModel.M,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.beamFlexureFormulaModel.M = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: UnitField(
                          label: "I",
                          category: UnitCategory.momentOfInertia,
                          initialSI: widget.beamFlexureFormulaModel.I,
                          signed: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateModulus(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.beamFlexureFormulaModel.I = value;
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
                          label: "y",
                          category: UnitCategory.length,
                          initialSI: widget.beamFlexureFormulaModel.y,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validateForce(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            widget.beamFlexureFormulaModel.y = value;
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
