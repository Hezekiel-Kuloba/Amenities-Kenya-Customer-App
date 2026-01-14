import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    final eatFormat = DateFormat('yyyy-MM-dd HH:mm', 'en_US');
    final eatTimeZone = DateTime.now()
        .toUtc()
        .add(const Duration(hours: 3)); // EAT is UTC+3
    return eatFormat.format(dateTime.toLocal());
  }

  static String formatDate(DateTime dateTime) {
    final eatFormat = DateFormat('yyyy-MM-dd', 'en_US');
    return eatFormat.format(dateTime.toLocal());
  }

  static String formatTime(DateTime dateTime) {
    final eatFormat = DateFormat('HH:mm', 'en_US');
    return eatFormat.format(dateTime.toLocal());
  }
}