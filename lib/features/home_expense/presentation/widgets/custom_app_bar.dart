import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;

  const CustomAppBar({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person, color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hello!",
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                      color: Colors.black87,
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                username,
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.black87),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
