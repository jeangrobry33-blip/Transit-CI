import 'package:intl/intl.dart';

/// Utilitaires de formatage — devise (FCFA), distances et durées.
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _currency = NumberFormat.decimalPattern('fr_FR');

  static String currency(num amount) => '${_currency.format(amount)} FCFA';

  static String distance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String duration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h${minutes.toString().padLeft(2, '0')}';
    return '$minutes min';
  }

  static String date(DateTime date) => DateFormat('dd MMM yyyy', 'fr_FR').format(date);

  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  static String dateTime(DateTime date) => '${AppFormatters.date(date)} · ${AppFormatters.time(date)}';
}
