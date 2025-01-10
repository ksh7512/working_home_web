extension DateTimeExtension on DateTime {
  bool get isWeekend => (weekday == 0 || weekday == 6 || weekday == 7);

  bool isSameCalendar(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get mondayOfWeek => weekday == 1 ? this : subtract(Duration(days: weekday - 1));

  DateTime get sundayOfWeek =>
      weekday == 0 || weekday == 7 ? this : subtract(Duration(days: weekday));
}
