import 'dart:async';

import 'package:expense_app/features/transactions/presentation/screens/expense_form_screen.dart';
import 'package:expense_app/features/transactions/data/models/transaction_model.dart';
import 'package:expense_app/features/transactions/presentation/screens/all_transaction_screen.dart';
import 'package:expense_app/features/auth/presentation/screens/change_pw_screen.dart';
import 'package:expense_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:expense_app/features/auth/presentation/screens/forgot_password.dart';
import 'package:expense_app/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:expense_app/features/auth/data/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _subscription = AuthService().authStateChanges().listen((user) {
      this.user = user;
      initialized = true;
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;
  User? user;
  bool initialized = false;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}

final _AuthRefreshNotifier _authRefreshNotifier = _AuthRefreshNotifier();

final GoRouter appRouter = GoRouter(
  initialLocation: '/loading',
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final location = state.matchedLocation;

    if (!_authRefreshNotifier.initialized) {
      return location == '/loading' ? null : '/loading';
    }

    final isPublicRoute = {
      '/login',
      '/signup',
      '/forgot-password',
    }.contains(location);

    if (_authRefreshNotifier.user == null && !isPublicRoute) {
      return '/login';
    }

    if (_authRefreshNotifier.user != null &&
        (location == '/login' ||
            location == '/forgot-password' ||
            location == '/loading')) {
      return '/home';
    }

    if (_authRefreshNotifier.user == null && location == '/loading') {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/loading',
      builder: (context, state) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPassword(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/transactions',
      name: 'transactions',
      builder: (context, state) => const AllTransactionsPage(),
    ),
    GoRoute(
      path: '/expense/new',
      name: 'expense-form',
      builder: (context, state) {
        final expense = state.extra;
        return ExpenseFormScreen(
          expense: expense is TransactionModel ? expense : null,
          isEdit: expense is TransactionModel,
        );
      },
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
  ],
);
