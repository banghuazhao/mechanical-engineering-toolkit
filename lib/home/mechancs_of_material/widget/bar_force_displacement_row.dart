import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/bar_force_displacement_model.dart';

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
  late TextEditingController _pController;
  late TextEditingController _lController;
  late TextEditingController _eController;
  late TextEditingController _aController;

  @override
  void initState() {
    super.initState();
    _pController = TextEditingController(
        text: widget.barForceDisplacementModel.p?.toString() ?? '');
    _lController = TextEditingController(
        text: widget.barForceDisplacementModel.l?.toString() ?? '');
    _eController = TextEditingController(
        text: widget.barForceDisplacementModel.e?.toString() ?? '');
    _aController = TextEditingController(
        text: widget.barForceDisplacementModel.area?.toString() ?? '');
  }

  @override
  void dispose() {
    _pController.dispose();
    _lController.dispose();
    _eController.dispose();
    _aController.dispose();
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
                          controller: _pController,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: true, decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "P",
                              errorText: widget.validate
                                  ? validateForce(
                                      widget.barForceDisplacementModel.p)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.barForceDisplacementModel.p =
                                double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _lController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "L",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.barForceDisplacementModel.l)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.barForceDisplacementModel.l =
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
                          controller: _eController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "E",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.barForceDisplacementModel.e)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.barForceDisplacementModel.e =
                                double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _aController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "Area",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.barForceDisplacementModel.area)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            widget.barForceDisplacementModel.area =
                                double.tryParse(value);
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
