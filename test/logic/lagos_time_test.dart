import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/logic/lagos_time.dart';

void main() {
  group('lagosDay', () {
    test('23:00 UTC is already the next Lagos day', () {
      expect(
        lagosDay(DateTime.utc(2026, 9, 30, 23)),
        DateTime.utc(2026, 10, 1),
      );
    });

    test('22:59:59 UTC is still the same Lagos day', () {
      expect(
        lagosDay(DateTime.utc(2026, 9, 30, 22, 59, 59)),
        DateTime.utc(2026, 9, 30),
      );
    });

    test('local DateTimes are converted to UTC first', () {
      final instant = DateTime.utc(2026, 10, 10, 23, 30);
      expect(lagosDay(instant.toLocal()), DateTime.utc(2026, 10, 11));
    });
  });

  group('lagosMonthRange', () {
    test('starts at Lagos midnight on the 1st and ends on the next 1st', () {
      final range = lagosMonthRange(DateTime.utc(2026, 10, 15));
      expect(range.start, DateTime.utc(2026, 9, 30, 23));
      expect(range.end, DateTime.utc(2026, 10, 31, 23));
    });

    test('the first Lagos hour of a month belongs to that month', () {
      // 2026-10-31 23:30 UTC is 1 November 00:30 in Lagos.
      final range = lagosMonthRange(DateTime.utc(2026, 10, 31, 23, 30));
      expect(range.start, DateTime.utc(2026, 10, 31, 23));
      expect(range.end, DateTime.utc(2026, 11, 30, 23));
    });

    test('December rolls over to January', () {
      final range = lagosMonthRange(DateTime.utc(2026, 12, 10));
      expect(range.start, DateTime.utc(2026, 11, 30, 23));
      expect(range.end, DateTime.utc(2026, 12, 31, 23));
    });

    test('start is included and end is excluded', () {
      final range = lagosMonthRange(DateTime.utc(2026, 10, 15));
      expect(range.contains(range.start), isTrue);
      expect(range.contains(range.end), isFalse);
    });
  });

  group('lagosLastDaysRange', () {
    test('7 days ending with today in Lagos', () {
      final range = lagosLastDaysRange(DateTime.utc(2026, 10, 10, 12), 7);
      expect(range.start, DateTime.utc(2026, 10, 3, 23));
      expect(range.end, DateTime.utc(2026, 10, 10, 23));
    });

    test('just after Lagos midnight, today is the new day', () {
      final range = lagosLastDaysRange(DateTime.utc(2026, 10, 10, 23, 1), 7);
      expect(range.start, DateTime.utc(2026, 10, 4, 23));
      expect(range.end, DateTime.utc(2026, 10, 11, 23));
    });

    test('crosses a month boundary', () {
      final range = lagosLastDaysRange(DateTime.utc(2026, 11, 2, 12), 7);
      expect(lagosDay(range.start), DateTime.utc(2026, 10, 27));
    });
  });
}
