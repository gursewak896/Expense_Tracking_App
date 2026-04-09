import 'package:expense_app/core/widgets/transaction_item.dart';
import 'package:expense_app/features/add_expense/presentation/screens/add_expense.dart';
import 'package:expense_app/features/home_expense/data/sources/dummy_data.dart';
import 'package:expense_app/features/home_expense/presentation/screens/all_transaction_screen.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_app_bar.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_balance_card.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(username: "Gursewak Singh"),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 6,
            ),
            const SizedBox(
              height: 8,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: BalanceCard(),
            ),
            const SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Recent Transactions",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      )),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const AllTransactionsPage();
                      }));
                    },
                    borderRadius: BorderRadius.circular(4),
                    hoverColor:
                        Colors.transparent, // removes default grey hover
                    splashColor: Colors.transparent, // removes ripple
                    highlightColor: Colors.transparent, // removes press bg
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3A2EDB), // default color
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            transactions.isEmpty
                ? Padding(
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
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListView.builder(
                      itemCount: transactions.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return TransactionItem(
                          transaction: transactions[index],
                        );
                      },
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: CustomFloatingButton(
                    icon: Icons.add,
                    onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const AddExpenseScreen();
                        }))),
              ),
            ),
            // Padding(
            //   padding:
            //       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            //   child: Align(
            //     alignment: Alignment.centerRight,
            //     child: Container(
            //         decoration: const BoxDecoration(
            //           color: Color(0xFF3A2EDB),
            //           shape: BoxShape.circle,
            //         ),
            //         child: IconButton(
            //           onPressed: () {
            //             Navigator.push(context,
            //                 MaterialPageRoute(builder: (context) {
            //               return const AddExpenseScreen();
            //             }));
            //           },
            //           icon: const Icon(Icons.add),
            //           color: Colors.white,
            //           style: IconButton.styleFrom(iconSize: 30),
            //         )),
            //   ),
            // ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          }); // Handle navigation logic here
        },
      ),
    );
  }
}
