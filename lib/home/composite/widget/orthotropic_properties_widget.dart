import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class OrthotropicPropertiesWidget extends StatelessWidget {
  final String title;
  final OrthotropicMaterial orthotropicMaterial;
  const OrthotropicPropertiesWidget(
      {Key? key, required this.title, required this.orthotropicMaterial})
      : super(key: key);

  _propertyRow(BuildContext context, String title, double? valueSI,
      [UnitCategory? category]) {
    return Consumer<NumberPrecisionHelper>(builder: (context, precs, child) {
      final system = context.watch<UnitSystemPreference>().system;
      final displayValue =
          valueSI == null || category == null
              ? valueSI
              : fromSI(valueSI, category, system);
      final label = category == null
          ? title
          : '$title (${unitLabel(category, system)})';
      return SizedBox(
        height: 40,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            precs.formatValue(displayValue),
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ]),
      );
    });
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
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 40 * 9 + 20,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _propertyRow(context, "E1", orthotropicMaterial.e1,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "E2", orthotropicMaterial.e2,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "E3", orthotropicMaterial.e3,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "G12", orthotropicMaterial.g12,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "G13", orthotropicMaterial.g13,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "G23", orthotropicMaterial.g23,
                    UnitCategory.modulus),
                const Divider(height: 1),
                _propertyRow(context, "ν12", orthotropicMaterial.nu12),
                const Divider(height: 1),
                _propertyRow(context, "ν13", orthotropicMaterial.nu13),
                const Divider(height: 1),
                _propertyRow(context, "ν23", orthotropicMaterial.nu23),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
