import 'package:intl/intl.dart';

class DateTimeUtils {
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Calculates remaining days in the month including today
  static int getRemainingDaysInMonth([DateTime? target]) {
    final now = target ?? DateTime.now();
    final totalDays = getDaysInMonth(now.year, now.month);
    final remaining = totalDays - now.day + 1;
    return remaining <= 0 ? 1 : remaining;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  static String formatHeader(DateTime date) {
    if (isToday(date)) {
      return 'Hôm nay, ngày ${DateFormat('dd/MM').format(date)}';
    } else if (isYesterday(date)) {
      return 'Hôm qua, ngày ${DateFormat('dd/MM').format(date)}';
    }
    return '${getVietnameseWeekday(date)}, ngày ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  static String getVietnameseWeekday(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
