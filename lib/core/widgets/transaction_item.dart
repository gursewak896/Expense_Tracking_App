import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:expense_app/features/home_expense/data/repositories/transaction_repository.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final CategoryItem? category = transaction.category;
    // ✅ Handle null safely for income transactions
    final String categoryName =
        transaction.isIncome ? 'Income' : (category?.label ?? 'Other');

    final IconData categoryIcon = transaction.isIncome
        ? Icons.attach_money
        : (category?.icon ?? Icons.category);

    final Color categoryColor =
        transaction.isIncome ? Colors.green : (category?.color ?? Colors.grey);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon, // ✅ Use categoryIcon which handles null
                color: categoryColor,
              ),
            ),

            const SizedBox(width: 12),

            // TITLE + DATE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "$categoryName • ${formatDate(transaction.date)}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // AMOUNT
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${transaction.isIncome ? '+' : '-'}\$${transaction.amount.abs()}",
                  style: TextStyle(
                    color: transaction.isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.isIncome ? "CREDIT" : "DEBIT",
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
