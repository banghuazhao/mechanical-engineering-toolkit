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
  late TextEditingController textEditingController14;
  late TextEditingController textEditingController15;
  late TextEditingController textEditingController16;
  late TextEditingController textEditingController17;
  late TextEditingController textEditingController18;
  late TextEditingController textEditingController19;
  late TextEditingController textEditingController20;
  late TextEditingController textEditingController21;

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
    textEditingController14 = TextEditingController();
    textEditingController15 = TextEditingController();
    textEditingController16 = TextEditingController();
    textEditingController17 = TextEditingController();
    textEditingController18 = TextEditingController();
    textEditingController19 = TextEditingController();
    textEditingController20 = TextEditingController();
    textEditingController21 = TextEditingController();
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
    textEditingController14.dispose();
    textEditingController15.dispose();
    textEditingController16.dispose();
    textEditingController17.dispose();
    textEditingController18.dispose();
    textEditingController19.dispose();
    textEditingController20.dispose();
    textEditingController21.dispose();
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
    } else if (widget.material is AnisotropicMaterial) {
      AnisotropicMaterial material = (widget.material as AnisotropicMaterial);
      textEditingController1.text = material.c11?.toString() ?? '';
      textEditingController2.text = material.c12?.toString() ?? '';
      textEditingController3.text = material.c13?.toString() ?? '';
      textEditingController4.text = material.c14?.toString() ?? '';
      textEditingController5.text = material.c15?.toString() ?? '';
      textEditingController6.text = material.c16?.toString() ?? '';
      textEditingController7.text = material.c22?.toString() ?? '';
      textEditingController8.text = material.c23?.toString() ?? '';
      textEditingController9.text = material.c24?.toString() ?? '';
      textEditingController10.text = material.c25?.toString() ?? '';
      textEditingController11.text = material.c26?.toString() ?? '';
      textEditingController12.text = material.c33?.toString() ?? '';
      textEditingController13.text = material.c34?.toString() ?? '';
      textEditingController14.text = material.c35?.toString() ?? '';
      textEditingController15.text = material.c36?.toString() ?? '';
      textEditingController16.text = material.c44?.toString() ?? '';
      textEditingController17.text = material.c45?.toString() ?? '';
      textEditingController18.text = material.c46?.toString() ?? '';
      textEditingController19.text = material.c55?.toString() ?? '';
      textEditingController20.text = material.c56?.toString() ?? '';
      textEditingController21.text = material.c66?.toString() ?? '';
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
