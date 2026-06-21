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
    return InkWell(
      onTap: onTap,
      child: ListTile(
        leading: Icon(leadingIcon),
        trailing: Icon(trailingIcon),
        title: Text(
          title,
        ),
      ),
    );
  }
}
