import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String date;

  const SectionHeader({
    super.key,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          date,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
