import 'package:expense_app/features/transactions/data/models/transaction_model.dart';
import 'package:flutter/material.dart';

enum StatsPeriod { week, month, year }

class StatsDateRange {
  const StatsDateRange({
    required this.start,
    required this.endExclusive,
  });

  final DateTime start;
  final DateTime endExclusive;

  factory StatsDateRange.forPeriod(StatsPeriod period, DateTime referenceDate) {
    final date = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    switch (period) {
      case StatsPeriod.week:
        final start =
            DateTime(date.year, date.month, date.day - date.weekday + 1);
        return StatsDateRange(
          start: start,
          endExclusive: DateTime(start.year, start.month, start.day + 7),
        );
      case StatsPeriod.month:
        final start = DateTime(date.year, date.month);
        return StatsDateRange(
          start: start,
          endExclusive: DateTime(date.year, date.month + 1),
        );
      case StatsPeriod.year:
        return StatsDateRange(
          start: DateTime(date.year),
          endExclusive: DateTime(date.year + 1),
        );
    }
  }
}

class ExpenseBucket {
  const ExpenseBucket({
    required this.label,
    required this.amount,
  });

  final String label;
  final double amount;
}

class CategoryExpense {
  const CategoryExpense({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
}

class TransactionStatistics {
  const TransactionStatistics({
    required this.period,
    required this.range,
    required this.totalExpenses,
    required this.expenseCount,
    required this.averageExpense,
    required this.buckets,
    required this.categories,
  });

  final StatsPeriod period;
  final StatsDateRange range;
  final double totalExpenses;
  final int expenseCount;
  final double averageExpense;
  final List<ExpenseBucket> buckets;
  final List<CategoryExpense> categories;

  factory TransactionStatistics.calculate({
    required List<TransactionModel> transactions,
    required StatsPeriod period,
    required DateTime referenceDate,
  }) {
    final range = StatsDateRange.forPeriod(period, referenceDate);
    final buckets = _createBuckets(period);
    final bucketAmounts = List<double>.filled(buckets.length, 0);
    final categoryAmounts = <String, double>{};
    final categoryColors = <String, Color>{};
    final categoryIcons = <String, IconData>{};
    var totalExpenses = 0.0;
    var expenseCount = 0;

    for (final transaction in transactions) {
      final localDate = transaction.date.toLocal();
      if (transaction.isIncome ||
          localDate.isBefore(range.start) ||
          !localDate.isBefore(range.endExclusive)) {
        continue;
      }

      totalExpenses += transaction.amount;
      expenseCount++;

      final bucketIndex = _bucketIndex(period, localDate, range.start);
      bucketAmounts[bucketIndex] += transaction.amount;

      final category = transaction.category;
      final label = category?.label ?? 'Uncategorized';
      categoryAmounts.update(
        label,
        (amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      categoryColors.putIfAbsent(
        label,
        () => category?.color ?? const Color(0xFF9E9E9E),
      );
      categoryIcons.putIfAbsent(
        label,
        () => category?.icon ?? Icons.category_outlined,
      );
    }

    final categoryExpenses = categoryAmounts.entries
        .map(
          (entry) => CategoryExpense(
            label: entry.key,
            amount: entry.value,
            color: categoryColors[entry.key]!,
            icon: categoryIcons[entry.key]!,
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return TransactionStatistics(
      period: period,
      range: range,
      totalExpenses: totalExpenses,
      expenseCount: expenseCount,
      averageExpense: expenseCount == 0 ? 0 : totalExpenses / expenseCount,
      buckets: [
        for (var index = 0; index < buckets.length; index++)
          ExpenseBucket(
            label: buckets[index].label,
            amount: bucketAmounts[index],
          ),
      ],
      categories: categoryExpenses,
    );
  }
}

List<ExpenseBucket> _createBuckets(StatsPeriod period) {
  switch (period) {
    case StatsPeriod.week:
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return labels
          .map((label) => ExpenseBucket(label: label, amount: 0))
          .toList();
    case StatsPeriod.month:
      return List.generate(
        5,
        (index) => ExpenseBucket(label: 'W${index + 1}', amount: 0),
      );
    case StatsPeriod.year:
      const labels = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return labels
          .map((label) => ExpenseBucket(label: label, amount: 0))
          .toList();
  }
}

int _bucketIndex(StatsPeriod period, DateTime date, DateTime rangeStart) {
  switch (period) {
    case StatsPeriod.week:
      final dateOnly = DateTime.utc(date.year, date.month, date.day);
      final startOnly =
          DateTime.utc(rangeStart.year, rangeStart.month, rangeStart.day);
      return dateOnly.difference(startOnly).inDays;
    case StatsPeriod.month:
      return (date.day - 1) ~/ 7;
    case StatsPeriod.year:
      return date.month - 1;
  }
}
