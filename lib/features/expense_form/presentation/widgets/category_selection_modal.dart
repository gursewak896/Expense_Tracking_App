import 'package:expense_app/core/contants.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:expense_app/core/widgets/transaction_cat_icon.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategorySelectionModal extends StatelessWidget {
  final CategoryItem? selectedCategory;
  final Function(CategoryItem) onCategorySelected;

  const CategorySelectionModal({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Select Category',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Category Grid (excluding "More" button)
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.builder(
                shrinkWrap: true,
                // Add extra bottom padding for shadows and safe area
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 36),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount:
                    categoryItems.where((cat) => cat.label != 'More').length,
                itemBuilder: (context, index) {
                  final allCategories = categoryItems
                      .where((cat) => cat.label != 'More')
                      .toList();
                  final category = allCategories[index];
                  final isSelected = selectedCategory?.label == category.label;

                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(category);
                      Navigator.pop(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: isSelected
                              ? BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(30),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                )
                              : null,
                          padding: const EdgeInsets.all(8),
                          child: TransactionCatIcon(
                            icon: category.icon,
                            color: category.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: isSelected
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                : (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54),
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
