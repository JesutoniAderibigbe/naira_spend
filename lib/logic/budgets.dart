import '../data/models/budget.dart';
import '../data/models/category.dart';
import 'budget_status.dart';

/// One row on the Budgets screen.
class BudgetLine {
  const BudgetLine({
    required this.category,
    required this.spentKobo,
    required this.limitKobo,
    required this.status,
  });

  final Category category;
  final int spentKobo;
  final int limitKobo;
  final BudgetStatus status;

  /// How full the progress bar is, from 0 to 1 (over budget shows full).
  double get fill => spentKobo >= limitKobo ? 1 : spentKobo / limitKobo;

  bool get isOver => status is BudgetOver;
}

/// A line for every category that has a limit, most used first
/// (by share of the limit, then by name).
List<BudgetLine> budgetLines(
  Iterable<Budget> budgets,
  Map<Category, int> spentByCategory,
) {
  final lines = [
    for (final budget in budgets)
      if (budget.monthlyLimitKobo > 0)
        BudgetLine(
          category: budget.category,
          spentKobo: spentByCategory[budget.category] ?? 0,
          limitKobo: budget.monthlyLimitKobo,
          status: budgetStatus(
            spentKobo: spentByCategory[budget.category] ?? 0,
            limitKobo: budget.monthlyLimitKobo,
          ),
        ),
  ];
  // Compare spent/limit without doubles: a.spent * b.limit vs b.spent * a.limit.
  lines.sort((a, b) {
    final byShare = (b.spentKobo * a.limitKobo).compareTo(
      a.spentKobo * b.limitKobo,
    );
    return byShare != 0 ? byShare : a.category.index - b.category.index;
  });
  return lines;
}

/// Lines that are over budget, most over first. Drives the Budgets alert.
List<BudgetLine> overBudget(Iterable<BudgetLine> lines) {
  final over = lines.where((l) => l.isOver).toList()
    ..sort(
      (a, b) => (b.status as BudgetOver).overByKobo.compareTo(
        (a.status as BudgetOver).overByKobo,
      ),
    );
  return over;
}
