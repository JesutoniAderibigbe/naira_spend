/// Calendar days and months in Africa/Lagos time.
///
/// Lagos is UTC+1 all year (West Africa Time, no daylight saving), so a
/// fixed offset is exact and no time zone package is needed.
library;

const lagosOffset = Duration(hours: 1);

/// A half-open range of instants: [start] is included, [end] is not.
class InstantRange {
  const InstantRange(this.start, this.end);

  final DateTime start;
  final DateTime end;

  bool contains(DateTime instant) =>
      !instant.isBefore(start) && instant.isBefore(end);
}

/// The Lagos calendar day of [instant], as a UTC date at midnight
/// (e.g. `DateTime.utc(2026, 10, 1)`). Use it as a day key.
DateTime lagosDay(DateTime instant) {
  final wall = instant.toUtc().add(lagosOffset);
  return DateTime.utc(wall.year, wall.month, wall.day);
}

/// The instant when Lagos day [day] (from [lagosDay]) starts.
DateTime lagosDayStart(DateTime day) =>
    DateTime.utc(day.year, day.month, day.day).subtract(lagosOffset);

/// The last [days] Lagos days, ending with the day that contains [now].
InstantRange lagosLastDaysRange(DateTime now, int days) {
  final today = lagosDay(now);
  final end = lagosDayStart(today.add(const Duration(days: 1)));
  final start = lagosDayStart(today.subtract(Duration(days: days - 1)));
  return InstantRange(start, end);
}

/// The Lagos calendar month that contains [now].
InstantRange lagosMonthRange(DateTime now) {
  final today = lagosDay(now);
  return InstantRange(
    lagosDayStart(DateTime.utc(today.year, today.month)),
    lagosDayStart(DateTime.utc(today.year, today.month + 1)),
  );
}
