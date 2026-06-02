import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/home_expense/data/models/transaction_model.dart';

class TransactionApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID for data isolation
  String get _userId => _auth.currentUser!.uid;

  // =======================================
  // ✅ GET - Fetch all transactions
  // =======================================
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // =======================================
  // ✅ POST - Add new transaction
  // =======================================
  Future<TransactionModel> addTransaction(TransactionModel transaction) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .add(transaction.toJson());

      return transaction.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  // =======================================
  // ✅ PUT - Update existing transaction
  // =======================================
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toJson());
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  // =======================================
  // ✅ DELETE - Remove transaction
  // =======================================
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  // =======================================
  // ✅ REAL-TIME LISTENER - Stream transactions
  // =======================================
  Stream<List<TransactionModel>> getTransactionsStream() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    }).handleError((error) {
      throw Exception('Failed to stream transactions: $error');
    });
  }
}
