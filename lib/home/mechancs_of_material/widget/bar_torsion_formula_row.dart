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
  late TextEditingController _tController;
  late TextEditingController _rController;
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    _tController = TextEditingController(
        text: widget.barTorsionFormulaModel.T?.toString() ?? '');
    _rController = TextEditingController(
        text: widget.barTorsionFormulaModel.r?.toString() ?? '');
    _ipController = TextEditingController(
        text: widget.barTorsionFormulaModel.Ip?.toString() ?? '');
  }

  @override
  void dispose() {
    _tController.dispose();
    _rController.dispose();
    _ipController.dispose();
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
                        child: TextField(
                          controller: _tController,
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
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.barTorsionFormulaModel.T =
                                double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _rController,
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
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
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
                          controller: _ipController,
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
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
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
