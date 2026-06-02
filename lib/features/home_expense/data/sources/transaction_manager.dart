// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/transaction_model.dart';

// class TransactionManager extends ChangeNotifier {
//   static const String _storageKey = 'transactions_data';
//   VoidCallback? onTransactionsChanged;
//   final List<TransactionModel> _transactions = [];

//   List<TransactionModel> get transactions => _transactions;

//   void addTransaction(TransactionModel transaction) {
//     _transactions.add(transaction);
//     notifyListeners();
//   }

//   void updateTransaction(TransactionModel updatedTransaction) {
//   final index = _transactions.indexWhere(
//     (t) => t.id == updatedTransaction.id,
//   );

//   if (index != -1) {
//     _transactions[index] = updatedTransaction;
//     _saveToStorage();
//     onTransactionsChanged?.call();
//   }
// }

//   Future<void> _saveToStorage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final jsonList = _transactions.map((t) => t.toJson()).toList();
//       final jsonString = jsonEncode(jsonList);
//       await prefs.setString(_storageKey, jsonString);
//     } catch (e) {
//       print('Error saving transactions: $e');
//     }
//   }
// }
