# 📚 REST API Reference Card

## Quick API Usage

### Import Required
```dart
import 'package:provider/provider.dart';
import 'package:expense_app/core/providers/transaction_provider.dart';
import 'package:expense_app/features/home_expense/data/models/transaction_model.dart';
```

---

## GET - Fetch Transactions

### Fetch All (Once)
```dart
await Provider.of<TransactionProvider>(context, listen: false)
    .fetchTransactions();
```

### Real-time Stream
```dart
Provider.of<TransactionProvider>(context, listen: false)
    .getTransactionsStream()  // Returns Stream<List<TransactionModel>>
```

### In UI with Consumer
```dart
Consumer<TransactionProvider>(
  builder: (context, provider, _) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return Text('Error: ${provider.error}');
    }
    
    if (provider.transactions.isEmpty) {
      return Text('No transactions');
    }
    
    return ListView.builder(
      itemCount: provider.transactions.length,
      itemBuilder: (context, index) {
        final transaction = provider.transactions[index];
        return TransactionTile(transaction: transaction);
      },
    );
  },
);
```

### Access Current Data
```dart
final provider = Provider.of<TransactionProvider>(context, listen: false);
List<TransactionModel> transactions = provider.transactions;
bool isLoading = provider.isLoading;
String? error = provider.error;
```

---

## POST - Add Transaction

### Create and Save
```dart
final newTransaction = TransactionModel(
  id: const Uuid().v4(),  // Auto-generate ID
  title: "Coffee",
  amount: 5.50,
  date: DateTime.now(),
  isIncome: false,
  category: coffeeCategory,  // Optional
);

await Provider.of<TransactionProvider>(context, listen: false)
    .addTransaction(newTransaction);
```

### With Error Handling
```dart
try {
  await Provider.of<TransactionProvider>(context, listen: false)
      .addTransaction(newTransaction);
  
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaction added!')),
    );
    Navigator.pop(context);
  }
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  }
}
```

### Income Transaction
```dart
final incomeTransaction = TransactionModel(
  id: const Uuid().v4(),
  title: "Salary",
  amount: 5000.00,  // Positive number
  date: DateTime(2024, 5, 25),
  isIncome: true,
  category: null,  // No category for income
);

await Provider.of<TransactionProvider>(context, listen: false)
    .addTransaction(incomeTransaction);
```

---

## PUT - Update Transaction

### Update Existing
```dart
// Get the transaction to update
final transaction = provider.transactions[index];

// Create updated version
final updated = transaction.copyWith(
  title: "New Title",
  amount: 100.00,
  category: newCategory,
);

// Save to Firestore
await Provider.of<TransactionProvider>(context, listen: false)
    .updateTransaction(updated);
```

### Keep ID Unchanged
```dart
// IMPORTANT: Keep the ID same for updates
final updated = TransactionModel(
  id: oldTransaction.id,  // ← Same ID
  title: "Updated Title",
  amount: newAmount,
  date: newDate,
  isIncome: isIncome,
  category: category,
);

await Provider.of<TransactionProvider>(context, listen: false)
    .updateTransaction(updated);
```

---

## DELETE - Remove Transaction

### Simple Delete
```dart
await Provider.of<TransactionProvider>(context, listen: false)
    .deleteTransaction(transactionId);
```

### With Confirmation Dialog
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Text('Delete?'),
    content: const Text('Are you sure?'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () async {
          Navigator.pop(context);
          
          await Provider.of<TransactionProvider>(context, listen: false)
              .deleteTransaction(transactionId);
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deleted')),
            );
          }
        },
        child: const Text('Delete', style: TextStyle(color: Colors.red)),
      ),
    ],
  ),
);
```

### Swipe to Delete (Dismissible)
```dart
Dismissible(
  key: Key(transaction.id),
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  onDismissed: (direction) async {
    await Provider.of<TransactionProvider>(context, listen: false)
        .deleteTransaction(transaction.id);
  },
  child: TransactionTile(transaction: transaction),
);
```

---

## Calculated Values

### Get Statistics
```dart
final provider = Provider.of<TransactionProvider>(context, listen: false);

