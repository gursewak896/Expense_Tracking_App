import 'package:expense_app/core/contants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInkwell extends StatelessWidget {
  const CustomInkwell({super.key, required this.text, required this.onTap});
  final VoidCallback? onTap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: Colors.transparent, // removes default grey hover
      splashColor: Colors.transparent, // removes ripple
      highlightColor: Colors.transparent, // removes press bg
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: primaryColor, // default color
          ),
        ),
      ),
    );
  }
}
