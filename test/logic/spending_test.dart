import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/logic/spending.dart';

var _id = 0;

Expense _expense(
  int amountKobo,
  DateTime date, [
  Category category = Category.food,
]) => Expense(
  id: '${_id++}',
  title: 'test',
  amountKobo: amountKobo,
  category: category,
  date: date,
  createdAt: date,
);

void main() {
  group('weeklySummary', () {
    // 10 October 2026, 13:00 in Lagos.
    final now = DateTime.utc(2026, 10, 10, 12);

    test('no expenses gives seven zero days', () {
      final summary = weeklySummary([], now);
      expect(summary.days, hasLength(7));
      expect(summary.days.every((d) => d.totalKobo == 0), isTrue);
      expect(summary.totalKobo, 0);
      expect(summary.dailyAverageKobo, 0);
    });

    test('days run oldest first and end today in Lagos', () {
      final days = weeklySummary([], now).days.map((d) => d.day).toList();
      expect(days.first, DateTime.utc(2026, 10, 4));
      expect(days.last, DateTime.utc(2026, 10, 10));
    });

    test('groups expenses into Lagos days', () {
      final summary = weeklySummary([
        _expense(1000, DateTime.utc(2026, 10, 10, 9)),
        _expense(2500, DateTime.utc(2026, 10, 10, 11)),
        // 23:30 UTC on the 8th is the 9th in Lagos.
        _expense(400, DateTime.utc(2026, 10, 8, 23, 30)),
      ], now);
      expect(summary.days[6], DailyTotal(DateTime.utc(2026, 10, 10), 3500));
      expect(summary.days[5], DailyTotal(DateTime.utc(2026, 10, 9), 400));
      expect(summary.days[4].totalKobo, 0);
      expect(summary.totalKobo, 3900);
    });

    test(
      'includes the first Lagos second of the window, not the one before',
      () {
        final summary = weeklySummary([
          _expense(100, DateTime.utc(2026, 10, 3, 23)), // 4 Oct 00:00 Lagos
          _expense(999, DateTime.utc(2026, 10, 3, 22, 59, 59)), // 3 Oct
        ], now);
        expect(summary.days.first.totalKobo, 100);
        expect(summary.totalKobo, 100);
      },
    );

    test('excludes expenses after today in Lagos', () {
      final summary = weeklySummary([
        _expense(100, DateTime.utc(2026, 10, 10, 22, 59)), // today, 23:59
        _expense(999, DateTime.utc(2026, 10, 10, 23)), // tomorrow
      ], now);
      expect(summary.totalKobo, 100);
    });

    test('daily average is total / 7 rounded to the nearest kobo', () {
      expect(weeklySummary([_expense(700, now)], now).dailyAverageKobo, 100);
      // 1000 / 7 = 142.86
      expect(weeklySummary([_expense(1000, now)], now).dailyAverageKobo, 143);
      // 1002 / 7 = 143.14
      expect(weeklySummary([_expense(1002, now)], now).dailyAverageKobo, 143);
    });

    test('works across a month boundary', () {
      final nov2 = DateTime.utc(2026, 11, 2, 12);
      final summary = weeklySummary([
        _expense(500, DateTime.utc(2026, 10, 27, 8)),
        _expense(300, DateTime.utc(2026, 10, 31, 23, 15)), // 1 Nov Lagos
      ], nov2);
      expect(summary.days.first, DailyTotal(DateTime.utc(2026, 10, 27), 500));
      expect(summary.days[5], DailyTotal(DateTime.utc(2026, 11, 1), 300));
    });
  });

  group('monthlyCategoryTotals', () {
    final now = DateTime.utc(2026, 10, 15);

    test('no expenses gives zero for every category', () {
      final totals = monthlyCategoryTotals([], now);
      expect(totals.keys, unorderedEquals(Category.values));
      expect(totals.values.every((t) => t == 0), isTrue);
    });

    test('sums each category for the Lagos month', () {
      final totals = monthlyCategoryTotals([
        _expense(1000, DateTime.utc(2026, 10, 2), Category.food),
        _expense(2000, DateTime.utc(2026, 10, 20), Category.food),
        _expense(500, DateTime.utc(2026, 10, 5), Category.data),
      ], now);
      expect(totals[Category.food], 3000);
      expect(totals[Category.data], 500);
      expect(totals[Category.bills], 0);
    });

    test('uses Lagos month boundaries, not UTC', () {
      final totals = monthlyCategoryTotals([
        // 1 Oct 00:00 Lagos: October.
        _expense(100, DateTime.utc(2026, 9, 30, 23), Category.fun),
        // 30 Sep 23:59:59 Lagos: September.
        _expense(999, DateTime.utc(2026, 9, 30, 22, 59, 59), Category.fun),
        // 31 Oct 23:59:59 Lagos: October.
        _expense(20, DateTime.utc(2026, 10, 31, 22, 59, 59), Category.fun),
        // 1 Nov 00:00 Lagos: November.
        _expense(999, DateTime.utc(2026, 10, 31, 23), Category.fun),
      ], now);
      expect(totals[Category.fun], 120);
    });

    test('"now" in the first Lagos hour of a month picks the new month', () {
      final firstHourOfNov = DateTime.utc(2026, 10, 31, 23, 30);
      final totals = monthlyCategoryTotals([
        _expense(100, DateTime.utc(2026, 10, 15), Category.bills),
        _expense(40, DateTime.utc(2026, 10, 31, 23, 10), Category.bills),
      ], firstHourOfNov);
      expect(totals[Category.bills], 40);
    });
  });
}
