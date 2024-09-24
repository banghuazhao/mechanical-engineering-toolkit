import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class MultipleRowResult extends StatelessWidget {
  final String title;
  final List<String> resultTitles;
  final List<double?> resultValues;
  const MultipleRowResult({
    Key? key,
    required this.title,
    required this.resultTitles,
    required this.resultValues,
  }) : super(key: key);

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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            height: 40 * resultTitles.length + 20,
            child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: List<Widget>.generate(
                    resultTitles.length,
                    (index) => _propertyRow(
                        context, resultTitles[index], resultValues[index]))),
          ),
        ],
      ),
    );
  }
}
