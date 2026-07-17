import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_deflection_slope_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class CantileverBeamDeflectionsSlopesRow extends StatefulWidget {
  final BeamDeflectionSlope beamDeflectionSlope;
  final bool validate;
  final Function(String) callback;

  const CantileverBeamDeflectionsSlopesRow(
      {Key? key,
      required this.beamDeflectionSlope,
      required this.validate,
      required this.callback})
      : super(key: key);

  @override
  _MonentsOfInertiaRowState createState() => _MonentsOfInertiaRowState();
}

class _MonentsOfInertiaRowState
    extends State<CantileverBeamDeflectionsSlopesRow> {
  String dropValue = "Point force at end";

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

  // "f" holds P (point force), q (distributed load), or M (moment)
  // depending on the selected loading type — each needs a different unit
  // category to stay dimensionally consistent with E (MPa), I (mm⁴) and
  // L (mm).
  UnitCategory get _forceCategory {
    if (dropValue == "Distributed force evenly" ||
        dropValue == "Distributed force") {
      return UnitCategory.distributedLoadSmall;
    } else if (dropValue == "Moment at end" || dropValue == "Moment") {
      return UnitCategory.momentSection;
    }
    return UnitCategory.force;
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
                    "Point force at end",
                    "Point force",
                    "Distributed force evenly",
                    "Distributed force",
                    "Moment at end",
                    "Moment"
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
                    initialSI: widget.beamDeflectionSlope.E,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.beamDeflectionSlope.E = value;
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
                    initialSI: widget.beamDeflectionSlope.I,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.beamDeflectionSlope.I = value;
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
                    initialSI: widget.beamDeflectionSlope.L,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateModulus(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.beamDeflectionSlope.L = value;
                    },
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: UnitField(
                    key: ValueKey('f-$dropValue'),
                    label: forceText(),
                    category: _forceCategory,
                    initialSI: widget.beamDeflectionSlope.f,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    errorText: (value) =>
                        widget.validate ? validateForce(value) : null,
                    errorStyle: const TextStyle(fontSize: 10),
                    onChangedSI: (value) {
                      widget.beamDeflectionSlope.f = value;
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
                        child: UnitField(
                          key: ValueKey('a-$dropValue'),
                          label: "a (0<=a<=L)",
                          category: UnitCategory.length,
                          initialSI: (widget.beamDeflectionSlope
                                  as BeamDeflectionSlopeABModel)
                              .a,
                          signed: false,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => widget.validate
                              ? validatePositive(value)
                              : null,
                          errorStyle: const TextStyle(fontSize: 10),
                          onChangedSI: (value) {
                            (widget.beamDeflectionSlope
                                    as BeamDeflectionSlopeABModel)
                                .a = value;
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
    if (dropValue == "Point force at end") {
      forceText = "P";
    } else if (dropValue == "Point force") {
      forceText = "P";
    } else if (dropValue == "Distributed force evenly") {
      forceText = "q";
    } else if (dropValue == "Distributed force") {
      forceText = "q";
    } else if (dropValue == "Moment at end") {
      forceText = "M";
    } else if (dropValue == "Moment") {
      forceText = "M";
    }
    return forceText;
  }

  Image buildCrossSectionImage() {
    AssetImage image = AssetImage(
        "images/cantilever_beam/icon_cantilever_beam_point_force_end.png");
    if (dropValue == "Point force at end") {
      image = AssetImage(
          "images/cantilever_beam/icon_cantilever_beam_point_force_end.png");
    } else if (dropValue == "Point force") {
      image = AssetImage(
          "images/cantilever_beam/icon_cantilever_beam_point_force.png");
    } else if (dropValue == "Distributed force evenly") {
      image = AssetImage(
          "images/cantilever_beam/icon_cantilever_beam_distributed_force_full.png");
    } else if (dropValue == "Distributed force") {
      image = AssetImage(
          "images/cantilever_beam/icon_cantilever_beam_distributed_force.png");
    } else if (dropValue == "Moment at end") {
      image = AssetImage(
          "images/cantilever_beam/icon_cantilever_beam_moment_end.png");
    } else if (dropValue == "Moment") {
      image =
          AssetImage("images/cantilever_beam/icon_cantilever_beam_moment.png");
    }
    return Image(
      height: 150,
      image: image,
      fit: BoxFit.fitHeight,
    );
  }
}
