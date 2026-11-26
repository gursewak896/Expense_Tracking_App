import 'package:expense_app/core/contants.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:expense_app/features/transactions/presentation/widgets/transaction_cat_icon.dart';
import 'package:expense_app/features/transactions/presentation/widgets/category_selection_modal.dart';
import 'package:expense_app/features/transactions/data/models/category_items.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryCard extends StatefulWidget {
  const CategoryCard({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  final Function(CategoryItem) onCategorySelected;
  final CategoryItem? selectedCategory;

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  int _selectedCategoryIndex = 1;
  // ✅ Use mainCategoryItems from constants.dart
  final List<CategoryItem> _categories = mainCategoryItems;
  CategoryItem? _currentSelectedCategory;

  @override
  void initState() {
    super.initState();

    final matchedIndex = _categories.indexWhere(
      (category) => category.label == widget.selectedCategory?.label,
    );

    if (matchedIndex != -1) {
      _selectedCategoryIndex = matchedIndex;
      _currentSelectedCategory = _categories[_selectedCategoryIndex];
    } else if (widget.selectedCategory != null) {
      // If selected category is not in main list, highlight the "More" button
      final moreIndex = _categories.indexWhere((c) => c.label == 'More');
      _selectedCategoryIndex = moreIndex != -1 ? moreIndex : 0;
      _currentSelectedCategory = widget.selectedCategory;
    }

    // Send initial selected category after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onCategorySelected(
          _currentSelectedCategory ?? _categories[_selectedCategoryIndex],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category',
                style: GoogleFonts.poppins(
                  color: Theme.of(context).textTheme.titleMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => CategorySelectionModal(
                      selectedCategory: _currentSelectedCategory ??
                          _categories[_selectedCategoryIndex],
                      onCategorySelected: (CategoryItem category) {
                        setState(() {
                          final index = mainCategoryItems.indexWhere(
                            (cat) => cat.label == category.label,
                          );
                          // If category is in main list, select it. Otherwise, highlight "More"
                          final moreIndex = mainCategoryItems
                              .indexWhere((c) => c.label == 'More');
                          _selectedCategoryIndex = index != -1
                              ? index
                              : (moreIndex != -1 ? moreIndex : 0);
                          _currentSelectedCategory = category;
                        });
                        widget.onCategorySelected(category);
                      },
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
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
                final isMoreButton = cat.label == 'More';

                return GestureDetector(
                  onTap: () {
                    if (isMoreButton) {
                      // Open bottom sheet when "More" is tapped
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => CategorySelectionModal(
                          selectedCategory: _currentSelectedCategory ??
                              _categories[_selectedCategoryIndex],
                          onCategorySelected: (CategoryItem category) {
                            setState(() {
                              final idx = mainCategoryItems.indexWhere(
                                (cat) => cat.label == category.label,
                              );
                              // If category is in main list, select it. Otherwise, highlight "More"
                              final moreIndex = mainCategoryItems
                                  .indexWhere((c) => c.label == 'More');
                              _selectedCategoryIndex = idx != -1
                                  ? idx
                                  : (moreIndex != -1 ? moreIndex : 0);
                              _currentSelectedCategory = category;
                            });
                            widget.onCategorySelected(category);
                          },
                        ),
                      );
                    } else {
                      // Normal category selection
                      setState(() {
                        _selectedCategoryIndex = index;
                        _currentSelectedCategory = _categories[index];
                      });
                      widget.onCategorySelected(_categories[index]);
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.primary,
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
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54),
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
