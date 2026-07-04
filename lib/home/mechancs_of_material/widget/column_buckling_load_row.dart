import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/column_buckling_load_model.dart';

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

  late TextEditingController textEditingController1;
  late TextEditingController textEditingController2;
  late TextEditingController textEditingController3;

  @override
  void initState() {
    super.initState();
    textEditingController1 = TextEditingController();
    textEditingController2 = TextEditingController();
    textEditingController3 = TextEditingController();
    _updateControllers();
  }

  @override
  void dispose() {
    textEditingController1.dispose();
    textEditingController2.dispose();
    textEditingController3.dispose();
    super.dispose();
  }

  void _updateControllers() {
    textEditingController1.text =
        widget.columnBucklingLoadModel.E?.toString() ?? '';
    textEditingController2.text =
        widget.columnBucklingLoadModel.I?.toString() ?? '';
    textEditingController3.text =
        widget.columnBucklingLoadModel.L?.toString() ?? '';
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
                      _updateControllers();
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
                  child: TextField(
                    controller: textEditingController1,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(),
                        labelText: "E",
                        errorText: widget.validate
                            ? validateModulus(widget.columnBucklingLoadModel.E)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.columnBucklingLoadModel.E = double.tryParse(value);
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
                        labelText: "I",
                        errorText: widget.validate
                            ? validateModulus(widget.columnBucklingLoadModel.I)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.columnBucklingLoadModel.I = double.tryParse(value);
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
                  child: TextField(
                    controller: textEditingController3,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(12),
                        border: const OutlineInputBorder(),
                        labelText: "L",
                        errorText: widget.validate
                            ? validateModulus(widget.columnBucklingLoadModel.L)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.columnBucklingLoadModel.L = double.tryParse(value);
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
