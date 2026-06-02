import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:flutter/material.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final CategoryItem? category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.category,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    bool? isIncome,
    CategoryItem? category,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
    );
  }

  // ✅ Convert TransactionModel to JSON (for Firestore/API)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'categoryLabel': category?.label,
      'categoryIconCodePoint': category?.icon.codePoint,
      'categoryColorValue': category?.color.toARGB32(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome,
      'categoryLabel': category?.label,
      'categoryIconCodePoint': category?.icon.codePoint,
      'categoryColorValue': category?.color.toARGB32(),
    };
  }

  // ✅ Create TransactionModel from JSON (from Firestore/API)
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    CategoryItem? category;

    if (json['categoryLabel'] != null &&
        json['categoryIconCodePoint'] != null &&
        json['categoryColorValue'] != null) {
      category = CategoryItem(
        label: json['categoryLabel'],
        icon: IconData(
          // ignore: non_const_argument_for_const_parameter
          json['categoryIconCodePoint'],
          fontFamily: 'MaterialIcons',
        ),
        color: Color(json['categoryColorValue']),
      );
    }

    return TransactionModel(
      id: json['id'] ?? '',
      title: json['title'],
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      isIncome: json['isIncome'] ?? false,
      category: category,
    );
  }
}
