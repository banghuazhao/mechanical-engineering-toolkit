import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/area_model.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

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
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: UnitField(
              label: "A (> 0)",
              category: UnitCategory.area,
              initialSI: widget.area.value,
              signed: false,
              isDense: true,
              contentPadding: const EdgeInsets.all(12),
              border: const OutlineInputBorder(),
              errorText: (value) =>
                  widget.validate ? validateLayupAngle(value) : null,
              onChangedSI: (value) {
                widget.area.value = value;
              },
            ),
          )
        ],
      ),
    );
  }
}
