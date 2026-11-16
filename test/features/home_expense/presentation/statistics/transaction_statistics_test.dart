import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:expense_app/features/home_expense/presentation/statistics/transaction_statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel _transaction({
  required String id,
  required DateTime date,
  required double amount,
  required bool isIncome,
  CategoryItem? category,
}) {
  return TransactionModel(
    id: id,
    title: id,
    amount: amount,
    date: date,
    isIncome: isIncome,
    category: category,
  );
}

void main() {
  group('TransactionStatistics', () {
    test('filters incomes and applies inclusive/exclusive month boundaries',
        () {
      final food = CategoryItem(
        label: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
      );
      final result = TransactionStatistics.calculate(
        transactions: [
          _transaction(
            id: 'first-day',
            date: DateTime(2025, 3, 1),
            amount: 20,
            isIncome: false,
            category: food,
          ),
          _transaction(
            id: 'last-day',
            date: DateTime(2025, 3, 31, 23, 59),
            amount: 30,
            isIncome: false,
            category: food,
          ),
          _transaction(
            id: 'income',
            date: DateTime(2025, 3, 15),
            amount: 500,
            isIncome: true,
          ),
          _transaction(
            id: 'before-range',
            date: DateTime(2025, 2, 28, 23, 59),
            amount: 100,
            isIncome: false,
          ),
          _transaction(
            id: 'end-exclusive',
            date: DateTime(2025, 4, 1),
            amount: 100,
            isIncome: false,
          ),
        ],
        period: StatsPeriod.month,
        referenceDate: DateTime(2025, 3, 20),
      );

      expect(result.totalExpenses, 50);
      expect(result.expenseCount, 2);
      expect(result.averageExpense, 25);
      expect(result.categories.single.label, 'Food');
      expect(result.categories.single.amount, 50);
      expect(result.buckets[0].amount, 20);
      expect(result.buckets[4].amount, 30);
    });

    test('groups week by weekday and assigns missing categories', () {
      final result = TransactionStatistics.calculate(
        transactions: [
          _transaction(
            id: 'monday',
            date: DateTime(2025, 3, 10),
            amount: 12,
            isIncome: false,
          ),
          _transaction(
            id: 'sunday',
            date: DateTime(2025, 3, 16, 23, 59),
            amount: 8,
            isIncome: false,
          ),
          _transaction(
            id: 'next-monday',
            date: DateTime(2025, 3, 17),
            amount: 100,
            isIncome: false,
          ),
        ],
        period: StatsPeriod.week,
        referenceDate: DateTime(2025, 3, 13),
      );

      expect(result.totalExpenses, 20);
      expect(result.buckets, hasLength(7));
      expect(result.buckets.first.amount, 12);
      expect(result.buckets.last.amount, 8);
      expect(result.categories.single.label, 'Uncategorized');
      expect(result.categories.single.color, const Color(0xFF9E9E9E));
    });

    test('returns zero average and empty categories when range has no expenses',
        () {
      final result = TransactionStatistics.calculate(
        transactions: [
          _transaction(
            id: 'income',
            date: DateTime(2025, 1, 15),
            amount: 100,
            isIncome: true,
          ),
        ],
        period: StatsPeriod.year,
        referenceDate: DateTime(2025, 6, 1),
      );

      expect(result.totalExpenses, 0);
      expect(result.expenseCount, 0);
      expect(result.averageExpense, 0);
      expect(result.categories, isEmpty);
      expect(result.buckets, hasLength(12));
      expect(result.buckets.every((bucket) => bucket.amount == 0), isTrue);
    });
  });
}
