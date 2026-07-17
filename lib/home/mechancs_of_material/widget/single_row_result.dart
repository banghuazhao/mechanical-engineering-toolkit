import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class SingleRowResult extends StatelessWidget {
  final String title;
  final String resultTitle;
  final double? resultValue;
  final UnitCategory? category;

  const SingleRowResult({
    super.key,
    required this.title,
    required this.resultTitle,
    required this.resultValue,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      child: AppCopyableValue(
        label: resultTitle,
        value: resultValue == null ? '' : null,
        valueSI: resultValue,
        category: category,
      ),
    );
  }
}
