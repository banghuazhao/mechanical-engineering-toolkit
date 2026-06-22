import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

class DescriptionItem extends StatelessWidget {
  final Widget content;

  const DescriptionItem({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                S.of(context).Description.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xffA8866B),
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const Divider(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: content,
            )
          ],
        ));
  }
}
