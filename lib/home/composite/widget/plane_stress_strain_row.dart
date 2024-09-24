import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';

class PlaneStressStrainRow extends StatefulWidget {
  final MechanicalTensor mechanicalTensor;
  final bool validate;
  final Function(String) callback;

  const PlaneStressStrainRow(
      {Key? key,
      required this.mechanicalTensor,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _PlaneStressStrainRowState createState() => _PlaneStressStrainRowState();
}

class _PlaneStressStrainRowState extends State<PlaneStressStrainRow> {
  String dropValue = "Stress";

  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();

  validateTensor(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dropValue = S.of(context).Stress;
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  S.of(context).Inputs,
                  style: Theme.of(context).textTheme.headline6,
                ),
                DropdownButton<String>(
                  value: dropValue,
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Color(0xff666159)),
                  underline: Container(
                    height: 2,
                    color: Color(0xffA8866B),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropValue = newValue!;
                      widget.callback(dropValue);
                      textEditingController1.clear();
                      textEditingController2.clear();
                      textEditingController3.clear();
                    });
                  },
                  items: <String>[S.of(context).Stress, S.of(context).Strain]
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController1,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(),
                        labelText:
                            dropValue == S.of(context).Stress ? "σ11" : "ε11",
                        errorText: widget.validate
                            ? validateTensor(dropValue == S.of(context).Stress
                                ? (widget.mechanicalTensor as PlaneStress)
                                    .sigma11
                                : (widget.mechanicalTensor as PlaneStrain)
                                    .epsilon11)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      if (dropValue == S.of(context).Stress) {
                        (widget.mechanicalTensor as PlaneStress).sigma11 =
                            double.tryParse(value);
                      } else {
                        (widget.mechanicalTensor as PlaneStrain).epsilon11 =
                            double.tryParse(value);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: TextField(
                    controller: textEditingController2,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(),
                        labelText:
                            dropValue == S.of(context).Stress ? "σ22" : "ε22",
                        errorText: widget.validate
                            ? validateTensor(dropValue == S.of(context).Stress
                                ? (widget.mechanicalTensor as PlaneStress)
                                    .sigma22
                                : (widget.mechanicalTensor as PlaneStrain)
                                    .epsilon22)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      if (dropValue == S.of(context).Stress) {
                        (widget.mechanicalTensor as PlaneStress).sigma22 =
                            double.tryParse(value);
                      } else {
                        (widget.mechanicalTensor as PlaneStrain).epsilon22 =
                            double.tryParse(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textEditingController3,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(),
                        labelText: dropValue == S.of(context).Stress
                            ? "σ12"
                            : "γ12 (2ε12)",
                        errorText: widget.validate
                            ? validateTensor(dropValue == S.of(context).Stress
                                ? (widget.mechanicalTensor as PlaneStress)
                                    .sigma12
                                : (widget.mechanicalTensor as PlaneStrain)
                                    .gamma12)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      if (dropValue == S.of(context).Stress) {
                        (widget.mechanicalTensor as PlaneStress).sigma12 =
                            double.tryParse(value);
                      } else {
                        (widget.mechanicalTensor as PlaneStrain).gamma12 =
                            double.tryParse(value);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
