import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/angle_model.dart';

class LayupAngleRow extends StatefulWidget {
  final LayupAngle layupAngle;
  final String title;
  final String placeHolder;
  final bool validate;

  const LayupAngleRow(
      {Key? key,
      required this.layupAngle,
      required this.validate,
      this.title = "Layup Angle",
      this.placeHolder = "Angle"})
      : super(key: key);

  @override
  _LayupAngleRowState createState() => _LayupAngleRowState();
}

class _LayupAngleRowState extends State<LayupAngleRow> {
  validateLayupAngle(double? value) {
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
              widget.title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: widget.placeHolder,
                  errorText: widget.validate
                      ? validateLayupAngle(widget.layupAngle.value)
                      : null),
              onChanged: (value) {
                widget.layupAngle.value = double.tryParse(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
