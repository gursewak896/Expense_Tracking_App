import 'package:expense_app/core/contants.dart';
import 'package:expense_app/features/home_expense/presentation/screens/home_screen.dart';
import 'package:expense_app/features/login/bloc/login_cubit.dart';
import 'package:expense_app/features/login/bloc/login_state.dart';
import 'package:expense_app/features/login/presentation/screens/forgot_password.dart';
import 'package:expense_app/features/login/presentation/screens/signup_screen.dart';
import 'package:expense_app/features/login/widgets/custom_inkwell.dart';
import 'package:expense_app/features/login/widgets/custom_textfield.dart';
import 'package:expense_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(authService: AuthService()),
      child: const _LoginScreenBody(),
    );
  }
}

class _LoginScreenBody extends StatefulWidget {
  const _LoginScreenBody();

  @override
  State<_LoginScreenBody> createState() => _LoginScreenBodyState();
}

class _LoginScreenBodyState extends State<_LoginScreenBody> {
  final GlobalKey<FormState> _loginKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _startLogin() {
    if (_loginKey.currentState?.validate() ?? false) {
      context.read<LoginCubit>().login(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }

        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid email or password'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          final bool isLoading = state is LoginLoading;

          return Scaffold(
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
                    _inputField(context, isLoading),
                    _forgotPassword(context),
                    const SizedBox(height: 16),
                    _signup(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _header(BuildContext context) {
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

  _inputField(BuildContext context, bool isLoading) {
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
              }
              return null;
            },
            prefixIcon: Icons.password,
          ),
          const SizedBox(height: 38),
          ElevatedButton(
            onPressed: isLoading ? null : _startLogin,
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
            child: isLoading
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

  _forgotPassword(BuildContext context) {
    return Center(
      child: CustomInkwell(
          text: "Forgot password?",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const ForgotPassword()));
          }),
    );
  }

  _signup(BuildContext context) {
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
    return Container(
      padding: const EdgeInsets.all(15.00),
      margin: const EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.red,
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(children: <Widget>[
        Container(
          margin: const EdgeInsets.only(right: 6.00),
          child: const Icon(Icons.info, color: Colors.white),
        ),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
      ]),
    );
  }
}
