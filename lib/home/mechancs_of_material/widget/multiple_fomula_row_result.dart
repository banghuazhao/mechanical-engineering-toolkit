import 'package:flutter/material.dart';

class MultipleFormulaRowResult extends StatelessWidget {
  final String title;
  final List<String> resultTitles;
  final List<String> resultValues;
  const MultipleFormulaRowResult({
    Key? key,
    required this.title,
    required this.resultTitles,
    required this.resultValues,
  }) : super(key: key);

  _propertyRow(BuildContext context, String title, String value) {
    return SizedBox(
      height: 50,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        )
      ]),
    );
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
            height: 50 * resultTitles.length + 20,
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
