import 'package:expense_app/features/add_expense/presentation/widgets/category_card.dart';
import 'package:expense_app/features/add_expense/presentation/widgets/custom_toogle_button.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:expense_app/features/home_expense/data/sources/dummy_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  bool _isIncome = false; // false for expense, true for income
  DateTime _selectedDate = DateTime.now(); // ✅ Changed to current date
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // ✅ Add this for category selection
  CategoryItem? _selectedCategoryItem;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  double get _amountFontSize {
    final length = _amountController.text.length;
    if (length <= 6) return 44;
    if (length <= 8) return 34;
    return 26;
  }

  // ✅ Fixed save function
  void _saveTransaction() async {
    // Validate amount
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount")),
      );
      return;
    }

    // Validate description
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a description")),
      );
      return;
    }

    // Validate category for expenses
    if (!_isIncome && _selectedCategoryItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    double amount = double.parse(_amountController.text);

    // ✅ Create transaction with proper null handling
    final transaction = TransactionModel(
      title: _descriptionController.text,
      amount: amount,
      date: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      ),
      isIncome: _isIncome,
      category:
          _isIncome ? null : _selectedCategoryItem, // ✅ Pass null for income
    );

    transactions.add(transaction);

    // ✅ Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction added successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Add Expense',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Section
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    'ENTER AMOUNT',
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          cursorColor: const Color(0xFF4B3EF5),
                          cursorWidth: 1.5,
                          cursorRadius: const Radius.circular(2),
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: _amountFontSize,
                            fontWeight: FontWeight.w300,
                            height: 1.0,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color: Colors.black26,
                              fontSize: 46,
                              fontWeight: FontWeight.w300,
                              height: 1.0,
                              leadingDistribution: TextLeadingDistribution.even,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 7,
                        child: Text(
                          'NPR',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF4B3EF5),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Income/Expense Toggle Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = false;
                          });
                        },
                        child: CustomToogleButton(
                          label1: 'Expense',
                          icon: Icons.arrow_downward,
                          isSelected:
                              !_isIncome, // ✅ True when expense is selected
                          onTap: () {
                            setState(() {
                              _isIncome = false; // ✅ Set to expense
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isIncome = true;
                          });
                        },
                        child: CustomToogleButton(
                          label1: "Income",
                          icon: Icons.arrow_upward,
                          isSelected:
                              _isIncome, // ✅ True when income is selected
                          onTap: () {
                            setState(() {
                              _isIncome = true; // ✅ Set to income
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ✅ Category Section - Only show for expenses, with proper callback
            if (!_isIncome)
              CategoryCard(
                onCategorySelected: (CategoryItem category) {
                  setState(() {
                    _selectedCategoryItem = category;
                  });
                },
              ),

            const SizedBox(height: 12),

            // Brief Description
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Brief Description',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'What was this for?',
                      hintStyle:
                          const TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: const Icon(
                        Icons.description_outlined,
                        color: Colors.black38,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5FA),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Date of Expense
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Date of Expense',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.black45,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatDate(_selectedDate),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.calendar_month_outlined,
                            color: Colors.black38,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Add Expense Button - ✅ Fixed onPressed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _saveTransaction, // ✅ Use the save function
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B3EF5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 22),
                  label: const Text(
                    'Add Expense',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
