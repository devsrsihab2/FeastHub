import 'package:intl/intl.dart';

/// Utility formatters for FeastHub.
class AppFormatters {
  AppFormatters._();

  static final _priceFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Formats a double price as "$12.99"
  static String price(double value) => _priceFormatter.format(value);

  /// Formats a DateTime as "Aug 27, 2026"
  static String date(DateTime dt) => DateFormat('MMM d, yyyy').format(dt);

  /// Formats a DateTime as "Aug 27, 2026 at 3:42 PM"
  static String dateTime(DateTime dt) =>
      DateFormat('MMM d, yyyy • h:mm a').format(dt);

  /// Returns "20 min" or "2 h 30 min"
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  /// Order number display: "#1042"
  static String orderNumber(String id) {
    final shortId = id.replaceAll('-', '').substring(0, 6).toUpperCase();
    return '#$shortId';
  }
}
