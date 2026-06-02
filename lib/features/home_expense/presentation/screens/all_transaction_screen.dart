import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/core/widgets/transaction_item_card.dart';
import 'package:expense_app/features/expense_form/presentation/screens/expense_form_screen.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        return transactions;
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final filteredList = filterTransactions(
      transactionProvider.transactions,
      selectedFilter,
    );
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            FilterTabs(
              onFilterChanged: (filter) {
                setState(() {
                  selectedFilter = filter;
                });
              },
            ),
            const SizedBox(height: 20),
            if (transactionProvider.isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (transactionProvider.error != null)
              Expanded(
                child: Center(
                  child: Text(
                    transactionProvider.error!,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              )
            else if (filteredList.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 72,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions yet',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first transaction to see it here.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    return TransactionItem(
                      transaction: filteredList[index],
                    );
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
                return const ExpenseFormScreen();
              }))),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: Text(
        "All Transactions",
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color),
      ),
      // actions: [
      //   Icon(Icons.filter, color: Theme.of(context).iconTheme.color),
      // const SizedBox(width: 12),
      // ],
    );
  }
}
