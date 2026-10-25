import '../data/models/category.dart';
import '../data/models/expense.dart';
import 'lagos_time.dart';

/// The periods offered on the Insights screen.
enum InsightsPeriod {
  last7Days('7 days', 'Spent in the last 7 days'),
  last30Days('30 days', 'Spent in the last 30 days'),
  thisMonth('This month', 'Spent this month');

  const InsightsPeriod(this.label, this.heading);

  /// Segment label, e.g. "30 days".
  final String label;

  /// Card heading, e.g. "Spent in the last 30 days".
  final String heading;

  /// The Lagos-time range this period covers, ending today.
  InstantRange range(DateTime now) => switch (this) {
    last7Days => lagosLastDaysRange(now, 7),
    last30Days => lagosLastDaysRange(now, 30),
    thisMonth => lagosMonthRange(now),
  };
}

/// One category's total and share of the period's spending.
class CategoryShare {
  const CategoryShare(this.category, this.totalKobo, this.percent);

  final Category category;
  final int totalKobo;

  /// Whole percent of the period total, rounded half up per category, as in
  /// the Figma Insights frame (so the shares can add up to 99–101%).
  final int percent;

  @override
  bool operator ==(Object other) =>
      other is CategoryShare &&
      other.category == category &&
      other.totalKobo == totalKobo &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(category, totalKobo, percent);

  @override
  String toString() => 'CategoryShare($category, $totalKobo, $percent%)';
}

class InsightsSummary {
  const InsightsSummary({
    required this.totalKobo,
    required this.expenseCount,
    required this.shares,
    required this.biggest,
  });

  final int totalKobo;
  final int expenseCount;

  /// Categories with spending, biggest first. Empty when nothing was spent.
  final List<CategoryShare> shares;

  /// The biggest single expense, or null when there are none.
  final Expense? biggest;
}

InsightsSummary insightsSummary(
  Iterable<Expense> expenses,
  InsightsPeriod period,
  DateTime now,
) {
  final range = period.range(now);
  final inRange = expenses.where((e) => range.contains(e.date)).toList();

  final totals = <Category, int>{};
  for (final e in inRange) {
    totals[e.category] = (totals[e.category] ?? 0) + e.amountKobo;
  }
  final total = totals.values.fold(0, (sum, t) => sum + t);

  final shares =
      [
        for (final MapEntry(key: category, value: amount) in totals.entries)
          if (amount > 0)
            CategoryShare(
              category,
              amount,
              (amount * 200 + total) ~/ (total * 2),
            ),
      ]..sort((a, b) {
        final byTotal = b.totalKobo.compareTo(a.totalKobo);
        return byTotal != 0 ? byTotal : a.category.index - b.category.index;
      });

  Expense? biggest;
  for (final e in inRange) {
    if (biggest == null ||
        e.amountKobo > biggest.amountKobo ||
        (e.amountKobo == biggest.amountKobo && e.date.isAfter(biggest.date))) {
      biggest = e;
    }
  }

  return InsightsSummary(
    totalKobo: total,
    expenseCount: inRange.length,
    shares: shares,
    biggest: biggest,
  );
}
