import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';

class MaterialInputRow extends StatefulWidget {
  final MechanicalMaterial material;
  final bool validate;
  final Function(String) callback;

  const MaterialInputRow(
      {Key? key,
      required this.material,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _MaterialInputRowState createState() => _MaterialInputRowState();
}

class _MaterialInputRowState extends State<MaterialInputRow> {
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
  TextEditingController textEditingController14 = TextEditingController();
  TextEditingController textEditingController15 = TextEditingController();
  TextEditingController textEditingController16 = TextEditingController();
  TextEditingController textEditingController17 = TextEditingController();
  TextEditingController textEditingController18 = TextEditingController();
  TextEditingController textEditingController19 = TextEditingController();
  TextEditingController textEditingController20 = TextEditingController();
  TextEditingController textEditingController21 = TextEditingController();

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
                            textEditingController14.clear();
                            textEditingController15.clear();
                            textEditingController16.clear();
                            textEditingController17.clear();
                            textEditingController18.clear();
                            textEditingController19.clear();
                            textEditingController20.clear();
                            textEditingController21.clear();
                          });
                        },
                        items: <String>[
                          S.of(context).Isotropic_material,
                          S.of(context).Transversely_isotropic_material,
                          S.of(context).Orthotropic_material,
                          S.of(context).Monoclinic_material,
                          S.of(context).Anisotropic_material
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
    } else if (dropValue == S.of(context).Anisotropic_material) {
      AnisotropicMaterial material = (widget.material as AnisotropicMaterial);
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
                      labelText: "C11",
                      errorText:
                          widget.validate ? validateNumber(material.c11) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c11 = double.tryParse(value);
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
                      labelText: "C12",
                      errorText:
                          widget.validate ? validateNumber(material.c12) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c12 = double.tryParse(value);
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
                      labelText: "C13",
                      errorText:
                          widget.validate ? validateNumber(material.c13) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c13 = double.tryParse(value);
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
                      labelText: "C14",
                      errorText:
                          widget.validate ? validateNumber(material.c14) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c14 = double.tryParse(value);
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
                      labelText: "C15",
                      errorText:
                          widget.validate ? validateNumber(material.c15) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c15 = double.tryParse(value);
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
                      labelText: "C16",
                      errorText:
                          widget.validate ? validateNumber(material.c16) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c16 = double.tryParse(value);
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
                      labelText: "C22",
                      errorText:
                          widget.validate ? validateNumber(material.c22) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c22 = double.tryParse(value);
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
                      labelText: "C23",
                      errorText:
                          widget.validate ? validateNumber(material.c23) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c23 = double.tryParse(value);
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
                      labelText: "C24",
                      errorText:
                          widget.validate ? validateNumber(material.c24) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c24 = double.tryParse(value);
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
                      labelText: "C25",
                      errorText:
                          widget.validate ? validateNumber(material.c25) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c25 = double.tryParse(value);
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
                      labelText: "C26",
                      errorText:
                          widget.validate ? validateNumber(material.c26) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c26 = double.tryParse(value);
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
                      labelText: "C33",
                      errorText:
                          widget.validate ? validateNumber(material.c33) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c33 = double.tryParse(value);
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
                      labelText: "C34",
                      errorText:
                          widget.validate ? validateNumber(material.c34) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c34 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController14,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C35",
                      errorText:
                          widget.validate ? validateNumber(material.c35) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c35 = double.tryParse(value);
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
                  controller: textEditingController15,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C36",
                      errorText:
                          widget.validate ? validateNumber(material.c36) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c36 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController16,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C44",
                      errorText:
                          widget.validate ? validateNumber(material.c44) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c44 = double.tryParse(value);
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
                  controller: textEditingController17,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C45",
                      errorText:
                          widget.validate ? validateNumber(material.c45) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c45 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController18,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C46",
                      errorText:
                          widget.validate ? validateNumber(material.c46) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c46 = double.tryParse(value);
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
                  controller: textEditingController19,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C55",
                      errorText:
                          widget.validate ? validateNumber(material.c55) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c55 = double.tryParse(value);
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: TextField(
                  controller: textEditingController20,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C56",
                      errorText:
                          widget.validate ? validateNumber(material.c56) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c56 = double.tryParse(value);
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
                  controller: textEditingController21,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      border: const OutlineInputBorder(),
                      labelText: "C66",
                      errorText:
                          widget.validate ? validateNumber(material.c66) : null,
                      errorStyle: const TextStyle(fontSize: 10)),
                  onChanged: (value) {
                    material.c66 = double.tryParse(value);
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
