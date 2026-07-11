import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

class SingleRowResult extends StatelessWidget {
  final String title;
  final String resultTitle;
  final double? resultValue;

  const SingleRowResult({
    super.key,
    required this.title,
    required this.resultTitle,
    required this.resultValue,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      child: Consumer<NumberPrecisionHelper>(
        builder: (context, precs, child) {
          final valueStr = precs.formatValue(resultValue);
          return AppCopyableValue(
            label: resultTitle,
            value: valueStr,
          );
        },
      ),
    );
  }
}
