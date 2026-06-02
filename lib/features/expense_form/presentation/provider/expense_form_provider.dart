import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ExpenseFormProvider extends ChangeNotifier {
  TransactionModel? editingTransaction;
  bool isIncome = false;
  DateTime selectedDate = DateTime.now();
  CategoryItem? selectedCategoryItem;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  ExpenseFormProvider() {
    amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    notifyListeners();
  }

  double get amountFontSize {
    final length = amountController.text.length;
    if (length <= 6) return 44;
    if (length <= 8) return 34;
    return 28;
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4B3EF5),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  String get formattedDate => DateFormat('MM/dd/yyyy').format(selectedDate);

  void toggleType(bool value) {
    isIncome = value;
    if (isIncome) selectedCategoryItem = null; // Reset category if income
    notifyListeners();
  }

  void updateDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateCategory(CategoryItem category) {
    selectedCategoryItem = category;
    notifyListeners();
  }

  bool validate(BuildContext context) {
    if (amountController.text.isEmpty) {
      return _showError(context, "Enter an amount");
    }
    if (descriptionController.text.isEmpty) {
      return _showError(context, "Enter description");
    }
    if (!isIncome && selectedCategoryItem == null) {
      return _showError(context, "Select a category");
    }
    return true;
  }

  bool _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    return false;
  }

  Future<void> saveTransaction(BuildContext context) async {
    if (!validate(context)) return;

    double amount = double.parse(amountController.text);
    final transaction = TransactionModel(
      id: const Uuid().v4(), // Use UUID for unique IDs
      title: descriptionController.text,
      amount: amount,
      date: selectedDate,
      isIncome: isIncome,
      category: isIncome ? null : selectedCategoryItem,
    );

    // Add to Firestore via TransactionProvider
    await Provider.of<TransactionProvider>(context, listen: false)
        .addTransaction(transaction);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void setEditData(TransactionModel expense) {
    editingTransaction = expense;

    amountController.text = expense.amount.abs().toString();
    descriptionController.text = expense.title;

    isIncome = expense.isIncome;
    selectedDate = expense.date;
    selectedCategoryItem = expense.category;

    notifyListeners();
  }

  Future<void> updateTransaction(BuildContext context) async {
    if (!validate(context)) return;

    if (editingTransaction == null) return;

    double amount = double.parse(amountController.text);

    final updated = TransactionModel(
      id: editingTransaction!.id, // Keep same ID for update
      title: descriptionController.text,
      amount: amount,
      date: selectedDate,
      isIncome: isIncome,
      category: isIncome ? null : selectedCategoryItem,
    );

    // Update in Firestore via TransactionProvider
    await Provider.of<TransactionProvider>(context, listen: false)
        .updateTransaction(updated);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> deleteTransaction(BuildContext context) async {
    if (editingTransaction == null) return;

    // Delete from Firestore via TransactionProvider
    await Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(editingTransaction!.id);

    if (context.mounted) {
      // Return to the home screen after deleting the transaction.
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
