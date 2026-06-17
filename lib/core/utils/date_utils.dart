import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _dateFmt = DateFormat('yyyy-MM-dd');
  static final DateFormat _dateCnFmt = DateFormat('yyyy年MM月dd日');
  static final DateFormat _monthDayFmt = DateFormat('MM月dd日');
  static final DateFormat _ymFmt = DateFormat('yyyy年MM月');

  static String formatDate(DateTime date) => _dateFmt.format(date);
  static String formatDateCn(DateTime date) => _dateCnFmt.format(date);
  static String formatMonthDay(DateTime date) => _monthDayFmt.format(date);
  static String formatYearMonth(DateTime date) => _ymFmt.format(date);
  static String today() => formatDate(DateTime.now());

  static DateTime mondayOfWeek([DateTime? date]) {
    final d = date ?? DateTime.now();
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime firstOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  static List<DateTime> dateRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return days;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String friendlyDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) return '今天';
    if (isSameDay(date, now.subtract(const Duration(days: 1)))) return '昨天';
    return formatDate(date);
  }

  static String remainingDays(DateTime deadline) {
    final diff = deadline.difference(DateTime.now()).inDays;
    if (diff > 0) return '剩余$diff天';
    if (diff == 0) return '今天到期';
    return '逾期${-diff}天';
  }
}
