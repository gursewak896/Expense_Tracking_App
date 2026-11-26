import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const CustomFloatingButton(
      {super.key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF4B3CF0),
      shape: const CircleBorder(),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 28,
        color: Colors.white,
      ),
    );
  }
}
