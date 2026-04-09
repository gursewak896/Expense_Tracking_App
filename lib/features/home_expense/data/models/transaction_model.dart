// transaction_model.dart
import 'package:expense_app/features/home_expense/data/models/category_items.dart';

class TransactionModel {
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final CategoryItem? category; // ✅ Change from 'Category' to 'CategoryItem?'

  TransactionModel({
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.category, // ✅ Now accepts CategoryItem or null
  });
}
