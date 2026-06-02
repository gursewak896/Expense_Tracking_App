# 🔐 Firestore Setup Guide - Security Rules & Configuration

## Step 1: Update Firestore Security Rules

Go to **Firebase Console** → Select your project → **Firestore Database** → **Rules** tab

Replace the default rules with this:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User-specific transactions
    match /users/{userId}/transactions/{transactionId} {
      // Only the authenticated user can read/write their transactions
      allow read, write: if request.auth.uid == userId;
    }
    
    // User profile (optional, for future)
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

Then click **Publish** to activate the rules.

## Step 2: Verify Firestore Collection Structure

Your Firestore database should have this structure:

```
users/
  └─ {userId}/                 # User's unique Firebase ID
      └─ transactions/         # Subcollection of transactions
          ├─ {docId1}          # Auto-generated document ID
          │   ├─ title: "Groceries"
          │   ├─ amount: 50.0
          │   ├─ date: "2024-05-29T10:30:00Z"
          │   ├─ isIncome: false
          │   └─ category: {...}
          │
          └─ {docId2}
              ├─ title: "Salary"
              ├─ amount: 5000.0
              ├─ date: "2024-05-25T00:00:00Z"
              ├─ isIncome: true
              └─ category: null
```

## Step 3: Test Security Rules

In Firebase Console, go to **Firestore** → **Rules** → **Rules Playground** (or just click "Test")

### Test Case 1: User Can Read Own Transactions ✅
```
Auth: Signed in as user "abc123"
Read: users/abc123/transactions
Result: Should be ALLOWED
```

### Test Case 2: User Cannot Read Other's Transactions ❌
```
Auth: Signed in as user "abc123"
Read: users/xyz789/transactions
Result: Should be DENIED
```

## Step 4: Understand the Data Flow

### GET - Reading Transactions
```
App User Login
    ↓
firebase_auth gets userId (e.g., "abc123")
    ↓
TransactionApiService.getTransactions() called
    ↓
Firestore Query:
  .collection('users').doc(userId).collection('transactions')
    ↓
Security Rule Checks: request.auth.uid == userId ✅
    ↓
Return user's transactions only
```

### POST - Adding Transaction
```
User fills form & clicks "Save"
    ↓
TransactionProvider.addTransaction(transaction)
    ↓
TransactionApiService.addTransaction()
    ↓
Firestore.collection('users').doc(userId).collection('transactions').add(data)
    ↓
Security Rule Checks: request.auth.uid == userId ✅
    ↓
Document created with auto-generated ID
```

### PUT - Updating Transaction
```
User edits transaction & clicks "Update"
    ↓
TransactionProvider.updateTransaction(transaction)
    ↓
TransactionApiService.updateTransaction()
    ↓
Firestore.doc(transactionId).update(newData)
    ↓
Security Rule Checks: request.auth.uid == userId ✅
    ↓
Document updated
```

### DELETE - Removing Transaction
```
User swipes/clicks "Delete" button
    ↓
TransactionProvider.deleteTransaction(transactionId)
    ↓
TransactionApiService.deleteTransaction()
    ↓
Firestore.doc(transactionId).delete()
    ↓
Security Rule Checks: request.auth.uid == userId ✅
    ↓
Document deleted
```

## Step 5: Real-World Best Practices Implemented

✅ **Data Isolation** - Users can only access their own transactions  
✅ **Security Rules** - Server-side validation, not just client-side  
✅ **Sub-collections** - Transactions are nested under users (scalable)  
✅ **Timestamps** - All dates stored in ISO 8601 format  
✅ **Auto IDs** - Firestore generates unique IDs automatically  

## Step 6: Handling Errors in Your App

The TransactionApiService already handles errors:

```dart
try {
  _transactions = await _apiService.getTransactions();
} catch (e) {
  _error = e.toString();  // Shows user-friendly error
  notifyListeners();
}
```

Common errors:
- **"Permission denied"** → Firestore rules issue (check rules)
- **"Failed to connect"** → Internet/Firebase connectivity issue
- **"User not authenticated"** → User needs to login first

## Next Steps in Your App

1. **Optimize queries** - Add pagination for large datasets
2. **Real-time updates** - Use StreamBuilder for live data
3. **Batch operations** - Handle multiple transactions at once
4. **Offline support** - Firestore automatically caches data
5. **Analytics** - Track user spending patterns

---

**That's it! Your REST API is now integrated with Firestore. 🎉**
