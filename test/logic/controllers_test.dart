import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/budget.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/auth_repository.dart';
import 'package:naira_spend/data/repositories/budget_repository.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/add_expense_controller.dart';
import 'package:naira_spend/logic/controllers/auth_controller.dart';
import 'package:naira_spend/logic/controllers/budgets_controller.dart';

import '../fakes.dart';

// Friday 9 October 2026, 13:00 in Lagos.
final _now = DateTime.utc(2026, 10, 9, 12);

void main() {
  group('AuthController', () {
    test('is not ready until the user is known', () async {
      final auth = AuthController(FakeAuthRepository());
      addTearDown(auth.dispose);
      expect(auth.isReady, isFalse);
      await pumpEventQueue();
      expect(auth.isReady, isTrue);
      expect(auth.user, isNull);
    });

    test('failures become words and clear on retry', () async {
      final repo = FakeAuthRepository();
      final auth = AuthController(repo);
      addTearDown(auth.dispose);
      repo.failNext = const AuthFailure('No connection.');
      await auth.signInAsGuest();
      expect(auth.error, 'No connection.');
      expect(auth.isBusy, isFalse);

      await auth.signInAsGuest();
      await pumpEventQueue();
      expect(auth.error, isNull);
      expect(auth.user!.isGuest, isTrue);
    });
  });

  group('AddExpenseController', () {
    late InMemoryExpenseRepository repo;
    late AddExpenseController form;

    setUp(() {
      repo = InMemoryExpenseRepository();
      form = AddExpenseController(expenses: repo, clock: () => _now);
    });
    tearDown(() => form.dispose());

    Future<List<Expense>> saved() => repo.watchExpenses().first;

    test('no errors are shown until the first save', () async {
      expect(form.amountError, isNull);
      expect(await form.save(), isFalse);
      expect(form.amountError, 'Enter an amount');
      expect(form.categoryError, 'Pick a category');
    });

    test('amount is tidied as it is typed', () {
      form.amount = '012500.999';
      expect(form.amount, '12,500.99');
    });

    test('today keeps the current time', () async {
      form
        ..amount = '100'
        ..title = 'Pure water'
        ..category = Category.other;
      expect(await form.save(), isTrue);
      final [e] = await saved();
      expect(e.date, _now);
      expect(e.amountKobo, 10000);
    });

    test('another day is saved at noon Lagos time', () async {
      form
        ..amount = '100'
        ..title = 'Keke'
        ..category = Category.transport
        ..day = DateTime(2026, 10, 5);
      expect(await form.save(), isTrue);
      final [e] = await saved();
      expect(e.date, DateTime.utc(2026, 10, 5, 11));
      expect(e.createdAt, _now);
    });

    test('a future day is refused', () async {
      form
        ..amount = '100'
        ..title = 'Keke'
        ..category = Category.transport
        ..day = DateTime(2026, 10, 10);
      expect(await form.save(), isFalse);
      expect(form.dayError, "The date can't be in the future");
      expect(await saved(), isEmpty);
    });
  });

  group('BudgetsController', () {
    test('saveLimits writes only what changed', () async {
      final budgets = _RecordingBudgets([
        const Budget(category: Category.food, monthlyLimitKobo: 100),
        const Budget(category: Category.fun, monthlyLimitKobo: 200),
      ]);
      final controller = BudgetsController(
        budgets: budgets,
        expenses: InMemoryExpenseRepository(),
        clock: () => _now,
      );
      addTearDown(controller.dispose);
      await pumpEventQueue();

      await controller.saveLimits({
        Category.food: 100, // unchanged
        Category.fun: 0, // removed
        Category.data: 500, // new
        Category.bills: 0, // still none
      });
      expect(budgets.writes, [(Category.fun, 0), (Category.data, 500)]);
    });

    test('lines use this Lagos month only', () async {
      final controller = BudgetsController(
        budgets: InMemoryBudgetRepository([
          const Budget(category: Category.food, monthlyLimitKobo: 10000),
        ]),
        expenses: InMemoryExpenseRepository([
          Expense(
            id: 'sep',
            title: 'September',
            amountKobo: 9000,
            category: Category.food,
            date: DateTime.utc(2026, 9, 30, 22, 59),
            createdAt: _now,
          ),
          Expense(
            id: 'oct',
            title: 'October',
            amountKobo: 1000,
            category: Category.food,
            date: DateTime.utc(2026, 9, 30, 23),
            createdAt: _now,
          ),
        ]),
        clock: () => _now,
      );
      addTearDown(controller.dispose);
      await pumpEventQueue();
      expect(controller.lines.single.spentKobo, 1000);
    });
  });
}

class _RecordingBudgets extends InMemoryBudgetRepository {
  _RecordingBudgets(super.initial);

  final writes = <(Category, int)>[];

  @override
  Future<void> setLimit(Category category, int monthlyLimitKobo) {
    writes.add((category, monthlyLimitKobo));
    return super.setLimit(category, monthlyLimitKobo);
  }
}
