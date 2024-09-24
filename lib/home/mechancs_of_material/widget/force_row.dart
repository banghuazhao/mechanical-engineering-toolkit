import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/force_model.dart';

class ForceRow extends StatefulWidget {
  final Force force;
  final bool validate;

  const ForceRow({Key? key, required this.force, required this.validate})
      : super(key: key);

  @override
  _ForceRowState createState() => _ForceRowState();
}

class _ForceRowState extends State<ForceRow> {
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
              S.of(context).Force,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: TextField(
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(12),
                  border: OutlineInputBorder(),
                  labelText: "F",
                  errorText: widget.validate
                      ? validateLayupAngle(widget.force.value)
                      : null),
              onChanged: (value) {
                widget.force.value = double.tryParse(value);
              },
            ),
          )
        ],
      ),
    );
  }
}
