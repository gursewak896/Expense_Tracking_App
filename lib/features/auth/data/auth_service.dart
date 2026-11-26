import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/auth_result.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔐 SIGN UP
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name and send email verification in the background
      // (don't await) to avoid blocking the signup response for the user.
      credential.user?.updateDisplayName(username).catchError((e) {
        // ignore background error
      });
      credential.user?.sendEmailVerification().catchError((e) {
        // ignore background error
      });

      return AuthResult(
        success: true,
        message: "Account created successfully. Verify your email.",
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: e.message ?? "Signup failed",
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Unexpected error occurred",
      );
    }
  }

  // =========================
  // 🔑 LOGIN
  // =========================
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return AuthResult(
        success: true,
        message: "Login successful",
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: e.message ?? "Login failed",
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Unexpected error occurred",
      );
    }
  }

  // =========================
  // 🚪 LOGOUT
  // =========================
  Future<AuthResult> logout() async {
    try {
      await _auth.signOut();

      return AuthResult(
        success: true,
        message: "Logged out successfully",
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Logout failed",
      );
    }
  }

  // =========================
  // 🔁 RESET PASSWORD
  // =========================
  Future<AuthResult> resetPassword({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      return AuthResult(
        success: true,
        message: "Password reset email sent",
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: e.message ?? "Reset failed",
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Unexpected error occurred",
      );
    }
  }

  // =========================
  // CHANGE PASSWORD
  // =========================
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      final email = user?.email;
      final apiKey = Firebase.app().options.apiKey;

      if (user == null || email == null) {
        return AuthResult(
          success: false,
          message: "No signed-in user found",
        );
      }

      final signInResponse = await http
          .post(
            Uri.parse(
              "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey",
            ),
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": email,
              "password": currentPassword,
              "returnSecureToken": true,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final signInBody = jsonDecode(signInResponse.body);

      if (signInResponse.statusCode != 200) {
        return AuthResult(
          success: false,
          message: _restPasswordErrorMessage(signInBody),
        );
      }

      final idToken = signInBody["idToken"] as String?;

      if (idToken == null || idToken.isEmpty) {
        return AuthResult(
          success: false,
          message: "Could not verify current password",
        );
      }

      final updateResponse = await http
          .post(
            Uri.parse(
              "https://identitytoolkit.googleapis.com/v1/accounts:update?key=$apiKey",
            ),
            headers: const {"Content-Type": "application/json"},
            body: jsonEncode({
              "idToken": idToken,
              "password": newPassword,
              "returnSecureToken": true,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (updateResponse.statusCode != 200) {
        return AuthResult(
          success: false,
          message: _restPasswordErrorMessage(jsonDecode(updateResponse.body)),
        );
      }

      try {
        await user.reload().timeout(const Duration(seconds: 10));
      } catch (_) {
        // The password update already succeeded. A local user refresh failure
        // should not turn a successful password change into an error.
      }

      return AuthResult(
        success: true,
        message: "Password changed successfully",
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(
        success: false,
        message: _passwordErrorMessage(e),
      );
    } on TimeoutException {
      return AuthResult(
        success: false,
        message: "Request timed out. Please check your internet and try again",
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: "Unexpected error occurred",
      );
    }
  }

  String _restPasswordErrorMessage(dynamic body) {
    String? code;

    if (body is Map<String, dynamic>) {
      final error = body["error"];
      if (error is Map<String, dynamic>) {
        code = error["message"]?.toString();
      }
    }

    switch (code) {
      case "INVALID_LOGIN_CREDENTIALS":
      case "INVALID_PASSWORD":
        return "Current password is incorrect";
      case "EMAIL_NOT_FOUND":
      case "USER_NOT_FOUND":
        return "No account found for this user";
      case "WEAK_PASSWORD : Password should be at least 6 characters":
      case "WEAK_PASSWORD":
        return "New password is too weak";
      case "USER_DISABLED":
        return "This account has been disabled";
      case "TOO_MANY_ATTEMPTS_TRY_LATER":
        return "Too many attempts. Please try again later";
      default:
        return code ?? "Password change failed";
    }
  }

  Future<AuthResult> sendCurrentUserPasswordResetEmail() async {
    final email = _auth.currentUser?.email;

    if (email == null || email.isEmpty) {
      return AuthResult(
        success: false,
        message: "No email found for this account",
      );
    }

    return resetPassword(email: email);
  }

  String _passwordErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case "wrong-password":
      case "invalid-credential":
        return "Current password is incorrect";
      case "weak-password":
        return "New password is too weak";
      case "requires-recent-login":
        return "Please log in again before changing your password";
      case "too-many-requests":
        return "Too many attempts. Please try again later";
      case "network-request-failed":
        return "Network error. Please check your connection";
      default:
        return e.message ?? "Password change failed";
    }
  }

  // =========================
  // 👤 CURRENT USER
  // =========================
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // =========================
  // Auth state stream used by the app router.
  // =========================
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
