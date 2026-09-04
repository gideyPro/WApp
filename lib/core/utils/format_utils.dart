import 'package:intl/intl.dart';

/// Formats a number with thousands separators.
/// Shows decimal places only when the value has a fractional part.
/// Example: 1500000 → "1,500,000", 1500000.50 → "1,500,000.5"
String smartDecimal(num value) {
  if (value == value.roundToDouble()) {
    return NumberFormat('#,###', 'en_US').format(value.toInt());
  }
  return NumberFormat('#,###.##', 'en_US').format(value);
}
