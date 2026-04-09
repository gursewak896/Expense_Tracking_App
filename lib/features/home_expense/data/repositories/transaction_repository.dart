import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

class TransactionRepository {
  static List<TransactionModel> getTransactions() {
    return [
      TransactionModel(
        title: "Artisan Kitchen",
        date: DateTime(2024, 6, 30),
        amount: -42.50,
        isIncome: false,
        category: CategoryItem(
          // ✅ Use CategoryItem
          label: 'Food',
          icon: Icons.restaurant,
          color: const Color(0xFFFF8C42),
        ),
      ),
      TransactionModel(
        title: "Monthly Salary",
        date: DateTime(2024, 6, 30),
        amount: 4250,
        isIncome: true,
        category: null, // ✅ Income has no category
      ),
      TransactionModel(
        title: "Rice",
        date: DateTime(2024, 6, 30),
        amount: -50,
        isIncome: false,
        category: CategoryItem(
          // ✅ Use CategoryItem
          label: 'Food',
          icon: Icons.restaurant,
          color: const Color(0xFFFF8C42),
        ),
      ),
      TransactionModel(
        title: "Bus fare",
        date: DateTime(2024, 6, 30),
        amount: -15,
        isIncome: false,
        category: CategoryItem(
          // ✅ Use CategoryItem
          label: 'Transport',
          icon: Icons.directions_car_outlined,
          color: const Color(0xFF4B9EF5),
        ),
      ),
    ];
  }
}
