import 'package:expense_app/core/contants.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

/// Specifies the category classification for an expense transaction.
///
/// Use [Category.grocery] to categorize expenses related to food, groceries,
/// This ensures proper expense tracking and categorization for financial analysis.
final List<TransactionModel> transactions = [
  TransactionModel(
    title: "Rice",
    date: DateTime(2024, 6, 30),
    amount: -50,
    isIncome: false,
    category: CategoryItem(
      label: 'Food',
      icon: Icons.restaurant,
      color: const Color(0xFFFF8C42),
    ),
  ),
  TransactionModel(
    title: "Company salary",
    date: DateTime(2024, 6, 30),
    amount: 1200,
    isIncome: true,
    category: CategoryItem(
      label: 'Income',
      icon: Icons.attach_money,
      color: const Color(0xFF4CAF50),
    ),
  ),
  TransactionModel(
    title: "Bus fare",
    date: DateTime(2024, 6, 30),
    amount: -15,
    isIncome: false,
    category: CategoryItem(
      label: '  Transport',
      icon: Icons.directions_bus,
      color: const Color(0xFF2196F3),
    ),
  ),
];