double totalIncome = provider.getTotalIncome();
double totalExpense = provider.getTotalExpense();
double balance = provider.getBalance();

// Usage
Text('Income: $${totalIncome}')
Text('Expense: $${totalExpense}')
Text('Balance: $${balance}')
```

---

## Error Handling

### Access Error Messages
```dart
final provider = Provider.of<TransactionProvider>(context, listen: false);

if (provider.error != null) {
  print('Error occurred: ${provider.error}');
  // Show to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${provider.error}')),
  );
}
```

### Common Errors
| Error | Cause | Solution |
|-------|-------|----------|
| "Permission denied" | Firestore rules issue | Check security rules in Firebase |
| "User not authenticated" | Not logged in | Login first |
| "Failed to connect" | No internet | Check network connection |
| "Document not found" | Wrong ID | Verify transaction ID |

---

## TransactionModel Creation

### Full Example
```dart
import 'package:uuid/uuid.dart';

final transaction = TransactionModel(
  id: const Uuid().v4(),  // Generate unique ID
  title: "Grocery Shopping",
  amount: 75.50,
  date: DateTime.now(),
  isIncome: false,
  category: CategoryItem(
    label: "Food",
    icon: Icons.fastfood,
    color: Colors.orange,
  ),
);
```

### Expense vs Income

**Expense:**
```dart
TransactionModel(
  id: id,
  title: "Rent",
  amount: 1200.0,      // Positive amount
  date: DateTime.now(),
  isIncome: false,     // ← false
  category: rentCategory,
)
```

**Income:**
```dart
TransactionModel(
  id: id,
  title: "Salary",
  amount: 5000.0,      // Positive amount
  date: DateTime.now(),
  isIncome: true,      // ← true
  category: null,      // No category
)
```

---

## Provider Access Patterns

### Pattern 1: One-time Operation
```dart
// Add
await Provider.of<TransactionProvider>(context, listen: false)
    .addTransaction(transaction);

// No UI rebuild
```

### Pattern 2: Watch for Changes
```dart
// In build method
Consumer<TransactionProvider>(
  builder: (context, provider, _) {
    // Rebuilds when provider changes
    return ListView(
      children: provider.transactions.map(...).toList(),
    );
  },
);
```

### Pattern 3: Multiple Listeners
```dart
// Watch multiple providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => TransactionProvider()),
  ],
  child: MyApp(),
)
```

---

## Complete Example - Add Transaction Screen

```dart
class AddTransactionScreen extends StatelessWidget {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  CategoryItem? selectedCategory;
  bool isIncome = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: 'Amount'),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate
              if (titleController.text.isEmpty || amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fill all fields')),
                );
                return;
              }

              // Create transaction
              final transaction = TransactionModel(
                id: const Uuid().v4(),
                title: titleController.text,
                amount: double.parse(amountController.text),
                date: selectedDate,
                isIncome: isIncome,
                category: selectedCategory,
              );

              // Save
              try {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .addTransaction(transaction);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added!')),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }
}
```

---

## Database Queries (Advanced)

### Firestore Structure
```
users/
  └─ {userId}/
      └─ transactions/
          ├─ docId1: { ... }
          └─ docId2: { ... }
```

### Available Queries
```dart
// All are done automatically in TransactionApiService:

// Get all (done)
.collection('users').doc(userId).collection('transactions').get()

// Real-time (done)
.collection('users').doc(userId).collection('transactions')
 .snapshots()

// Sorted by date (done)
.collection('users').doc(userId).collection('transactions')
 .orderBy('date', descending: true).get()

// Custom queries (for future):
.where('isIncome', isEqualTo: false)  // Get only expenses
.where('date', isGreaterThan: startDate)  // Date range
```

---

## Tips & Tricks

✅ Always use `const Uuid().v4()` for transaction IDs  
✅ Keep IDs unchanged on updates  
✅ Use `context.mounted` check after async operations  
✅ Show loading spinner during operations  
✅ Validate input before saving  
✅ Use error messages for debugging  
✅ Test with Firebase Console open  
✅ Check Firestore rules if "Permission denied"  

---

**Happy coding! 🚀**
