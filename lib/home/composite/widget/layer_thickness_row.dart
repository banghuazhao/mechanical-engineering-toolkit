import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layer_thickness.dart';

class LayerThicknessPage extends StatefulWidget {
  final LayerThickness layerThickness;
  final bool validate;

  LayerThicknessPage(
      {Key? key, required this.layerThickness, required this.validate})
      : super(key: key);

  @override
  _LayerThicknessPageState createState() => _LayerThicknessPageState();
}

class _LayerThicknessPageState extends State<LayerThicknessPage> {
  validate(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
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
        children: [
          ListTile(
            title: Text(
              S.of(context).Layer_Thickness,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(12),
                  border: const OutlineInputBorder(),
                  labelText: "Thickness",
                  errorText: widget.validate
                      ? validate(widget.layerThickness.value)
                      : null),
              onChanged: (value) {
                widget.layerThickness.value = double.tryParse(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
