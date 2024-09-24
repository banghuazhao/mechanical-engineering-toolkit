import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';

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
                              labelText: "σx",
                              errorText: widget.validate
                                  ? validateForce(widget.planeStress.sigma11)
                                  : null),
                          onChanged: (value) {
                            widget.planeStress.sigma11 = double.tryParse(value);
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
                              labelText: "σy",
                              errorText: widget.validate
                                  ? validateForce(widget.planeStress.sigma22)
                                  : null),
                          onChanged: (value) {
                            widget.planeStress.sigma22 = double.tryParse(value);
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
                              labelText: "𝛕xy",
                              errorText: widget.validate
                                  ? validateForce(widget.planeStress.sigma12)
                                  : null),
                          onChanged: (value) {
                            widget.planeStress.sigma12 = double.tryParse(value);
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
