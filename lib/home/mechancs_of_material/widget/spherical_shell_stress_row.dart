import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/spherical_shell_stress_model.dart';

class SphericalShellStressRow extends StatefulWidget {
  final SphericalShellStressModel sphericalShellStressModel;
  final bool validate;

  const SphericalShellStressRow(
      {Key? key,
      required this.sphericalShellStressModel,
      required this.validate})
      : super(key: key);

  @override
  _LaminaContantsRowState createState() => _LaminaContantsRowState();
}

class _LaminaContantsRowState extends State<SphericalShellStressRow> {
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
                              labelText: "p",
                              errorText: widget.validate
                                  ? validateForce(
                                      widget.sphericalShellStressModel.p)
                                  : null),
                          onChanged: (value) {
                            widget.sphericalShellStressModel.p =
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
                                      widget.sphericalShellStressModel.r)
                                  : null),
                          onChanged: (value) {
                            widget.sphericalShellStressModel.r =
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
                              labelText: "t",
                              errorText: widget.validate
                                  ? validateModulus(
                                      widget.sphericalShellStressModel.t)
                                  : null),
                          onChanged: (value) {
                            widget.sphericalShellStressModel.t =
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
