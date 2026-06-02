import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/core/widgets/transaction_item_card.dart';
import 'package:expense_app/features/expense_form/presentation/screens/expense_form_screen.dart';
import 'package:expense_app/features/home_expense/presentation/screens/all_transaction_screen.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_app_bar.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_balance_card.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_floating_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final provider = Provider.of<TransactionProvider>(context, listen: false);
      await provider.loadLocalTransactions();
      if (provider.transactions.isEmpty) {
        await provider.fetchTransactions();
      }
    });
  }

  // Navigate to add expense screen and refresh on return
  Future<void> _navigateToAddExpense() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExpenseFormScreen()),
    );
    // Refresh transactions after adding
    if (mounted) {
      Provider.of<TransactionProvider>(context, listen: false)
          .fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(user: FirebaseAuth.instance.currentUser),
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 88.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: BalanceCard(),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Transactions",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          )),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const AllTransactionsPage();
                          }));
                        },
                        borderRadius: BorderRadius.circular(4),
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            "See All",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : const Color(0xFF3A2EDB),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (transactionProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )
                else if (transactionProvider.error != null)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading transactions',
                          style: GoogleFonts.poppins(
                            color: Colors.red.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          transactionProvider.error ?? '',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else if (transactionProvider.transactions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the + button to add your first transaction',
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: transactionProvider.transactions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TransactionItem(
                          transaction: transactionProvider.transactions[index],
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        onPressed: _navigateToAddExpense,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
    //   bottomNavigationBar: CustomBottomNavBar(
    //     currentIndex: _currentIndex,
    //     onTap: (index) {
    //       setState(() {
    //         _currentIndex = index;
    //       }); // Handle navigation logic here
    //     },
    //   ),
    // );
  }
}
