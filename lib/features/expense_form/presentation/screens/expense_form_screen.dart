import 'package:expense_app/features/expense_form/presentation/provider/expense_form_provider.dart';
import 'package:expense_app/features/expense_form/presentation/widgets/category_card.dart';
import 'package:expense_app/features/expense_form/presentation/widgets/custom_toogle_button.dart';
import 'package:expense_app/features/home_expense/data/models/category_items.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ExpenseFormScreen extends StatefulWidget {
  final TransactionModel? expense;
  final bool isEdit;
  const ExpenseFormScreen({super.key, this.expense, this.isEdit = false});

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  bool get isEdit => widget.expense != null;
  late final ExpenseFormProvider provider;

  @override
  void initState() {
    super.initState();

    provider = ExpenseFormProvider();

    if (widget.isEdit && widget.expense != null) {
      provider.setEditData(widget.expense!);
    }
  }

  @override
  void dispose() {
    provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: Consumer<ExpenseFormProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).iconTheme.color),
                onPressed: () => Navigator.maybePop(context),
              ),
              title: Text(
                isEdit ? 'Edit Expense' : 'Add Expense',
                style: TextStyle(
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: false,
              actions: [
                if (isEdit)
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: Text(
                                  'Delete Transaction',
                                  style: TextStyle(
                                    color: Theme.of(dialogContext)
                                        .textTheme
                                        .titleMedium
                                        ?.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Do you really want to delete this item?',
                                  style: TextStyle(
                                    color: Theme.of(dialogContext)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Theme.of(dialogContext)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          dialogContext); // Close dialog
                                      provider.deleteTransaction(context);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Section
                  Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 28, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'ENTER AMOUNT',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withAlpha(180),
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
                                controller: provider.amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontSize: provider.amountFontSize,
                                  fontWeight: FontWeight.w300,
                                  height: 1.0,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0.00',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withAlpha(100),
                                    fontSize: 46,
                                    fontWeight: FontWeight.w300,
                                    height: 1.2,
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              left: 6,
                              top: 16,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  //   _isIncome = false;
                                  provider.toggleType(false);
                                });
                              },
                              child: CustomToogleButton(
                                label1: 'Expense',
                                icon: Icons.arrow_downward,
                                isSelected: !provider
                                    .isIncome, // ✅ True when expense is selected
                                onTap: () => provider.toggleType(false),
                                // {
                                //   setState(() {
                                //     _isIncome = false; // ✅ Set to expense
                                //   });
                                // },
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  provider.toggleType(true);
                                });
                              },
                              child: CustomToogleButton(
                                label1: "Income",
                                icon: Icons.arrow_upward,
                                isSelected: provider
                                    .isIncome, // ✅ True when income is selected
                                onTap: () => provider.toggleType(true),
                                // {
                                //   setState(() {
                                //     _isIncome = true; // ✅ Set to income
                                //   });
                                // },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ✅ Category Section - Only show for expenses, with proper callback
                  if (!provider.isIncome)
                    CategoryCard(
                      selectedCategory: provider.selectedCategoryItem,
                      onCategorySelected: (CategoryItem category) {
                        provider.updateCategory(category);
                        // setState(() {
                        //   _selectedCategoryItem = category;
                        // });
                      },
                    ),

                  const SizedBox(height: 12),

                  // Brief Description
                  Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1E1E1E)
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Brief Description',
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: provider.descriptionController,
                          style: TextStyle(
                              fontSize: 14,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                          decoration: InputDecoration(
                            hintText: 'What was this for?',
                            hintStyle: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withAlpha(150),
                                fontSize: 14),
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withAlpha(150),
                              size: 20,
                            ),
                            filled: true,
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFF5F5FA),
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
                  GestureDetector(
                    onTap: () => provider.pickDate(context),
                    child: Container(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date of Expense',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => provider.pickDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF2C2C2C)
                                    : const Color(0xFFF5F5FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withAlpha(180),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      provider.formattedDate,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withAlpha(150),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                        onPressed: () {
                          if (isEdit) {
                            provider.updateTransaction(context);
                          } else {
                            provider.saveTransaction(context);
                          }
                        }, // ✅ Use the save function
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4B3EF5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 22),
                        label: Text(
                          isEdit ? 'Update Expense' : 'Add Expense',
                          style: const TextStyle(
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
        },
      ),
    );
  }
}
