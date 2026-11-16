import 'package:expense_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile(
      {super.key,
      required this.title,
      required this.darkMode,
      required this.icon,
      required this.value,
      required this.onChanged});
  final Text? title;
  final bool darkMode;
  final IconData? icon;
  final bool value;
  final Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: title,
      // Only icon is tappable
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      trailing: Switch(
        splashRadius: 4,
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
