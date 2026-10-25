import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/ui/screens/add_expense_screen.dart';
import 'package:naira_spend/ui/theme/app_theme.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);

void main() {
  late InMemoryExpenseRepository repository;
  late List<String?> done;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    repository = InMemoryExpenseRepository();
    done = [];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AddExpenseScreen(
          expenses: repository,
          clock: () => _now,
          onDone: done.add,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Read outside the widget test's fake-async zone, where stream events flow.
  Future<List<Expense>> saved(WidgetTester tester) async =>
      (await tester.runAsync(() => repository.watchExpenses().first))!;

  testWidgets('shows the form with Today as the date', (tester) async {
    await pump(tester);
    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('What did you buy?'), findsOneWidget);
    for (final c in Category.values) {
      expect(find.byKey(ValueKey('category.${c.name}')), findsOneWidget);
    }
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('addExpense.date'))).data,
      'Today',
    );
  });

  testWidgets('groups thousands as you type', (tester) async {
    await pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.amount')),
      '1250.505',
    );
    await tester.pump();
    expect(find.text('1,250.50'), findsOneWidget);
  });

  testWidgets('saving an empty form shows every error and saves nothing', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('addExpense.save')));
    await tester.pumpAndSettle();

    expect(find.text('Enter an amount'), findsOneWidget);
    expect(find.text('Say what you bought'), findsOneWidget);
    expect(find.text('Pick a category'), findsOneWidget);
    expect(await saved(tester), isEmpty);
    expect(done, isEmpty);
  });

  testWidgets('a zero amount is rejected', (tester) async {
    await pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.amount')),
      '0',
    );
    await tester.tap(find.byKey(const ValueKey('addExpense.save')));
    await tester.pumpAndSettle();
    expect(find.text('Amount must be more than ₦0'), findsOneWidget);
  });

  testWidgets('a valid form saves in kobo and finishes', (tester) async {
    await pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.amount')),
      '2500',
    );
    await tester.enterText(
      find.byKey(const ValueKey('addExpense.title')),
      '  Suya ',
    );
    await tester.tap(find.byKey(const ValueKey('category.food')));
    await tester.tap(find.byKey(const ValueKey('addExpense.save')));
    await tester.pumpAndSettle();

    final [expense] = await saved(tester);
    expect(expense.amountKobo, 250000);
    expect(expense.title, 'Suya');
    expect(expense.category, Category.food);
    expect(expense.date, _now);
    expect(done, ['Suya']);
  });

  testWidgets('selected category is marked for screen readers', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('category.bills')));
    await tester.pump();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('category.bills'))),
      matchesSemantics(
        isSelected: true,
        hasSelectedState: true,
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        label: 'Bills',
      ),
    );
  });

  testWidgets('close finishes without saving', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const ValueKey('addExpense.close')));
    expect(done, [null]);
  });
}
