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
        color: const Color(0xFF3A2EDB),
      ),
      trailing: Switch(
        splashRadius: 4,
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF3A2EDB),
      ),
    );
  }
}
