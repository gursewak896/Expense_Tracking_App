import 'package:expense_app/core/contants.dart';
import 'package:expense_app/core/widgets/transaction_cat_icon.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({super.key, required this.onCategorySelected});
  final Function(CategoryItem) onCategorySelected;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  int _selectedCategoryIndex = 1;

  // ✅ Use categoryItems from constants.dart
  final List<CategoryItem> _categories = categoryItems;

  @override
  void initState() {
    super.initState();
    // Send initial selected category after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onCategorySelected(
            _categories[_selectedCategoryIndex]); // ✅ Sends CategoryItem
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4B3EF5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                    widget.onCategorySelected(
                        _categories[index]); // ✅ Sends CategoryItem
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFF4B3EF5),
                                  width: 1.5,
                                ),
                              )
                            : null,
                        child: TransactionCatIcon(
                          icon: cat.icon,
                          color: cat.color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat.label,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF4B3EF5)
                              : Colors.black54,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
