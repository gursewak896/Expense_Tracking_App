// Custom text widget function
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget customText(String text) {
  return Text(
    text,
    style: GoogleFonts.poppins(
      textStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  );
}

Text bNavText(BuildContext context, String text) {
  // Get the current theme's text style for bodyLarge
  final TextStyle themeStyle =
      Theme.of(context).textTheme.bodyLarge ?? const TextStyle();

  // Combine GoogleFonts with theme text style
  return Text(
    text,
    style: GoogleFonts.poppins(
      textStyle: themeStyle.copyWith(
        // color: Colors.black, // Override color if needed
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );
}
