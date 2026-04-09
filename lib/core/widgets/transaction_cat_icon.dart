import 'package:flutter/material.dart';

class TransactionCatIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const TransactionCatIcon({
    super.key,
    required this.icon,
    this.color = Colors.blue,
    this.size = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.25),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size * 0.5),
      ),
      child: Icon(
        icon,
        color: color,
        size: size,
      ),
    );
  }
}
