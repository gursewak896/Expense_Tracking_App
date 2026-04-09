import 'package:expense_app/core/widgets/transaction_item.dart';
import 'package:expense_app/features/add_expense/presentation/screens/add_expense.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:expense_app/features/home_expense/data/repositories/transaction_repository.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import '../widgets/filter_tabs.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  TransactionFilter selectedFilter = TransactionFilter.all;
  List<TransactionModel> filterTransactions(
    List<TransactionModel> transactions,
    TransactionFilter filter,
  ) {
    switch (filter) {
      case TransactionFilter.income:
        return transactions.where((t) => t.isIncome).toList();

      case TransactionFilter.expense:
        return transactions.where((t) => !t.isIncome).toList();

      case TransactionFilter.all:
      default:
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allTransactions = TransactionRepository.getTransactions();

    final filtered = filterTransactions(allTransactions, selectedFilter);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            FilterTabs(
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  return TransactionItem(transaction: filtered[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingButton(
          icon: Icons.add,
          onPressed: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const AddExpenseScreen();
              }))),
    );
  }

  Widget _buildHeader() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black87),
      title: const Text(
        "All Transactions",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      actions: const [
        Icon(Icons.filter, color: Colors.black87),
        SizedBox(width: 12),
      ],
    );
  }
}
