import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

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

  late TextEditingController textEditingController1;
  late TextEditingController textEditingController2;
  late TextEditingController textEditingController3;
  late TextEditingController textEditingController4;
  late TextEditingController textEditingController5;
  late TextEditingController textEditingController6;
  late TextEditingController textEditingController7;
  late TextEditingController textEditingController8;
  late TextEditingController textEditingController9;
  late TextEditingController textEditingController10;
  late TextEditingController textEditingController11;
  late TextEditingController textEditingController12;
  late TextEditingController textEditingController13;

  @override
  void initState() {
    super.initState();
    textEditingController1 = TextEditingController();
    textEditingController2 = TextEditingController();
    textEditingController3 = TextEditingController();
    textEditingController4 = TextEditingController();
    textEditingController5 = TextEditingController();
    textEditingController6 = TextEditingController();
    textEditingController7 = TextEditingController();
    textEditingController8 = TextEditingController();
    textEditingController9 = TextEditingController();
    textEditingController10 = TextEditingController();
    textEditingController11 = TextEditingController();
    textEditingController12 = TextEditingController();
    textEditingController13 = TextEditingController();
    _updateControllers();
  }

  @override
  void dispose() {
    textEditingController1.dispose();
    textEditingController2.dispose();
    textEditingController3.dispose();
    textEditingController4.dispose();
    textEditingController5.dispose();
    textEditingController6.dispose();
    textEditingController7.dispose();
    textEditingController8.dispose();
    textEditingController9.dispose();
    textEditingController10.dispose();
    textEditingController11.dispose();
    textEditingController12.dispose();
    textEditingController13.dispose();
    super.dispose();
  }

  void _updateControllers() {
    if (widget.material is IsotropicMaterial) {
      IsotropicMaterial material = (widget.material as IsotropicMaterial);
      textEditingController1.text = material.e?.toString() ?? '';
      textEditingController2.text = material.nu?.toString() ?? '';
    } else if (widget.material is TransverselyIsotropicMaterial) {
      TransverselyIsotropicMaterial material =
          (widget.material as TransverselyIsotropicMaterial);
      textEditingController1.text = material.e1?.toString() ?? '';
      textEditingController2.text = material.e2?.toString() ?? '';
      textEditingController3.text = material.g12?.toString() ?? '';
      textEditingController4.text = material.nu12?.toString() ?? '';
      textEditingController5.text = material.nu23?.toString() ?? '';
    } else if (widget.material is OrthotropicMaterial) {
      OrthotropicMaterial material = (widget.material as OrthotropicMaterial);
      textEditingController1.text = material.e1?.toString() ?? '';
      textEditingController2.text = material.e2?.toString() ?? '';
      textEditingController3.text = material.e3?.toString() ?? '';
      textEditingController4.text = material.g12?.toString() ?? '';
      textEditingController5.text = material.g13?.toString() ?? '';
      textEditingController6.text = material.g23?.toString() ?? '';
      textEditingController7.text = material.nu12?.toString() ?? '';
      textEditingController8.text = material.nu13?.toString() ?? '';
      textEditingController9.text = material.nu23?.toString() ?? '';
    } else if (widget.material is MonoclinicMaterial) {
      MonoclinicMaterial material = (widget.material as MonoclinicMaterial);
      textEditingController1.text = material.e1?.toString() ?? '';
      textEditingController2.text = material.e2?.toString() ?? '';
      textEditingController3.text = material.e3?.toString() ?? '';
      textEditingController4.text = material.g12?.toString() ?? '';
      textEditingController5.text = material.g13?.toString() ?? '';
      textEditingController6.text = material.g23?.toString() ?? '';
      textEditingController7.text = material.nu12?.toString() ?? '';
      textEditingController8.text = material.nu13?.toString() ?? '';
      textEditingController9.text = material.nu23?.toString() ?? '';
      textEditingController10.text = material.eta1_12?.toString() ?? '';
      textEditingController11.text = material.eta2_12?.toString() ?? '';
      textEditingController12.text = material.eta3_12?.toString() ?? '';
      textEditingController13.text = material.eta13_23?.toString() ?? '';
    }
  }

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
                            _updateControllers();
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
                child: UnitField(
                  key: const ValueKey('eciso-E'),
                  label: "E",
                  category: UnitCategory.modulus,
                  initialSI: material.e,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e = value;
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
                child: UnitField(
                  key: const ValueKey('ectrans-E1'),
                  label: "E1",
                  category: UnitCategory.modulus,
                  initialSI: material.e1,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e1 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ectrans-E2'),
                  label: "E2",
                  category: UnitCategory.modulus,
                  initialSI: material.e2,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e2 = value;
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
                child: UnitField(
                  key: const ValueKey('ectrans-G12'),
                  label: "G12",
                  category: UnitCategory.modulus,
                  initialSI: material.g12,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g12 = value;
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
                child: UnitField(
                  key: const ValueKey('ecortho-E1'),
                  label: "E1",
                  category: UnitCategory.modulus,
                  initialSI: material.e1,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e1 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecortho-E2'),
                  label: "E2",
                  category: UnitCategory.modulus,
                  initialSI: material.e2,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e2 = value;
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
                child: UnitField(
                  key: const ValueKey('ecortho-E3'),
                  label: "E3",
                  category: UnitCategory.modulus,
                  initialSI: material.e3,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e3 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecortho-G12'),
                  label: "G12",
                  category: UnitCategory.modulus,
                  initialSI: material.g12,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g12 = value;
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
                child: UnitField(
                  key: const ValueKey('ecortho-G13'),
                  label: "G13",
                  category: UnitCategory.modulus,
                  initialSI: material.g13,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g13 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecortho-G23'),
                  label: "G23",
                  category: UnitCategory.modulus,
                  initialSI: material.g23,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g23 = value;
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
                child: UnitField(
                  key: const ValueKey('ecmono-E1'),
                  label: "E1",
                  category: UnitCategory.modulus,
                  initialSI: material.e1,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e1 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecmono-E2'),
                  label: "E2",
                  category: UnitCategory.modulus,
                  initialSI: material.e2,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e2 = value;
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
                child: UnitField(
                  key: const ValueKey('ecmono-E3'),
                  label: "E3",
                  category: UnitCategory.modulus,
                  initialSI: material.e3,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.e3 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecmono-G12'),
                  label: "G12",
                  category: UnitCategory.modulus,
                  initialSI: material.g12,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g12 = value;
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
                child: UnitField(
                  key: const ValueKey('ecmono-G13'),
                  label: "G13",
                  category: UnitCategory.modulus,
                  initialSI: material.g13,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g13 = value;
                  },
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              Expanded(
                child: UnitField(
                  key: const ValueKey('ecmono-G23'),
                  label: "G23",
                  category: UnitCategory.modulus,
                  initialSI: material.g23,
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  errorText:
                      widget.validate ? (si) => validateModulus(si) : null,
                  errorStyle: const TextStyle(fontSize: 10),
                  onChangedSI: (value) {
                    material.g23 = value;
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
