import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_app/services/transaction_api_service.dart';
import '../../features/home_expense/data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  static const String _storageKey = 'saved_transactions';

  final TransactionApiService _apiService = TransactionApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _localStorageKey {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return _storageKey;
    }
    return '${_storageKey}_$uid';
  }

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _saveTransactionsToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_transactions.map((t) => t.toMap()).toList());
    await prefs.setString(_localStorageKey, jsonString);
  }

  Future<void> loadLocalTransactions() async {
    _isLoading = true;
    _error = null;
    _transactions = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_localStorageKey);
      if (stored != null && stored.isNotEmpty) {
        final decoded = jsonDecode(stored) as List<dynamic>;
        _transactions = decoded
            .map((item) => TransactionModel.fromJson(
                Map<String, dynamic>.from(item as Map<String, dynamic>)))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearLocalTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localStorageKey);
    _transactions = [];
    notifyListeners();
  }

  // =======================================
  // ✅ GET - Fetch all transactions
  // =======================================
  Future<void> fetchTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactions();
      await _saveTransactionsToLocal();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // =======================================
  // ✅ POST - Add new transaction
  // =======================================
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final newTransaction = await _apiService.addTransaction(transaction);
      _transactions.insert(0, newTransaction);
      await _saveTransactionsToLocal();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // =======================================
  // ✅ PUT - Update existing transaction
  // =======================================
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _apiService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        await _saveTransactionsToLocal();
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // =======================================
  // ✅ DELETE - Remove transaction
  // =======================================
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _apiService.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      await _saveTransactionsToLocal();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // =======================================
  // 🔄 STREAM - Real-time transaction updates
  // =======================================
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _apiService.getTransactionsStream();
  }

  // =======================================
  // 💰 CALCULATE STATS
  // =======================================
  double getTotalIncome() {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getTotalExpense() {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpense();
  }
}
