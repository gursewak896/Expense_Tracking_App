import 'package:expense_app/features/home_expense/presentation/screens/home_screen.dart';
import 'package:expense_app/features/login/presentation/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // This "Stream" listens for login/logout events automatically
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🔄 Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // If snapshot has data, the user is logged in
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        // Otherwise, show Login
        return const LoginScreen();
      },
    );
  }
}
