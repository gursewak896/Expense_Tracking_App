import 'package:expense_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        // borderRadius: BorderRadius.circular(30),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Home", 0, context),
          _buildNavItem(Icons.bar_chart, "Stats", 1, context),
          _buildNavItem(Icons.person, "Profile", 2, context),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, int index, BuildContext context) {
    final isSelected = currentIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFEDEAFF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDarkMode ? Colors.white : AppColors.primary)
                  : (isDarkMode ? Colors.grey.shade600 : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                  textStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? (isDarkMode ? Colors.white : AppColors.primary)
                        : (isDarkMode ? Colors.grey.shade600 : Colors.grey),
                    letterSpacing: 1,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
