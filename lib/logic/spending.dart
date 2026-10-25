import '../data/models/category.dart';
import '../data/models/expense.dart';
import 'lagos_time.dart';

/// Total spent on one Lagos day.
class DailyTotal {
  const DailyTotal(this.day, this.totalKobo);

  /// Lagos day as a UTC midnight date, from [lagosDay].
  final DateTime day;
  final int totalKobo;

  @override
  bool operator ==(Object other) =>
      other is DailyTotal && other.day == day && other.totalKobo == totalKobo;

  @override
  int get hashCode => Object.hash(day, totalKobo);

  @override
  String toString() => 'DailyTotal($day, $totalKobo)';
}

/// Spending over the last 7 Lagos days, for the Home screen.
class WeeklySummary {
  const WeeklySummary({
    required this.days,
    required this.totalKobo,
    required this.dailyAverageKobo,
  });

  /// Seven days, oldest first, ending today. Days with no spending are 0.
  final List<DailyTotal> days;
  final int totalKobo;

  /// [totalKobo] / 7, rounded to the nearest kobo (halves round up).
  final int dailyAverageKobo;
}

/// Summarises the last 7 Lagos days up to and including the day of [now].
WeeklySummary weeklySummary(Iterable<Expense> expenses, DateTime now) {
  const dayCount = 7;
  final range = lagosLastDaysRange(now, dayCount);
  final firstDay = lagosDay(range.start);
  final totals = List.filled(dayCount, 0);

  for (final expense in expenses) {
    if (!range.contains(expense.date)) continue;
    final index = lagosDay(expense.date).difference(firstDay).inDays;
    totals[index] += expense.amountKobo;
  }

  final total = totals.fold(0, (sum, t) => sum + t);
  return WeeklySummary(
    days: [
      for (var i = 0; i < dayCount; i++)
        DailyTotal(firstDay.add(Duration(days: i)), totals[i]),
    ],
    totalKobo: total,
    dailyAverageKobo: (total * 2 + dayCount) ~/ (dayCount * 2),
  );
}

/// Total per category for expenses in [range]. Every category is present;
/// categories with no spending are 0.
Map<Category, int> categoryTotals(
  Iterable<Expense> expenses,
  InstantRange range,
) {
  final totals = {for (final c in Category.values) c: 0};
  for (final expense in expenses) {
    if (range.contains(expense.date)) {
      totals[expense.category] = totals[expense.category]! + expense.amountKobo;
    }
  }
  return totals;
}

/// Total per category for the Lagos calendar month that contains [now].
Map<Category, int> monthlyCategoryTotals(
  Iterable<Expense> expenses,
  DateTime now,
) => categoryTotals(expenses, lagosMonthRange(now));
