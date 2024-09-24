import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/area_model.dart';

class AreaRow extends StatefulWidget {
  final Area area;
  final bool validate;

  const AreaRow({Key? key, required this.area, required this.validate})
      : super(key: key);

  @override
  _AreaRowState createState() => _AreaRowState();
}

class _AreaRowState extends State<AreaRow> {
  validateLayupAngle(double? value) {
    if (value == null) {
      return S.of(context).Not_a_number;
    } else if (value <= 0) {
      return "Must > 0";
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
              S.of(context).Area,
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
                  labelText: "A (> 0)",
                  errorText: widget.validate
                      ? validateLayupAngle(widget.area.value)
                      : null),
              onChanged: (value) {
                widget.area.value = double.tryParse(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
