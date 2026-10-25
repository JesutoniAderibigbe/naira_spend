import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/budget.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/logic/budget_status.dart';
import 'package:naira_spend/logic/budgets.dart';

Budget _b(Category c, int naira) =>
    Budget(category: c, monthlyLimitKobo: naira * 100);

void main() {
  group('budgetLines', () {
    test('no budgets gives no lines', () {
      expect(budgetLines([], {Category.food: 100}), isEmpty);
    });

    test('matches the Figma Budgets frame, most used first', () {
      final lines = budgetLines(
        [
          _b(Category.food, 15000),
          _b(Category.fun, 10000),
          _b(Category.bills, 18000),
          _b(Category.transport, 6000),
          _b(Category.data, 5000),
        ],
        {
          Category.bills: 2000000,
          Category.data: 500000,
          Category.transport: 500000,
          Category.fun: 700000,
          Category.food: 880000,
        },
      );

      expect(lines.map((l) => l.category), [
        Category.bills,
        Category.data,
        Category.transport,
        Category.fun,
        Category.food,
      ]);
      expect(lines.map((l) => l.status.label), [
        'Over by ₦2,000',
        'At limit · ₦0 left',
        'Near limit · ₦1,000 left',
        '₦3,000 left',
        '₦6,200 left',
      ]);
    });

    test('a category with a limit but no spending is fine', () {
      final [line] = budgetLines([_b(Category.fun, 100)], {});
      expect(line.spentKobo, 0);
      expect(line.status, const BudgetFine(10000));
      expect(line.fill, 0);
    });

    test('fill is capped at 1 when over', () {
      final [line] = budgetLines(
        [_b(Category.fun, 100)],
        {Category.fun: 50000},
      );
      expect(line.fill, 1);
      expect(line.isOver, isTrue);
    });

    test('zero limits are ignored', () {
      expect(budgetLines([_b(Category.fun, 0)], {}), isEmpty);
    });

    test('equal shares are ordered by category', () {
      final lines = budgetLines([
        _b(Category.other, 100),
        _b(Category.food, 100),
      ], {});
      expect(lines.map((l) => l.category), [Category.food, Category.other]);
    });
  });

  test('overBudget lists only over lines, most over first', () {
    final lines = budgetLines(
      [_b(Category.food, 100), _b(Category.fun, 100), _b(Category.data, 100)],
      {Category.food: 10500, Category.fun: 20000, Category.data: 10000},
    );
    expect(overBudget(lines).map((l) => l.category), [
      Category.fun,
      Category.food,
    ]);
  });
}
