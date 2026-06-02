import 'package:expense_app/core/contants.dart';
import 'package:expense_app/features/login/presentation/screens/login_screen.dart';
import 'package:expense_app/features/login/widgets/custom_inkwell.dart';
import 'package:expense_app/features/login/widgets/custom_textfield.dart';
import 'package:expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController nameController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final AuthService _authService = AuthService();
  bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();
  double passwordStrength = 0;

  Future<void> _handleSignUp() async {
    // 🔴 STEP 1: VALIDATE PASSWORD MATCH (PUT HERE - TOP)
    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return; // ❗ STOP FUNCTION HERE
    }
    try {
      setState(() {
        _isSubmitting = true;
      });
      // Step 2: Call firebase (only if passwords match)
      final result = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        username: nameController.text.trim(),
      );

      // Step 3: CHECK THE ASYNC GAP (The most important fix)
      if (!mounted) return;

      if (result.success) {
        // Step 4: Show Success SnackBar with requested message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully. Please Log In"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear form
        _formKey.currentState?.reset();
        setState(() {
          passwordStrength = 0;
        });

        // Step 5. Wait briefly so snackbar is visible, then navigate back to login
        await Future.delayed(const Duration(milliseconds: 800));
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // Step 6. Show Error SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void checkPasswordStrength(String value) {
    double strength = 0;

    if (value.length >= 8) strength += 0.3;
    if (RegExp(r'[A-Z]').hasMatch(value)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(value)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      strength += 0.3;
    }

    setState(() {
      passwordStrength = strength.clamp(0, 1);
    });
  }

  Color getStrengthColor() {
    if (passwordStrength < 0.4) {
      return Colors.red;
    } else if (passwordStrength < 0.7) {
      return Colors.orange;
    } else {
      return const Color(0xFF4B3EF5);
    }
  }

  String getStrengthText() {
    if (passwordController.text.isEmpty) {
      return "ENTER A PASSWORD";
    }
    if (passwordStrength < 0.4) {
      return "WEAK PASSWORD";
    } else if (passwordStrength < 0.7) {
      return "MEDIUM PASSWORD";
    } else {
      return "STRONG PASSWORD";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleTextColor =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(170);

    return Scaffold(
      // appBar: appbar(context),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        // height: MediaQuery.of(context).size.height - 50,
        width: double.infinity,
        child: Form(
          key: _formKey,
          child: ScrollConfiguration(
            behavior:
                ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 62.0),
                      _header(context),
                      const SizedBox(height: 26.0),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      textFieldHeader("Name"),
                      const SizedBox(height: 6),
                      CustomTextField(
                          hintText: "Name",
                          controller: nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          prefixIcon: Icons.person),
                      const SizedBox(height: 16),
                      textFieldHeader("Email Address"),
                      const SizedBox(height: 6),
                      CustomTextField(
                          hintText: "Email",
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Email';
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
                          prefixIcon: Icons.email),
                      const SizedBox(height: 16),
                      textFieldHeader("Create Password"),
                      const SizedBox(height: 6),
                      CustomTextField(
                        prefixIcon: Icons.password,
                        hintText: "Password",
                        controller: passwordController,
                        isPassword: true,
                        onChanged: checkPasswordStrength,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else if (value.length < 6) {
                            return "Password should be at least 6 characters";
                          } else if (value.length > 15) {
                            return "Password should not be greater than 15 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: passwordStrength,
                          minHeight: 5,
                          backgroundColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFE7E7EE),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(getStrengthColor()),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        getStrengthText(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: passwordController.text.isEmpty
                              ? subtleTextColor
                              : getStrengthColor(),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      textFieldHeader("Confirm Password"),
                      const SizedBox(height: 6),
                      CustomTextField(
                        prefixIcon: Icons.password,
                        hintText: "Confirm Password",
                        controller: confirmPasswordController,
                        isPassword: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password again';
                          }
                          if (value != passwordController.text) {
                            return 'Password not matched';
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                      padding: const EdgeInsets.only(top: 3, left: 3),
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                // 1. Added 'async' here
                                if (_formKey.currentState!.validate()) {
                                  // 2. Wait for the actual signup result
                                  await _handleSignUp();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: primaryColor,
                          disabledForegroundColor: Colors.white,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : Text(
                                "Sign up",
                                style: GoogleFonts.poppins(
                                    fontSize: 16, color: Colors.white),
                              ),
                      )),
                  const SizedBox(
                    height: 6,
                  ),
                  const Center(child: Text("Or")),
                  const SizedBox(
                    height: 6,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      CustomInkwell(
                          text: "Login Here",
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _header(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "Join Us",
          style: GoogleFonts.poppins(
              fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor),
        ),
        const SizedBox(height: 6),
        Text("Start tracking your expenses today :)",
            style: GoogleFonts.poppins(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}
