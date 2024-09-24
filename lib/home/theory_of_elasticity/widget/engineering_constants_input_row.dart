import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';

class EngineeringConstantsInputRow extends StatefulWidget {
  final MechanicalMaterial material;
  final bool validate;
  final Function(String) callback;

  const EngineeringConstantsInputRow(
      {Key? key,
      required this.material,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _EngineeringConstantsInputRowState createState() =>
      _EngineeringConstantsInputRowState();
}

class _EngineeringConstantsInputRowState
    extends State<EngineeringConstantsInputRow> {
  String dropValue = "Isotropic material";

  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();
  TextEditingController textEditingController4 = TextEditingController();
  TextEditingController textEditingController5 = TextEditingController();
  TextEditingController textEditingController6 = TextEditingController();
  TextEditingController textEditingController7 = TextEditingController();
  TextEditingController textEditingController8 = TextEditingController();
  TextEditingController textEditingController9 = TextEditingController();
  TextEditingController textEditingController10 = TextEditingController();
  TextEditingController textEditingController11 = TextEditingController();
  TextEditingController textEditingController12 = TextEditingController();
  TextEditingController textEditingController13 = TextEditingController();

  validateNumber(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else {
      return null;
    }
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

  validatePoissonRatio(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0 || value >= 0.5) {
      return "Not in (0, 0.5)";
    } else {
      return null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dropValue = S.of(context).Isotropic_material;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                            textEditingController4.clear();
                            textEditingController5.clear();
                            textEditingController6.clear();
                            textEditingController7.clear();
                            textEditingController8.clear();
                            textEditingController9.clear();
                            textEditingController10.clear();
                            textEditingController11.clear();
                            textEditingController12.clear();
                            textEditingController13.clear();
                          });
                        },
                        items: <String>[
                          S.of(context).Isotropic_material,
                          S.of(context).Transversely_isotropic_material,
                          S.of(context).Orthotropic_material,
                          S.of(context).Monoclinic_material,
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                )
              ] +
              buildInputs()),
    );
  }

  List<Widget> buildInputs() {
    if (dropValue == S.of(context).Isotropic_material) {
      IsotropicMaterial material = (widget.material as IsotropicMaterial);
      return [
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
                      labelText: "E",
                      errorText:
                          widget.validate ? validateModulus(material.e) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e = double.tryParse(value);
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
                      labelText: "ν",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
      ];
    } else if (dropValue == S.of(context).Transversely_isotropic_material) {
      TransverselyIsotropicMaterial material =
          (widget.material as TransverselyIsotropicMaterial);
      return [
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
                      labelText: "E1",
                      errorText:
                          widget.validate ? validateModulus(material.e1) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e1 = double.tryParse(value);
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
                      labelText: "E2",
                      errorText:
                          widget.validate ? validateModulus(material.e2) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e2 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                      labelText: "G12",
                      errorText: widget.validate
                          ? validateModulus(material.g12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g12 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController4,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν12",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu12 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController5,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν23",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu23 = double.tryParse(value);
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
        SizedBox(
          height: 12,
        ),
      ];
    } else if (dropValue == S.of(context).Orthotropic_material) {
      OrthotropicMaterial material = (widget.material as OrthotropicMaterial);
      return [
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
                      labelText: "E1",
                      errorText:
                          widget.validate ? validateModulus(material.e1) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e1 = double.tryParse(value);
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
                      labelText: "E2",
                      errorText:
                          widget.validate ? validateModulus(material.e2) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e2 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                      labelText: "E3",
                      errorText:
                          widget.validate ? validateModulus(material.e3) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e3 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController4,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G12",
                      errorText: widget.validate
                          ? validateModulus(material.g12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g12 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController5,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G13",
                      errorText: widget.validate
                          ? validateModulus(material.g13)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g13 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController6,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G23",
                      errorText: widget.validate
                          ? validateModulus(material.g23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g23 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController7,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν12",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu12 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController8,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν13",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu13)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu13 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController9,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν23",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu23 = double.tryParse(value);
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
        SizedBox(
          height: 12,
        ),
      ];
    } else if (dropValue == S.of(context).Monoclinic_material) {
      MonoclinicMaterial material = (widget.material as MonoclinicMaterial);
      return [
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
                      labelText: "E1",
                      errorText:
                          widget.validate ? validateModulus(material.e1) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e1 = double.tryParse(value);
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
                      labelText: "E2",
                      errorText:
                          widget.validate ? validateModulus(material.e2) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e2 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                      labelText: "E3",
                      errorText:
                          widget.validate ? validateModulus(material.e3) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.e3 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController4,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G12",
                      errorText: widget.validate
                          ? validateModulus(material.g12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g12 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController5,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G13",
                      errorText: widget.validate
                          ? validateModulus(material.g13)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g13 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController6,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "G23",
                      errorText: widget.validate
                          ? validateModulus(material.g23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.g23 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController7,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν12",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu12 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController8,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν13",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu13)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu13 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController9,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "ν23",
                      errorText: widget.validate
                          ? validatePoissonRatio(material.nu23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.nu23 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController10,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "η1,12",
                      errorText: widget.validate
                          ? validateNumber(material.eta1_12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.eta1_12 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController11,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "η2,12",
                      errorText: widget.validate
                          ? validateNumber(material.eta2_12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.eta2_12 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController12,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "η3,12",
                      errorText: widget.validate
                          ? validateNumber(material.eta3_12)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.eta3_12 = double.tryParse(value);
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 12,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController13,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "η12,23",
                      errorText: widget.validate
                          ? validateNumber(material.eta13_23)
                          : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.eta13_23 = double.tryParse(value);
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
        SizedBox(
          height: 12,
        ),
      ];
    }
    return [];
  }
}
