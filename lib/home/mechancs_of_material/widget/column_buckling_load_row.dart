import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/column_buckling_load_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class ColumnBucklingLoadRow extends StatefulWidget {
  final ColumnBucklingLoadModel columnBucklingLoadModel;
  final bool validate;
  final Function(String) callback;

  const ColumnBucklingLoadRow(
      {Key? key,
      required this.columnBucklingLoadModel,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _ColumnBucklingLoadRowState createState() => _ColumnBucklingLoadRowState();
}

class _ColumnBucklingLoadRowState extends State<ColumnBucklingLoadRow> {
  String dropValue = "Pinned-pinned column";

  validateModulus(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0) {
      return "Not > 0";
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
                    });
                  },
                  items: <String>[
                    "Pinned-pinned column",
                    "Fixed-free column",
                    "Fixed-fixed column",
                    "Fixed-pinned column",
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: buildCrossSectionImage()),
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
                    key: ValueKey('E-$dropValue'),
                    label: "E",
                    category: UnitCategory.stress,
                    initialSI: widget.columnBucklingLoadModel.E,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.columnBucklingLoadModel.E = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: UnitField(
                    key: ValueKey('I-$dropValue'),
                    label: "I",
                    category: UnitCategory.momentOfInertia,
                    initialSI: widget.columnBucklingLoadModel.I,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.columnBucklingLoadModel.I = value;
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: UnitField(
                    key: ValueKey('L-$dropValue'),
                    label: "L",
                    category: UnitCategory.length,
                    initialSI: widget.columnBucklingLoadModel.L,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.columnBucklingLoadModel.L = value;
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
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Image buildCrossSectionImage() {
    AssetImage image =
        AssetImage("images/buckling/icon_buckling_pinned_pinned.png");
    if (dropValue == "Pinned-pinned column") {
      image = AssetImage("images/buckling/icon_buckling_pinned_pinned.png");
    } else if (dropValue == "Fixed-free column") {
      image = AssetImage("images/buckling/icon_buckling_fixed_free.png");
    } else if (dropValue == "Fixed-fixed column") {
      image = AssetImage("images/buckling/icon_buckling_fixed_fixed.png");
    } else if (dropValue == "Fixed-pinned column") {
      image = AssetImage("images/buckling/icon_buckling_fixed_pinned.png");
    }
    return Image(
      height: 150,
      image: image,
      fit: BoxFit.fitHeight,
    );
  }
}
