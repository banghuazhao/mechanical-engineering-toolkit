import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/force_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

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
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: UnitField(
              label: "F",
              category: UnitCategory.force,
              initialSI: widget.force.value,
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
              border: const OutlineInputBorder(),
              errorText: (value) =>
                  widget.validate ? validateLayupAngle(value) : null,
              onChangedSI: (value) {
                widget.force.value = value;
              },
            ),
          )
        ],
      ),
    );
  }
}
