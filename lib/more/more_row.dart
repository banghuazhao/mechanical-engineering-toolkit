import 'package:flutter/material.dart';

class MoreRow extends StatelessWidget {
  final IconData leadingIcon;
  final IconData trailingIcon;
  final String title;
  final void Function() onTap;

  const MoreRow({
    Key? key,
    this.trailingIcon = Icons.chevron_right_rounded,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leadingIcon, color: primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            Icon(trailingIcon, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
