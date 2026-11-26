// import 'package:expense_app/core/contants.dart';
// import 'package:flutter/material.dart';

// class FilterTabs extends StatelessWidget {
//   const FilterTabs({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           _tab("All", TransactionFilter.all == TransactionFilter.all),
//           _tab("Income", TransactionFilter.income == TransactionFilter.all),
//           _tab("Expense", TransactionFilter.expense == TransactionFilter.all),
//         ],
//       ),
//     );
//   }

//   Widget _tab(String text, bool active) {
//     return Container(
//       margin: const EdgeInsets.only(right: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//       decoration: BoxDecoration(
//         color: active ? const Color(0xFF4B3CF0) : Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           color: active ? Colors.white : Colors.black54,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

// Define transaction types
enum TransactionFilter { all, income, expense }

// Callback to notify parent about filter change
typedef FilterChanged = void Function(TransactionFilter filter);

class FilterTabs extends StatefulWidget {
  final FilterChanged onFilterChanged;

  const FilterTabs({super.key, required this.onFilterChanged});

  @override
  State<FilterTabs> createState() => _FilterTabsState();
}

class _FilterTabsState extends State<FilterTabs> {
  TransactionFilter _selectedFilter = TransactionFilter.all;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _tab("All", TransactionFilter.all),
          _tab("Income", TransactionFilter.income),
          _tab("Expense", TransactionFilter.expense),
        ],
      ),
    );
  }

  Widget _tab(String text, TransactionFilter filter) {
    final bool isActive = _selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        widget.onFilterChanged(filter); // Notify parent
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4B3CF0) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
