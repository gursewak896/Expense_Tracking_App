import 'dart:async';
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
  StreamSubscription<List<TransactionModel>>? _transactionsSubscription;
  String? _activeUserId;

  String _localStorageKeyFor(String? userId) {
    if (userId == null || userId.isEmpty) {
      return _storageKey;
    }
    return '${_storageKey}_$userId';
  }

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _saveTransactionsToLocal(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(transactions.map((t) => t.toMap()).toList());
    await prefs.setString(_localStorageKeyFor(userId), jsonString);
  }

  Future<void> loadLocalTransactions() async {
    final userId = _auth.currentUser?.uid;
    _isLoading = true;
    _error = null;
    _transactions = [];
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_localStorageKeyFor(userId));
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

  Future<void> initializeTransactions() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      await stopListeningToTransactions();
      _transactions = [];
      _isLoading = false;
      _error = null;
      notifyListeners();
      return;
    }

    if (_activeUserId == userId && _transactionsSubscription != null) return;

    await stopListeningToTransactions();
    if (_auth.currentUser?.uid != userId) return;

    _activeUserId = userId;
    _transactions = [];
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_localStorageKeyFor(userId));
      if (_activeUserId != userId) return;
      if (stored != null && stored.isNotEmpty) {
        final decoded = jsonDecode(stored) as List<dynamic>;
        _transactions = decoded
            .map((item) => TransactionModel.fromJson(
                Map<String, dynamic>.from(item as Map<String, dynamic>)))
            .toList();
      }
      _isLoading = _transactions.isEmpty;
      notifyListeners();
    } catch (e) {
      if (_activeUserId != userId) return;
      _error = 'Failed to load cached transactions: $e';
      _isLoading = true;
      notifyListeners();
    }

    if (_activeUserId != userId) return;
    try {
      _transactionsSubscription = getTransactionsStream().listen(
        (transactions) {
          if (_activeUserId != userId) return;
          _transactions = transactions;
          _isLoading = false;
          _error = null;
          notifyListeners();
          unawaited(_cacheStreamTransactions(userId, transactions));
        },
        onError: (Object error) {
          if (_activeUserId != userId) return;
          _isLoading = false;
          _error = error.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      if (_activeUserId != userId) return;
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _cacheStreamTransactions(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    try {
      await _saveTransactionsToLocal(userId, transactions);
    } catch (e) {
      if (_activeUserId != userId) return;
      _error = 'Failed to cache transactions: $e';
      notifyListeners();
    }
  }

  Future<void> stopListeningToTransactions() async {
    _activeUserId = null;
    final subscription = _transactionsSubscription;
    _transactionsSubscription = null;
    await subscription?.cancel();
  }

  Future<void> clearLocalTransactions() async {
    await stopListeningToTransactions();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localStorageKeyFor(_auth.currentUser?.uid));
    _transactions = [];
    _isLoading = false;
    _error = null;
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
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw StateError('A signed-in user is required to fetch transactions.');
      }
      _transactions = await _apiService.getTransactions();
      await _saveTransactionsToLocal(userId, _transactions);
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
  Future<bool> addTransaction(TransactionModel transaction) async {
    late final String userId;
    late final TransactionModel newTransaction;
    try {
      final currentUserId = _auth.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw StateError('A signed-in user is required to add transactions.');
      }
      userId = currentUserId;
      newTransaction = await _apiService.addTransaction(transaction);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }

    _upsertTransaction(newTransaction);
    _error = null;
    notifyListeners();

    try {
      await _saveTransactionsToLocal(userId, _transactions);
    } catch (e) {
      _error = 'Expense saved to Firestore, but local cache update failed: $e';
      notifyListeners();
    }
    return true;
  }

  // =======================================
  // ✅ PUT - Update existing transaction
  // =======================================
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw StateError(
            'A signed-in user is required to update transactions.');
      }
      await _apiService.updateTransaction(transaction);
      _upsertTransaction(transaction);
      await _saveTransactionsToLocal(userId, _transactions);
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
      final userId = _auth.currentUser?.uid;
      if (userId == null || userId.isEmpty) {
        throw StateError(
            'A signed-in user is required to delete transactions.');
      }
      await _apiService.deleteTransaction(transactionId);
      _transactions.removeWhere((t) => t.id == transactionId);
      await _saveTransactionsToLocal(userId, _transactions);
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

  void _upsertTransaction(TransactionModel transaction) {
    final index = _transactions.indexWhere((item) => item.id == transaction.id);
    if (index == -1) {
      _transactions.add(transaction);
    } else {
      _transactions[index] = transaction;
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
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

  @override
  void dispose() {
    unawaited(_transactionsSubscription?.cancel());
    super.dispose();
  }
}
