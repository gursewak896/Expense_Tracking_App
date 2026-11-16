import 'package:expense_app/features/home_expense/presentation/screens/home_view.dart';
import 'package:expense_app/features/home_expense/presentation/screens/profile_view.dart';
import 'package:expense_app/features/home_expense/presentation/screens/stats_view.dart';
import 'package:expense_app/features/home_expense/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeView(), // index 0
    const StatsView(), // index 1
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
