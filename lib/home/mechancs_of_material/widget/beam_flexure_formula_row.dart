import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_flexure_formula_model.dart';

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
                              signed: true, decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "M",
                              errorText: widget.validate
                                  ? validateForce(
                                      widget.beamFlexureFormulaModel.M)
                                  : null),
                          onChanged: (value) {
                            widget.beamFlexureFormulaModel.M =
                                double.tryParse(value);
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
                              labelText: "I",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.beamFlexureFormulaModel.I)
                                  : null),
                          onChanged: (value) {
                            widget.beamFlexureFormulaModel.I =
                                double.tryParse(value);
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
                              signed: true, decimal: true),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(12),
                            border: const OutlineInputBorder(),
                            labelText: "y (optional)",
                          ),
                          onChanged: (value) {
                            widget.beamFlexureFormulaModel.y =
                                double.tryParse(value);
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
