// constants.dart
import 'package:expense_app/features/transactions/data/models/category_items.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum TransactionFilter { all, income, expense }

enum Category {
  food,
  transport,
  income,
  electronics,
  housing,
}

Text textFieldHeader(String text) {
  return Text(text,
      style: GoogleFonts.poppins(fontSize: 12, color: Colors.black));
}

const Color primaryColor = AppColors.primary;

// Main categories shown in horizontal list (first 4 + More button)
final List<CategoryItem> mainCategoryItems = [
  CategoryItem(
    label: 'Food',
    icon: Icons.restaurant,
    color: const Color(0xFFFF8C42),
  ),
  CategoryItem(
    label: 'Shopping',
    icon: Icons.shopping_bag_outlined,
    color: AppColors.primary,
  ),
  CategoryItem(
    label: 'Transport',
    icon: Icons.directions_car_outlined,
    color: const Color(0xFF4B9EF5),
  ),
  CategoryItem(
    label: 'Health',
    icon: Icons.medical_services_outlined,
    color: const Color(0xFFEF4B4B),
  ),
  CategoryItem(
    label: 'Housing',
    icon: Icons.home_outlined,
    color: const Color(0xFF8B6F47),
  ),
  CategoryItem(
    label: 'More',
    icon: Icons.grid_view_rounded,
    color: const Color(0xFF9B6BF5),
  ),
];

// Additional categories shown in bottom sheet modal
final List<CategoryItem> additionalCategoryItems = [
  // CategoryItem(
  //   label: 'Housing',
  //   icon: Icons.home_outlined,
  //   color: const Color(0xFF8B6F47),
  // ),
  CategoryItem(
    label: 'Utilities',
    icon: Icons.electric_bolt_outlined,
    color: const Color(0xFFFFC107),
  ),
  CategoryItem(
    label: 'Education',
    icon: Icons.school_outlined,
    color: const Color(0xFF6366F1),
  ),
  CategoryItem(
    label: 'Entertainment',
    icon: Icons.movie_outlined,
    color: const Color(0xFFEC407A),
  ),
  CategoryItem(
    label: 'Personal',
    icon: Icons.person_outline,
    color: const Color(0xFF29B6F6),
  ),
  CategoryItem(
    label: 'Others',
    icon: Icons.category_outlined,
    color: const Color(0xFF78909C),
  ),
];

// All categories combined
final List<CategoryItem> categoryItems = [
  ...mainCategoryItems,
  ...additionalCategoryItems,
];

// Helper function: Convert CategoryItem (UI) to Category (enum)
Category categoryItemToEnum(CategoryItem item) {
  switch (item.label.toLowerCase()) {
    case 'food':
      return Category.food;
    case 'shopping':
      return Category.electronics; // or keep as shopping
    case 'transport':
      return Category.transport;
    case 'health':
      return Category.housing; // map health to housing
    case 'more':
      return Category.electronics;
    default:
      return Category.food;
  }
}

// Helper function: Convert Category (enum) to CategoryItem (UI)
CategoryItem categoryEnumToItem(Category category) {
  switch (category) {
    case Category.food:
      return categoryItems.firstWhere((item) => item.label == 'Food');
    case Category.transport:
      return categoryItems.firstWhere((item) => item.label == 'Transport');
    case Category.income:
      return CategoryItem(
        label: 'Income',
        icon: Icons.attach_money,
        color: Colors.green,
      );
    case Category.electronics:
      return categoryItems.firstWhere((item) => item.label == 'Shopping');
    case Category.housing:
      return categoryItems.firstWhere((item) => item.label == 'Health');
  }
}

extension CategoryExtension on Category {
  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.transport:
        return Icons.directions_car;
      case Category.income:
        return Icons.attach_money;
      case Category.electronics:
        return Icons.shopping_bag;
      case Category.housing:
        return Icons.home;
    }
  }

  Color get bgColor {
    switch (this) {
      case Category.food:
        return Colors.orangeAccent.withValues(alpha: 0.8);
      case Category.transport:
        return Colors.blueAccent.withValues(alpha: 0.8);
      case Category.income:
        return Colors.greenAccent.withValues(alpha: 0.8);
      case Category.electronics:
        return const Color(0xFFEDE1FF);
      case Category.housing:
        return const Color(0xFFDCE2F7);
    }
  }

  String get label {
    switch (this) {
      case Category.food:
        return "Food & Dining";
      case Category.transport:
        return "Transport";
      case Category.income:
        return "Income";
      case Category.electronics:
        return "Electronics";
      case Category.housing:
        return "Housing";
    }
  }
}
