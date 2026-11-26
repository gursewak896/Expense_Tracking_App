import 'dart:async';

import 'package:expense_app/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:expense_app/features/dashboard/presentation/screens/home_view.dart';
import 'package:expense_app/features/dashboard/presentation/screens/profile_view.dart';
import 'package:expense_app/features/analytics/presentation/screens/stats_view.dart';
import 'package:expense_app/features/dashboard/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final TransactionProvider _transactionProvider;

  final List<Widget> _pages = [
    const HomeView(), // index 0
    const StatsView(), // index 1
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _transactionProvider = context.read<TransactionProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_transactionProvider.initializeTransactions());
      }
    });
  }

  @override
  void dispose() {
    unawaited(_transactionProvider.stopListeningToTransactions());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
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
