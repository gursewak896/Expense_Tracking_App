import 'dart:math' as math;

import 'package:expense_app/core/utils/currency_formatter.dart';
import 'package:expense_app/features/analytics/presentation/statistics/transaction_statistics.dart';
import 'package:flutter/material.dart';

class ExpenseBarChart extends StatelessWidget {
  const ExpenseBarChart({
    super.key,
    required this.buckets,
    required this.color,
  });

  final List<ExpenseBucket> buckets;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    final gridColor = Theme.of(context).dividerColor.withValues(alpha: 0.5);

    return Semantics(
      label: 'Expense trend chart',
      child: SizedBox(
        height: 220,
        width: double.infinity,
        child: CustomPaint(
          painter: _ExpenseBarChartPainter(
            buckets: buckets,
            barColor: color,
            textColor: textColor,
            gridColor: gridColor,
          ),
        ),
      ),
    );
  }
}

class _ExpenseBarChartPainter extends CustomPainter {
  const _ExpenseBarChartPainter({
    required this.buckets,
    required this.barColor,
    required this.textColor,
    required this.gridColor,
  });

  final List<ExpenseBucket> buckets;
  final Color barColor;
  final Color textColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 44.0;
    const right = 8.0;
    const top = 8.0;
    const bottom = 32.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    final maxAmount = buckets.fold<double>(
      0,
      (maximum, bucket) => math.max(maximum, bucket.amount),
    );
    final scaleMax = maxAmount == 0 ? 1.0 : maxAmount;
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (var line = 0; line <= 4; line++) {
      final y = top + chartHeight * line / 4;
      canvas.drawLine(
          Offset(left, y), Offset(size.width - right, y), gridPaint);
      final amountAtLine = scaleMax * (4 - line) / 4;
      _drawText(
        canvas,
        _compactAmount(amountAtLine),
        Offset(0, y - 7),
        textColor,
        fontSize: 10,
        width: left - 6,
        align: TextAlign.right,
      );
    }

    if (buckets.isEmpty) return;

    final slotWidth = chartWidth / buckets.length;
    final barWidth = math.min(28.0, slotWidth * 0.56);
    for (var index = 0; index < buckets.length; index++) {
      final bucket = buckets[index];
      final barHeight = chartHeight * bucket.amount / scaleMax;
      final x = left + slotWidth * index + (slotWidth - barWidth) / 2;
      final y = top + chartHeight - barHeight;
      if (bucket.amount > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, barWidth, barHeight),
            const Radius.circular(5),
          ),
          barPaint,
        );
      }
      _drawText(
        canvas,
        bucket.label,
        Offset(left + slotWidth * index, size.height - bottom + 7),
        textColor,
        fontSize: 10,
        width: slotWidth,
        align: TextAlign.center,
      );
    }
  }

  String _compactAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k';
    return amount.toStringAsFixed(0);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    required double fontSize,
    required double width,
    required TextAlign align,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: 1,
    )..layout(maxWidth: width);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ExpenseBarChartPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.barColor != barColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.gridColor != gridColor;
  }
}

class ExpenseDonutChart extends StatelessWidget {
  const ExpenseDonutChart({
    super.key,
    required this.categories,
    required this.total,
  });

  final List<CategoryExpense> categories;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Expense by category chart',
      child: SizedBox(
        width: 184,
        height: 184,
        child: CustomPaint(
          painter: _ExpenseDonutChartPainter(
            categories: categories,
            total: total,
            trackColor: Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  formatNpr(total),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseDonutChartPainter extends CustomPainter {
  const _ExpenseDonutChartPainter({
    required this.categories,
    required this.total,
    required this.trackColor,
  });

  final List<CategoryExpense> categories;
  final double total;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    const strokeWidth = 20.0;
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    if (total <= 0) return;

    var startAngle = -math.pi / 2;
    for (final category in categories) {
      final sweepAngle = math.pi * 2 * category.amount / total;
      final paint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseDonutChartPainter oldDelegate) {
    return oldDelegate.categories != categories ||
        oldDelegate.total != total ||
        oldDelegate.trackColor != trackColor;
  }
}
