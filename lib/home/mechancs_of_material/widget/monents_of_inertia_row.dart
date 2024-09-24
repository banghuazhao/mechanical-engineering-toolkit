import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/cross_section_model.dart';

class MonentsOfInertiaRow extends StatefulWidget {
  final CrossSectionModel crossSectionModel;
  final bool validate;
  final Function(String) callback;

  const MonentsOfInertiaRow(
      {Key? key,
      required this.crossSectionModel,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _MonentsOfInertiaRowState createState() => _MonentsOfInertiaRowState();
}

class _MonentsOfInertiaRowState extends State<MonentsOfInertiaRow> {
  String dropValue = "Rectangle (Origin of axes at centroid)";

  TextEditingController textEditingController1 = TextEditingController();
  TextEditingController textEditingController2 = TextEditingController();
  TextEditingController textEditingController3 = TextEditingController();

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
                      textEditingController1.clear();
                      textEditingController2.clear();
                    });
                  },
                  items: <String>[
                    "Rectangle (Origin of axes at centroid)",
                    "Rectangle (Origin at corner)",
                    "Isosceles triangle (Origin at centroid)",
                    "Right triangle (Origin at centroid)",
                    "Circle (Origin at center)",
                    "Semicircle (Origin at centroid)"
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
                        labelText: (dropValue == "Circle (Origin at center)" ||
                                dropValue == "Semicircle (Origin at centroid)")
                            ? "r"
                            : "b",
                        errorText: widget.validate
                            ? validateModulus(
                                (dropValue == "Circle (Origin at center)" ||
                                        dropValue ==
                                            "Semicircle (Origin at centroid)")
                                    ? (widget.crossSectionModel
                                            as CrossSectionRModel)
                                        .r
                                    : (widget.crossSectionModel
                                            as CrossSectionBHModel)
                                        .b)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      if (dropValue == "Circle (Origin at center)" ||
                          dropValue == "Semicircle (Origin at centroid)") {
                        (widget.crossSectionModel as CrossSectionRModel).r =
                            double.tryParse(value);
                      } else {
                        (widget.crossSectionModel as CrossSectionBHModel).b =
                            double.tryParse(value);
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: (dropValue == "Circle (Origin at center)" ||
                          dropValue == "Semicircle (Origin at centroid)")
                      ? Container()
                      : TextField(
                          controller: textEditingController2,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "h",
                              errorText: widget.validate
                                  ? validateModulus((widget.crossSectionModel
                                          as CrossSectionBHModel)
                                      .h)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            (widget.crossSectionModel as CrossSectionBHModel)
                                .h = double.tryParse(value);
                          },
                        ),
                ),
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
    AssetImage image = AssetImage("images/cross_section/icon_cs_rectangle.png");
    if (dropValue == "Rectangle (Origin of axes at centroid)") {
      image = AssetImage("images/cross_section/icon_cs_rectangle.png");
    } else if (dropValue == "Rectangle (Origin at corner)") {
      image = AssetImage("images/cross_section/icon_cs_rectangle_corner.png");
    } else if (dropValue == "Isosceles triangle (Origin at centroid)") {
      image = AssetImage("images/cross_section/icon_cs_isosceles_triangle.png");
    } else if (dropValue == "Right triangle (Origin at centroid)") {
      image = AssetImage("images/cross_section/icon_cs_right_triangle.png");
    } else if (dropValue == "Circle (Origin at center)") {
      image = AssetImage("images/cross_section/icon_cs_circle.png");
    } else if (dropValue == "Semicircle (Origin at centroid)") {
      image = AssetImage("images/cross_section/icon_cs_semicircle.png");
    }
    return Image(
      height: 150,
      image: image,
      fit: BoxFit.fitHeight,
    );
  }
}
