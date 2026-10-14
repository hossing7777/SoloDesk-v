import 'package:intl/intl.dart';

/// Small formatting helpers (ISO dates keep PDF/CSV output locale-neutral).
class Fmt {
  Fmt._();

  static final DateFormat _date = DateFormat('yyyy-MM-dd', 'en_US');

  static String money(double v, String currency) => '${v.toStringAsFixed(2)} $currency';

  static String date(int millis) => _date.format(DateTime.fromMillisecondsSinceEpoch(millis));

  static String number(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static String duration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}';
  }

  static double parse(String s) => double.tryParse(s.trim().replaceAll(',', '.')) ?? 0;
}
