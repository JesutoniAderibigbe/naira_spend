import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/budget.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/budget_repository.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/budgets_controller.dart';
import 'package:naira_spend/ui/screens/budgets_screen.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

final _now = DateTime.utc(2026, 10, 9, 12);
var _id = 0;

Expense _e(int naira, Category c) => Expense(
  id: '${_id++}',
  title: 't',
  amountKobo: naira * 100,
  category: c,
  date: DateTime.utc(2026, 10, 5),
  createdAt: DateTime.utc(2026, 10, 5),
);

Budget _b(Category c, int naira) =>
    Budget(category: c, monthlyLimitKobo: naira * 100);

void main() {
  late InMemoryBudgetRepository budgets;

  Future<void> pump(
    WidgetTester tester, {
    List<Budget> limits = const [],
    List<Expense> spent = const [],
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    budgets = InMemoryBudgetRepository(limits);
    final controller = BudgetsController(
      budgets: budgets,
      expenses: InMemoryExpenseRepository(spent),
      clock: () => _now,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BudgetsScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
  }

  String status(WidgetTester tester, Category c) => tester
      .widget<Text>(find.byKey(ValueKey('budget.${c.name}.status')))
      .data!;

  testWidgets('shows the month, the Figma states and the over alert', (
    tester,
  ) async {
    await pump(
      tester,
      limits: [
        _b(Category.bills, 18000),
        _b(Category.data, 5000),
        _b(Category.transport, 6000),
        _b(Category.fun, 10000),
        _b(Category.food, 15000),
      ],
      spent: [
        _e(20000, Category.bills),
        _e(5000, Category.data),
        _e(5000, Category.transport),
        _e(7000, Category.fun),
        _e(8800, Category.food),
      ],
    );

    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('Bills is ₦2,000 over budget'), findsOneWidget);
    expect(status(tester, Category.bills), 'Over by ₦2,000');
    expect(status(tester, Category.data), 'At limit · ₦0 left');
    expect(status(tester, Category.transport), 'Near limit · ₦1,000 left');
    expect(status(tester, Category.fun), '₦3,000 left');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('budget.food.status')),
      200,
    );
    expect(status(tester, Category.food), '₦6,200 left');
  });

  testWidgets('no alert when nothing is over', (tester) async {
    await pump(
      tester,
      limits: [_b(Category.fun, 100)],
      spent: [_e(50, Category.fun)],
    );
    expect(find.byKey(const ValueKey('budgets.alert')), findsNothing);
  });

  testWidgets('two over budget are summarised', (tester) async {
    await pump(
      tester,
      limits: [_b(Category.fun, 100), _b(Category.food, 100)],
      spent: [_e(200, Category.fun), _e(150, Category.food)],
    );
    expect(find.text('2 categories are over budget'), findsOneWidget);
  });

  testWidgets('Edit sets and clears limits', (tester) async {
    await pump(tester, limits: [_b(Category.fun, 100)]);
    expect(find.byKey(const ValueKey('budget.fun')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('budgets.edit')));
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('budgetEdit.fun')), '');
    await tester.enterText(
      find.byKey(const ValueKey('budgetEdit.food')),
      '15000',
    );
    await tester.tap(find.byKey(const ValueKey('budgetEdit.save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('budget.fun')), findsNothing);
    expect(status(tester, Category.food), '₦15,000 left');
  });

  testWidgets('an invalid limit keeps the sheet open', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('budgets.edit')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('budgetEdit.food')),
      '...',
    );
    await tester.tap(find.byKey(const ValueKey('budgetEdit.save')));
    await tester.pumpAndSettle();
    // "..." is tidied to "." which is not an amount.
    expect(find.text('Enter an amount like 15,000'), findsOneWidget);
  });

  testWidgets('empty state', (tester) async {
    await pump(tester);
    expect(find.byKey(const ValueKey('budgets.empty')), findsOneWidget);
  });
}
