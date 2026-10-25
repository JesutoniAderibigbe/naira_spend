import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/insights_controller.dart';
import 'package:naira_spend/ui/screens/insights_screen.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);
var _id = 0;

Expense _e(String title, int naira, Category c, DateTime date) => Expense(
  id: '${_id++}',
  title: title,
  amountKobo: naira * 100,
  category: c,
  date: date,
  createdAt: date,
);

void main() {
  Future<void> pump(WidgetTester tester, List<Expense> expenses) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = InsightsController(
      expenses: InMemoryExpenseRepository(expenses),
      clock: () => _now,
    );
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: InsightsScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  final tuesday = DateTime.utc(2026, 10, 6, 11);
  final expenses = [
    _e('Prepaid electricity', 20000, Category.bills, tuesday),
    _e('Phone case', 10000, Category.other, tuesday),
    _e('Groceries', 8800, Category.food, tuesday),
    _e('Cinema', 7000, Category.fun, tuesday),
    _e('Danfo', 5000, Category.transport, tuesday),
    _e('Data', 5000, Category.data, tuesday),
    _e('Old', 9999, Category.food, DateTime.utc(2026, 8, 1)),
  ];

  testWidgets('30 days matches the Figma Insights frame', (tester) async {
    await pump(tester, expenses);

    expect(find.text('Spent in the last 30 days'), findsOneWidget);
    expect(text(tester, 'insights.total'), '₦55,800');
    expect(text(tester, 'insights.count'), 'Across 6 expenses');
    expect(text(tester, 'insights.share.bills'), '₦20,000 · 36%');
    expect(text(tester, 'insights.share.other'), '₦10,000 · 18%');
    expect(text(tester, 'insights.share.data'), '₦5,000 · 9%');

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('insights.biggest')),
      200,
    );
    expect(
      find.text(
        'Your biggest single expense was Prepaid electricity, ₦20,000 '
        'on Tuesday.',
        findRichText: true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('switching period changes the totals', (tester) async {
    await pump(tester, [
      ...expenses,
      _e('Last month', 1000, Category.fun, DateTime.utc(2026, 9, 20)),
    ]);
    expect(text(tester, 'insights.total'), '₦56,800');

    await tester.tap(find.byKey(const ValueKey('insights.period.thisMonth')));
    await tester.pumpAndSettle();
    expect(find.text('Spent this month'), findsOneWidget);
    expect(text(tester, 'insights.total'), '₦55,800');
  });

  testWidgets('no spending shows ₦0 and no tip', (tester) async {
    await pump(tester, []);
    expect(text(tester, 'insights.total'), '₦0');
    expect(text(tester, 'insights.count'), 'Across 0 expenses');
    expect(find.byKey(const ValueKey('insights.empty')), findsOneWidget);
    expect(find.byKey(const ValueKey('insights.biggest')), findsNothing);
  });

  testWidgets('one expense is singular', (tester) async {
    await pump(tester, [_e('Suya', 2500, Category.food, _now)]);
    expect(text(tester, 'insights.count'), 'Across 1 expense');
  });
}
