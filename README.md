# Expense Tracker App

A cross-platform personal finance app built with **Flutter** and **Firebase**. Track income and expenses, see where your money goes with charts, and get a daily reminder to log your spending, all backed by a real-time cloud database with secure per-user accounts.

> Currency is displayed in **NPR**. Daily reminders are currently supported on **Android**.

<!-- Add screenshots here, e.g.
<p align="center">
  <img src="screenshots/home.png" width="220" />
  <img src="screenshots/stats.png" width="220" />
  <img src="screenshots/profile.png" width="220" />
</p>
-->

## Features

### Authentication
- Email and password **sign up** and **login** with Firebase Authentication
- **Forgot password** flow
- **Change password** with re-authentication of the current password
- Automatic routing between login and home based on auth state
- Per-user data isolation: every user only sees their own transactions

### Transactions
- Add, edit and delete **income** and **expense** transactions
- **Category** selection with icons and colors
- Form validation before saving
- **Real-time sync** with Cloud Firestore, so changes appear instantly
- **Offline-friendly cache** that loads saved data immediately on launch
- Filter the full transaction list by **All / Income / Expense**
- Balance card with income and expense totals

### Statistics
- Expense breakdown by **week, month and year**
- **Bar chart** and **donut chart** by category, drawn with Flutter's `CustomPaint` (no chart library)
- Unit-tested aggregation logic, including UTC vs local date handling

### Daily reminders (push notifications)
- **Local scheduled notifications** that remind you to log your expenses
- Turn the reminder on or off and pick the **time** from the Profile screen
- Survives phone **reboots** and app updates
- **Smart skip:** no reminder on days you have already added an expense
- Android 13+ notification permission handling
- Reminder is cancelled on logout

### UI
- Light and dark themes
- Bottom navigation with Home, Stats and Profile tabs
- Reusable widget library (cards, list tiles, filter tabs, app bar, and more)

## Tech stack

| Area | Technology |
|---|---|
| Framework | **Flutter** |
| Language | **Dart** |
| Authentication | **Firebase Authentication** (email and password) |
| Database | **Cloud Firestore** (real-time streams) |
| State management | **Provider** (transactions, theme, reminder settings) and **Bloc / Cubit** (login flow) |
| Local storage | **shared_preferences** (offline cache and settings) |
| Notifications | **flutter_local_notifications**, **timezone**, **flutter_timezone** |
| Networking | **http** (Firebase Identity Toolkit REST API for password verification) |
| Utilities | **intl** (formatting), **uuid** (IDs), **equatable**, **google_fonts** |
| Testing | **flutter_test** |

## Architecture

The project uses a feature-first structure with a clear split between UI, state and services.

```
lib/
├── main.dart                  # Firebase init, providers, theming
├── wrapper.dart               # AuthWrapper: login state decides the screen
├── services/
│   ├── auth_service.dart              # Firebase Auth operations
│   ├── transaction_api_service.dart   # Firestore CRUD + live stream
│   └── notification_service.dart      # Scheduled local notifications
├── core/
│   ├── providers/             # TransactionProvider, ThemeProvider, NotificationProvider
│   ├── theme/                 # Colors and light/dark themes
│   ├── utils/                 # Currency formatter
│   └── widgets/               # Shared UI components
└── features/
    ├── login/                 # Login, signup, forgot password (Cubit)
    ├── home_expense/          # Home, stats, profile, change password
    └── expense_form/          # Add / edit expense form and category picker
```

### How it works
1. `main()` initializes Firebase and the notification service, then registers the providers.
2. `AuthWrapper` listens to `FirebaseAuth.authStateChanges()` and shows either the login flow or the home screen.
3. `LoginCubit` handles login and emits Loading, Success or Failure states.
4. On home load, `TransactionProvider` reads the local cache, then subscribes to the user's Firestore collection (`users/{uid}/transactions`) and refreshes the cache on every update.
5. Adding, editing or deleting goes through `TransactionApiService`, and the Firestore stream pushes the result back to the UI.
6. `NotificationProvider` stores the reminder settings and schedules one notification per upcoming day, leaving out today if an expense has already been logged.

## Getting started

### Prerequisites
- Flutter SDK (Dart 3.4.4 or newer)
- Android Studio with **Android SDK Platform 37** installed
- A Firebase project

### Setup
1. **Clone the repo**
   ```bash
   git clone https://github.com/gursewak896/Expense_Tracking_App.git
   cd Expense_Tracking_App
   ```
2. **Install dependencies**
   ```bash
   flutter pub get
   ```
3. **Connect your own Firebase project**
   - Create a project in the [Firebase console](https://console.firebase.google.com/)
   - Enable **Authentication → Email/Password**
   - Create a **Cloud Firestore** database (see `FIRESTORE_SETUP.md` for rules and structure)
   - Generate the config with the FlutterFire CLI:
     ```bash
     dart pub global activate flutterfire_cli
     flutterfire configure
     ```
4. **Run the app**
   ```bash
   flutter run
   ```

### Android notes
- `compileSdk` is set to 37 and **core library desugaring** is enabled, both required by the notification dependencies.
- Notification permission, boot receivers and alarm receivers are declared in `AndroidManifest.xml`.

## Testing

```bash
flutter test
```

Current coverage focuses on the statistics logic (`transaction_statistics_test.dart`). A manual checklist is available in `TESTING_CHECKLIST.md`.

## Documentation

| File | Contents |
|---|---|
| `FIRESTORE_SETUP.md` | Firestore structure and setup |
| `API_REFERENCE.md` | Service layer reference |
| `REST_API_IMPLEMENTATION.md` | REST integration notes |
| `IMPLEMENTATION_QUICK_START.md` | Quick start for contributors |
| `TESTING_CHECKLIST.md` | Manual test checklist |

## Roadmap
- [ ] Monthly budgets per category with budget alerts
- [ ] Tap a reminder to open the Add Expense screen
- [ ] Search and advanced filters
- [ ] Recurring expenses
- [ ] CSV / PDF export
- [ ] iOS notification support
- [ ] Expanded unit and widget test coverage
