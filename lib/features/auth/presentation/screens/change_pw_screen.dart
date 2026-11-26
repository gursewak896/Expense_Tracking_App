import 'package:expense_app/features/auth/data/auth_service.dart';
import 'package:expense_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isChangingPassword = false;
  bool isSendingResetEmail = false;
  double passwordStrength = 0;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
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
      return AppColors.primary;
    }
  }

  String getStrengthText() {
    if (newPasswordController.text.isEmpty) {
      return "ENTER A NEW PASSWORD";
    }
    if (passwordStrength < 0.4) {
      return "WEAK PASSWORD";
    } else if (passwordStrength < 0.7) {
      return "MEDIUM PASSWORD";
    } else {
      return "STRONG PASSWORD";
    }
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate() || isChangingPassword) return;

    setState(() {
      isChangingPassword = true;
    });

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (result.success) {
        currentPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();
        setState(() {
          passwordStrength = 0;
        });
        Navigator.maybePop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not change password. Please try again"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isChangingPassword = false;
        });
      }
    }
  }

  Future<void> sendResetEmail() async {
    if (isSendingResetEmail) return;

    setState(() {
      isSendingResetEmail = true;
    });

    try {
      final result = await _authService.sendCurrentUserPasswordResetEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingResetEmail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtleTextColor =
        Theme.of(context).textTheme.bodySmall?.color?.withAlpha(170);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          "Change Password",
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                color: sectionColor,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 22,
                  horizontal: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "Update Security",
                      style: GoogleFonts.poppins(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Choose a strong new password for your account.",
                      style: GoogleFonts.poppins(
                        color: subtleTextColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                color: sectionColor,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, "Current Password"),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      controller: currentPasswordController,
                      hintText: "Enter current password",
                      obscureText: obscureCurrent,
                      onToggle: () {
                        setState(() {
                          obscureCurrent = !obscureCurrent;
                        });
                      },
                      prefixIcon: Icons.key_outlined,
                    ),
                    const SizedBox(height: 18),
                    _buildLabel(context, "New Password"),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      controller: newPasswordController,
                      hintText: "Enter new password",
                      obscureText: obscureNew,
                      prefixIcon: Icons.lock_outline,
                      onChanged: checkPasswordStrength,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Field cannot be empty";
                        }
                        if (value.trim().length < 6) {
                          return "Password should be at least 6 characters";
                        }
                        if (value.trim() ==
                            currentPasswordController.text.trim()) {
                          return "New password must be different";
                        }
                        return null;
                      },
                      onToggle: () {
                        setState(() {
                          obscureNew = !obscureNew;
                        });
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
                        color: newPasswordController.text.isEmpty
                            ? subtleTextColor
                            : getStrengthColor(),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildLabel(context, "Confirm New Password"),
                    const SizedBox(height: 10),
                    _buildPasswordField(
                      controller: confirmPasswordController,
                      hintText: "Confirm new password",
                      obscureText: obscureConfirm,
                      prefixIcon: Icons.lock_person_outlined,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Field cannot be empty";
                        }
                        if (value.trim() != newPasswordController.text.trim()) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                      onToggle: () {
                        setState(() {
                          obscureConfirm = !obscureConfirm;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: isChangingPassword ? null : changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    icon: isChangingPassword
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline, size: 22),
                    label: Text(
                      isChangingPassword ? "Changing..." : "Change Password",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: isSendingResetEmail ? null : sendResetEmail,
                  child: Text(
                    isSendingResetEmail
                        ? "Sending reset email..."
                        : "Reset password via email",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: Theme.of(context).textTheme.titleMedium?.color,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required IconData prefixIcon,
    required String hintText,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return "Field cannot be empty";
            }
            return null;
          },
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5FA),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150),
          size: 20,
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(150),
            size: 20,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}
