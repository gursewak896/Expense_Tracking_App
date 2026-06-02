import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/features/expense_form/presentation/screens/expense_form_screen.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/core/utils/currency_formatter.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  const TransactionItem({super.key, required this.transaction});

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(BuildContext context) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed != true) return;

    await Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(transaction.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    }
  }

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
    return Dismissible(
        key: Key(transaction.id),
        background: Container(
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          final confirmed = await _showDeleteConfirmation(context);
          return confirmed == true;
        },
        onDismissed: (direction) {
          Provider.of<TransactionProvider>(context, listen: false)
              .deleteTransaction(transaction.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted')),
          );
        },
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseFormScreen(
                  expense: transaction,
                  isEdit: true,
                ),
              ),
            );
          },
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: const Text('Edit'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpenseFormScreen(
                              expense: transaction,
                              isEdit: true,
                            ),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteTransaction(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF2C2C2C)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // ICON
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.2),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              "$categoryName • ${formatDate(transaction.date)}",
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
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
                        "${transaction.isIncome ? '+' : '-'} ${formatNpr(transaction.amount.abs())}",
                        style: TextStyle(
                          color:
                              transaction.isIncome ? Colors.green : Colors.red,
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
          ),
        ));
  }
}
