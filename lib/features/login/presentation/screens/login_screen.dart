import 'package:expense_app/core/contants.dart';
import 'package:expense_app/features/home_expense/presentation/screens/home_screen.dart';
import 'package:expense_app/features/login/presentation/screens/forgot_password.dart';
import 'package:expense_app/features/login/presentation/screens/signup_screen.dart';
import 'package:expense_app/features/login/widgets/custom_inkwell.dart';
import 'package:expense_app/features/login/widgets/custom_textfield.dart';
import 'package:expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  String errormsg = "";
  bool error = false, showprogress = false;
  String username = "", password = "";
  bool hasAttemptedLogin = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> startLogin() async {
    if (showprogress) return;

    setState(() {
      showprogress = true;
      error = false;
    });

    try {
      // 1. Single call to the service
      final result = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return; // Safety check for async transitions

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // 2. Direct SnackBar call on failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          showprogress = false;
        });
      }
    }
  }

  // void _showErrorSnackBar(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.redAccent,
  //       behavior: SnackBarBehavior.floating,
  //       margin: const EdgeInsets.all(15),
  //     ),
  //   );
  // }

  final _loginKey = GlobalKey<FormState>();

  @override
  void initState() {
    username = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: appbar(context),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 62),
              _header(context),
              const SizedBox(height: 32),
              _inputField(context),
              _forgotPassword(context),
              const SizedBox(height: 16),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.account_balance_wallet,
              size: 20, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          "Welcome Back",
          style: GoogleFonts.poppins(
              fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 6),
        Text("Manage your expenses effortlessly.",
            style: GoogleFonts.poppins(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color)),
      ],
    );
  }

  _inputField(context) {
    return Form(
      key: _loginKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const SizedBox(height: 10),
          Text("PASSWORD",
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color)),
          const SizedBox(height: 6),
          CustomTextField(
            hintText: "Password",
            controller: passwordController,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your Password';
              } else if (passwordController.text != value) {
                return "Password Incorrect";
              }
              return null;
            },
            prefixIcon: Icons.password,
          ),
          const SizedBox(height: 38),
          ElevatedButton(
            onPressed: showprogress
                ? null
                : () {
                    if (_loginKey.currentState!.validate()) {
                      startLogin();
                    }
                  },
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: primaryColor,
              disabledForegroundColor: Colors.white,
            ),
            child: showprogress
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    "Login",
                    style: GoogleFonts.poppins(fontSize: 16),
                  ),
          ),
          const SizedBox(
            height: 32,
          ),
        ],
      ),
    );
  }

  _forgotPassword(context) {
    return Center(
      child: CustomInkwell(
          text: "Forgot password?",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ForgotPassword()));
          }),
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Dont have an account?",
            style: GoogleFonts.poppins(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12)),
        const SizedBox(width: 6),
        CustomInkwell(
            text: "Sign Up",
            onTap: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignupPage()));
            }),
      ],
    );
  }

  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: const EdgeInsets.all(15.00),
      margin: const EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red, width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
        //show error message text
      ]),
    );
  }
}
