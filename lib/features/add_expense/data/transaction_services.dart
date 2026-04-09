import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';

class TransactionService {
  static final List<TransactionModel> transactions = [];

  static void addTransaction(TransactionModel transaction) {
    transactions.add(transaction);
  }
}
