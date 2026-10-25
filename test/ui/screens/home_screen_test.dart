import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/expense_repository.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/home_controller.dart';
import 'package:naira_spend/ui/screens/home_screen.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);

class _FailingRepository implements ExpenseRepository {
  @override
  Stream<List<Expense>> watchExpenses() => Stream.error(StateError('offline'));
  @override
  Future<void> addExpense(Expense expense) async {}
  @override
  Future<void> deleteExpense(String id) async {}
}

void main() {
  late int addTaps;
  late int accountTaps;

  Future<HomeController> pumpHome(
    WidgetTester tester,
    ExpenseRepository repository, {
    String? displayName = 'Jane Ade',
  }) async {
    // Same size as the Figma frame, so overflows show up here.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    addTaps = 0;
    accountTaps = 0;
    final controller = HomeController(expenses: repository, clock: () => _now);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: HomeScreen(
          controller: controller,
          displayName: displayName,
          onAddExpense: () => addTaps++,
          onAccount: () => accountTaps++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  testWidgets('shows greeting, weekly total and daily average', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository.placeholder(_now));

    expect(find.text('Good afternoon'), findsOneWidget);
    expect(find.text('Your money'), findsOneWidget);
    expect(find.text('JA'), findsOneWidget);
    expect(find.text('Spent this week'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home.weekTotal'))).data,
      '₦45,800',
    );
    // 45,800 / 7 = 6,542.857…, rounded to the nearest kobo.
    expect(find.text('Daily average ₦6,542.86'), findsOneWidget);
  });

  testWidgets('chart shows the last 7 Lagos days, ending today', (
    tester,
  ) async {
    await pumpHome(tester, InMemoryExpenseRepository.placeholder(_now));

    final chart = find.byKey(const ValueKey('home.chart'));
    expect(chart, findsOneWidget);
    for (final day in ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
      expect(
        find.descendant(of: chart, matching: find.text(day)),
        findsOneWidget,
      );
    }
    expect(
      tester.getSemantics(chart).label,
      contains('Tue ₦22,000'),
      reason: 'screen readers get every day and amount',
    );
  });

  testWidgets('lists recent expenses newest first, at most 5', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository.placeholder(_now));

    expect(find.text('Jollof rice and chicken'), findsOneWidget);
    expect(find.text('Food · Today'), findsOneWidget);
    expect(find.text('₦4,500'), findsOneWidget);
    expect(find.text('Data · Yesterday'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsNWidgets(5));

    final jollof = tester.getTopLeft(find.text('Jollof rice and chicken'));
    final danfo = tester.getTopLeft(find.text('Danfo to Ojota'));
    expect(jollof.dy, lessThan(danfo.dy));
  });

  testWidgets('delete removes the expense and Undo brings it back', (
    tester,
  ) async {
    await pumpHome(tester, InMemoryExpenseRepository.placeholder(_now));
    Text total() =>
        tester.widget<Text>(find.byKey(const ValueKey('home.weekTotal')));

    await tester.tap(
      find.byKey(const ValueKey('expense.placeholder-0.delete')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jollof rice and chicken'), findsNothing);
    expect(total().data, '₦41,300');
    expect(find.text('Deleted Jollof rice and chicken'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Jollof rice and chicken'), findsOneWidget);
    expect(total().data, '₦45,800');
  });

  testWidgets('with no expenses shows ₦0 and an empty message', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository());

    expect(find.byKey(const ValueKey('home.empty')), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('home.weekTotal'))).data,
      '₦0',
    );
    expect(find.text('Daily average ₦0'), findsOneWidget);
  });

  testWidgets('guest without a name gets a person icon', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository(), displayName: null);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });

  testWidgets('shows an error when expenses cannot load', (tester) async {
    await pumpHome(tester, _FailingRepository());
    expect(find.byKey(const ValueKey('home.error')), findsOneWidget);
  });

  testWidgets('Add expense button calls onAddExpense', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository());
    await tester.tap(find.byKey(const ValueKey('home.addExpense')));
    expect(addTaps, 1);
  });

  testWidgets('avatar opens the account options', (tester) async {
    await pumpHome(tester, InMemoryExpenseRepository());
    await tester.tap(find.byKey(const ValueKey('home.account')));
    expect(accountTaps, 1);
  });
}
