import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator? validator;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.validator,
    required this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true; // State managed internally
  @override
  void initState() {
    super.initState();
    // No need for _isPassword variable—use widget.isPassword directly
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      onChanged: widget.onChanged,
      style: GoogleFonts.poppins(
          fontSize: 12,
          color: theme.textTheme.bodyLarge?.color ?? Colors.black),
      validator: widget.validator,
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscured : false,
      obscuringCharacter: '•',
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: theme.inputDecorationTheme.hintStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor:
            theme.inputDecorationTheme.fillColor ?? const Color(0xFFE9EEFF),
        filled: true,
        prefixIcon: Icon(
          widget.prefixIcon,
          color: theme.inputDecorationTheme.prefixIconColor ??
              theme.iconTheme.color,
        ),
        suffixIcon: widget.isPassword
            ? Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    setState(() {
                      // Ensure isPassword is set
                      _isObscured = !_isObscured; // Toggle internal state
                    });
                  },
                  tooltip: _isObscured ? 'Show password' : 'Hide password',
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
