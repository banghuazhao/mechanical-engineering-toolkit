import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';

class DescriptionItem extends StatelessWidget {
  final Widget content;

  const DescriptionItem({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(title: S.of(context).Description, child: content);
  }
}
