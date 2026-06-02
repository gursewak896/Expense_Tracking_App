import 'package:intl/intl.dart';

String formatNpr(double value) {
  final absoluteValue = value.abs();
  final isWholeNumber =
      (absoluteValue - absoluteValue.truncateToDouble()).abs() < 0.001;
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: 'NPR ',
    decimalDigits: isWholeNumber ? 0 : 2,
  );

  return formatter.format(value);
}
