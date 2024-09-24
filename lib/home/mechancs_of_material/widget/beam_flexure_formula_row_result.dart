import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class BeamFlexureFormulaRowResult extends StatelessWidget {
  final String resultFormula;
  final double? resultValue;
  const BeamFlexureFormulaRowResult({
    Key? key,
    required this.resultFormula,
    required this.resultValue,
  }) : super(key: key);

  _propertyFormulaRow(BuildContext context, String title, String value) {
    return SizedBox(
      height: 40,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyText1,
        )
      ]),
    );
  }

  _propertyRow(BuildContext context, String title, double? value) {
    return Consumer<NumberPrecisionHelper>(builder: (context, precs, child) {
      return SizedBox(
        height: 40,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            title,
            style: Theme.of(context).textTheme.subtitle1,
          ),
          Text(
            getValue(value, precs.precision),
            style: Theme.of(context).textTheme.bodyText1,
          )
        ]),
      );
    });
  }

  String getValue(double? value, int precision) {
    String valueString = "";
    if (value != null) {
      valueString =
          value == 0 ? "0" : value.toStringAsExponential(precision).toString();
    }
    return valueString;
  }

  @override
  Widget build(BuildContext context) {
    int row = 1;
    if (resultValue != null) {
      row += 1;
    }
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              S.of(context).Stress,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 40 * row + 20,
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _propertyFormulaRow(context, "σx Formula", resultFormula),
                resultValue != null
                    ? _propertyRow(context, "σx Value", resultValue)
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
