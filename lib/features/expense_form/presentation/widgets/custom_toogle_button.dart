import 'package:expense_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomToogleButton extends StatelessWidget {
  final String label1;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  const CustomToogleButton({
    super.key,
    required this.label1,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    // required this.activeColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary
            : (Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2C2C2C)
                : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white60
                    : Colors.black54),
            size: 18,
          ),
          const SizedBox(width: 4),
          Text(
            label1,
            style: TextStyle(
              color: isSelected
                  ? Colors.white
                  : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : Colors.black54),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
