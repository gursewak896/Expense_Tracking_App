import 'package:expense_app/core/theme/app_colors.dart';
import 'package:expense_app/core/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // final String username;
  final User? user;

  const CustomAppBar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade200,
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome, ",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  user?.displayName ?? "No name",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return IconButton(
                  icon: Icon(
                    themeProvider.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
