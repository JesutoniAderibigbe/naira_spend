import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/logic/insights.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);
var _id = 0;

Expense _e(int naira, Category category, DateTime date) => Expense(
  id: '${_id++}',
  title: 'e$_id',
  amountKobo: naira * 100,
  category: category,
  date: date,
  createdAt: date,
);

void main() {
  group('insightsSummary', () {
    test('no expenses gives zero, no shares and no biggest', () {
      final s = insightsSummary([], InsightsPeriod.last30Days, _now);
      expect(s.totalKobo, 0);
      expect(s.expenseCount, 0);
      expect(s.shares, isEmpty);
      expect(s.biggest, isNull);
    });

    test('matches the Figma Insights frame (30 days, ₦55,800)', () {
      final day = DateTime.utc(2026, 10, 6, 11); // Tuesday
      final expenses = [
        _e(20000, Category.bills, day),
        _e(10000, Category.other, day),
        _e(4400, Category.food, day),
        _e(4400, Category.food, day),
        _e(3500, Category.fun, day),
        _e(3500, Category.fun, day),
        _e(5000, Category.transport, day),
        _e(2500, Category.data, day),
        _e(2500, Category.data, day),
      ];
      final s = insightsSummary(expenses, InsightsPeriod.last30Days, _now);

      expect(s.totalKobo, 5580000);
      expect(s.expenseCount, 9);
      expect(s.shares, [
        const CategoryShare(Category.bills, 2000000, 36),
        const CategoryShare(Category.other, 1000000, 18),
        const CategoryShare(Category.food, 880000, 16),
        const CategoryShare(Category.fun, 700000, 13),
        const CategoryShare(Category.transport, 500000, 9),
        const CategoryShare(Category.data, 500000, 9),
      ]);
      expect(s.biggest!.amountKobo, 2000000);
    });

    test('a single category is 100%', () {
      final s = insightsSummary(
        [_e(100, Category.fun, _now)],
        InsightsPeriod.last7Days,
        _now,
      );
      expect(s.shares, [const CategoryShare(Category.fun, 10000, 100)]);
    });

    test('percent rounds half up', () {
      // 1 of 8 = 12.5% → 13; 7 of 8 = 87.5% → 88.
      final s = insightsSummary(
        [_e(1, Category.fun, _now), _e(7, Category.food, _now)],
        InsightsPeriod.last7Days,
        _now,
      );
      expect(s.shares.map((x) => x.percent), [88, 13]);
    });

    test('7 days uses Lagos day boundaries', () {
      final s = insightsSummary(
        [
          _e(100, Category.fun, DateTime.utc(2026, 10, 2, 23)), // 3 Oct Lagos
          _e(999, Category.fun, DateTime.utc(2026, 10, 2, 22, 59)), // 2 Oct
        ],
        InsightsPeriod.last7Days,
        _now,
      );
      expect(s.totalKobo, 10000);
    });

    test('30 days includes 30 Lagos days ending today', () {
      final s = insightsSummary(
        [
          _e(100, Category.fun, DateTime.utc(2026, 9, 10, 11)), // day 30
          _e(999, Category.fun, DateTime.utc(2026, 9, 9, 11)), // day 31
        ],
        InsightsPeriod.last30Days,
        _now,
      );
      expect(s.totalKobo, 10000);
    });

    test('this month starts on the 1st in Lagos', () {
      final s = insightsSummary(
        [
          _e(100, Category.fun, DateTime.utc(2026, 9, 30, 23)), // 1 Oct
          _e(999, Category.fun, DateTime.utc(2026, 9, 30, 22, 59)), // 30 Sep
        ],
        InsightsPeriod.thisMonth,
        _now,
      );
      expect(s.totalKobo, 10000);
    });

    test('biggest ties go to the most recent', () {
      final older = _e(500, Category.fun, DateTime.utc(2026, 10, 5));
      final newer = _e(500, Category.food, DateTime.utc(2026, 10, 7));
      final s = insightsSummary([older, newer], InsightsPeriod.last7Days, _now);
      expect(s.biggest, same(newer));
    });
  });

  test('period labels and headings', () {
    expect(InsightsPeriod.values.map((p) => p.label), [
      '7 days',
      '30 days',
      'This month',
    ]);
    expect(InsightsPeriod.last30Days.heading, 'Spent in the last 30 days');
    expect(InsightsPeriod.thisMonth.heading, 'Spent this month');
  });
}
