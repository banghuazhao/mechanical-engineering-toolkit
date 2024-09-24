import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/bar_torsion_formula_model.dart';

class BarTorsionFormulaRow extends StatefulWidget {
  final BarTorsionFormulaModel barTorsionFormulaModel;
  final bool validate;

  const BarTorsionFormulaRow(
      {Key? key, required this.barTorsionFormulaModel, required this.validate})
      : super(key: key);

  @override
  _BarTorsionFormulaRowState createState() => _BarTorsionFormulaRowState();
}

class _BarTorsionFormulaRowState extends State<BarTorsionFormulaRow> {
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
                              labelText: "T",
                              errorText: widget.validate
                                  ? validateForce(
                                      widget.barTorsionFormulaModel.T)
                                  : null),
                          onChanged: (value) {
                            widget.barTorsionFormulaModel.T =
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
                              labelText: "r",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.barTorsionFormulaModel.r)
                                  : null),
                          onChanged: (value) {
                            widget.barTorsionFormulaModel.r =
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
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "Ip",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.barTorsionFormulaModel.Ip)
                                  : null),
                          onChanged: (value) {
                            widget.barTorsionFormulaModel.Ip =
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
