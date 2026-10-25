/// Short words shown next to data: greetings, day names, initials.
/// Times are read in Africa/Lagos time.
library;

import 'lagos_time.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdaysLong = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', //
  'Friday', 'Saturday', 'Sunday',
];
const _monthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// "Good morning" before 12:00, "Good afternoon" before 17:00, otherwise
/// "Good evening", by the Lagos clock.
String greetingFor(DateTime now) {
  final hour = now.toUtc().add(lagosOffset).hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// Short weekday name ("Mon") of a Lagos day from [lagosDay].
String weekdayShort(DateTime day) => _weekdays[day.weekday - 1];

/// "Today", "Yesterday", or a date such as "Mon 5 Oct", by Lagos day.
String relativeDayLabel(DateTime date, DateTime now) {
  final day = lagosDay(date);
  final daysAgo = lagosDay(now).difference(day).inDays;
  if (daysAgo == 0) return 'Today';
  if (daysAgo == 1) return 'Yesterday';
  return '${weekdayShort(day)} ${day.day} ${_months[day.month - 1]}';
}

/// Up to two capital initials from a name: "Jane Ade" → "JA".
/// Returns an empty string when there is no name.
String initialsFor(String? name) {
  final words = (name ?? '').trim().split(RegExp(r'\s+'));
  return words
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();
}

/// "October 2026": the Lagos month and year of [now].
String monthYearLabel(DateTime now) {
  final day = lagosDay(now);
  return '${_monthsLong[day.month - 1]} ${day.year}';
}

/// When something happened, to finish a sentence: "today", "yesterday",
/// "on Tuesday" within the last week, otherwise "on 5 Oct".
String dayPhrase(DateTime date, DateTime now) {
  final day = lagosDay(date);
  final daysAgo = lagosDay(now).difference(day).inDays;
  if (daysAgo == 0) return 'today';
  if (daysAgo == 1) return 'yesterday';
  if (daysAgo > 1 && daysAgo < 7) return 'on ${_weekdaysLong[day.weekday - 1]}';
  return 'on ${day.day} ${_months[day.month - 1]}';
}

/// Lagos day as a label for the date row: "Today", "Yesterday" or
/// "Mon 5 Oct". [day] is from [lagosDay].
String dateRowLabel(DateTime day, DateTime now) =>
    relativeDayLabel(lagosDayStart(day).add(const Duration(hours: 12)), now);
