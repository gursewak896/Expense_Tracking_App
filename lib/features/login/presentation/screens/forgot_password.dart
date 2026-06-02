import 'package:expense_app/core/contants.dart';
import 'package:expense_app/features/login/presentation/screens/login_screen.dart';
import 'package:expense_app/features/login/widgets/custom_inkwell.dart';
import 'package:expense_app/features/login/widgets/custom_textfield.dart';
import 'package:expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleResetPassword() async {
    // setState(() => _hasAttempted = true);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authService.resetPassword(
      email: emailController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSnackBar(result.message, Colors.green);
      Navigator.pop(context); // Go back to Login
    } else {
      _showSnackBar("Error: ${result.message}", Colors.redAccent);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Reset Password",
          style: GoogleFonts.poppins(textStyle: const TextStyle(fontSize: 18)),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
          iconSize: 18,
          color: primaryColor,
          padding: const EdgeInsets.only(left: 6),
          alignment: Alignment.center,
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 22),
              _header(context),
              const SizedBox(height: 32),
              _login(context)
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            "Forgot your Password ?",
            style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color),
          ),
          // const SizedBox(height: 2),
          Text("No Worries!",
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor)),
          const SizedBox(height: 10),
          Text(
              "Enter your email and we'll send you a link to reset your password",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  // fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color)),
          const SizedBox(height: 18),
          Text("EMAIL ADDRESS",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 6),
          CustomTextField(
            hintText: "Email",
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              // This Regex checks for standard email patterns (name@domain.com)
              bool emailValid = RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                  .hasMatch(value);
              if (!emailValid) {
                return 'Please enter a valid email';
              }
              return null;
            },
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            // () {
            //   if (_formKey.currentState!.validate()) {
            //     _handleResetPassword;
            //   }
            // },
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              "Send Reset Link",
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  _login(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Remember Password?",
            style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12)),
        const SizedBox(width: 6),
        CustomInkwell(
            text: "Login Here",
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            }),
      ],
    );
  }
}
