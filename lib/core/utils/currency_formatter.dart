import 'package:intl/intl.dart';

final NumberFormat _wholeCurrencyFormatter = NumberFormat.currency(
  locale: 'en_US',
  symbol: 'NPR ',
  decimalDigits: 0,
);

final NumberFormat _decimalCurrencyFormatter = NumberFormat.currency(
  locale: 'en_US',
  symbol: 'NPR ',
  decimalDigits: 2,
);

String formatNpr(double value) {
  final absoluteValue = value.abs();
  final isWholeNumber =
      (absoluteValue - absoluteValue.truncateToDouble()).abs() < 0.001;
  final formatter =
      isWholeNumber ? _wholeCurrencyFormatter : _decimalCurrencyFormatter;

  return formatter.format(value);
}
