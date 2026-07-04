import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_deflection_slope_model.dart';

class SimpleBeamDeflectionsSlopesRow extends StatefulWidget {
  final BeamDeflectionSlope beamDeflectionSlope;
  final bool validate;
  final Function(String) callback;

  const SimpleBeamDeflectionsSlopesRow(
      {Key? key,
      required this.beamDeflectionSlope,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _MonentsOfInertiaRowState createState() => _MonentsOfInertiaRowState();
}

class _MonentsOfInertiaRowState extends State<SimpleBeamDeflectionsSlopesRow> {
  String dropValue = "Point force at middle";

  late TextEditingController textEditingController1;
  late TextEditingController textEditingController2;
  late TextEditingController textEditingController3;
  late TextEditingController textEditingController4;
  late TextEditingController textEditingController5;

  @override
  void initState() {
    super.initState();
    textEditingController1 = TextEditingController();
    textEditingController2 = TextEditingController();
    textEditingController3 = TextEditingController();
    textEditingController4 = TextEditingController();
    textEditingController5 = TextEditingController();
    _updateControllers();
  }

  @override
  void dispose() {
    textEditingController1.dispose();
    textEditingController2.dispose();
    textEditingController3.dispose();
    textEditingController4.dispose();
    textEditingController5.dispose();
    super.dispose();
  }

  void _updateControllers() {
    textEditingController1.text = widget.beamDeflectionSlope.E?.toString() ?? '';
    textEditingController2.text = widget.beamDeflectionSlope.I?.toString() ?? '';
    textEditingController3.text = widget.beamDeflectionSlope.L?.toString() ?? '';
    textEditingController4.text = widget.beamDeflectionSlope.f?.toString() ?? '';
    if (widget.beamDeflectionSlope is BeamDeflectionSlopeABModel) {
      textEditingController5.text =
          (widget.beamDeflectionSlope as BeamDeflectionSlopeABModel)
                  .a
                  ?.toString() ??
              '';
    }
  }

  validateForce(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else {
      return null;
    }
  }

  validatePositive(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value < 0) {
      return "Not >= 0";
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
                    "Point force at middle",
                    "Distributed force evenly",
                    "Moment at middle",
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
                            ? validateModulus(widget.beamDeflectionSlope.E)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.beamDeflectionSlope.E = double.tryParse(value);
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
                            ? validateModulus(widget.beamDeflectionSlope.I)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.beamDeflectionSlope.I = double.tryParse(value);
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
                            ? validateModulus(widget.beamDeflectionSlope.L)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.beamDeflectionSlope.L = double.tryParse(value);
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
                        labelText: forceText(),
                        errorText: widget.validate
                            ? validateForce(widget.beamDeflectionSlope.f)
                            : null,
                        errorStyle: const TextStyle(fontSize: 10)),
                    onChanged: (value) {
                      widget.beamDeflectionSlope.f = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          (widget.beamDeflectionSlope is BeamDeflectionSlopeABModel)
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textEditingController5,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: "a (0<=a<=L)",
                              errorText: widget.validate
                                  ? validatePositive((widget.beamDeflectionSlope
                                          as BeamDeflectionSlopeABModel)
                                      .a)
                                  : null,
                              errorStyle: const TextStyle(fontSize: 10)),
                          onChanged: (value) {
                            (widget.beamDeflectionSlope
                                    as BeamDeflectionSlopeABModel)
                                .a = double.tryParse(value);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(child: Container()),
                    ],
                  ),
                )
              : Container(),
          (widget.beamDeflectionSlope is BeamDeflectionSlopeABModel)
              ? const SizedBox(
                  height: 12,
                )
              : Container(),
        ],
      ),
    );
  }

  String forceText() {
    String forceText = "P";
    if (dropValue == "Point force at middle") {
      forceText = "P";
    } else if (dropValue == "Distributed force evenly") {
      forceText = "q";
    } else if (dropValue == "Moment at end") {
      forceText = "M";
    }
    return forceText;
  }

  Image buildCrossSectionImage() {
    AssetImage image = AssetImage(
        "images/simple_beam/icon_simple_beam_point_force_middle.png");
    if (dropValue == "Point force at middle") {
      image = AssetImage(
          "images/simple_beam/icon_simple_beam_point_force_middle.png");
    } else if (dropValue == "Distributed force evenly") {
      image = AssetImage(
          "images/simple_beam/icon_simple_beam_distributed_force_evenly.png");
    } else if (dropValue == "Moment at middle") {
      image =
          AssetImage("images/simple_beam/icon_simple_beam_moment_middle.png");
    }
    return Image(
      height: 150,
      image: image,
      fit: BoxFit.fitHeight,
    );
  }
}
