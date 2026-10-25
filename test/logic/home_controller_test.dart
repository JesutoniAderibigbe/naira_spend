import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/in_memory_expense_repository.dart';
import 'package:naira_spend/logic/controllers/home_controller.dart';

final _now = DateTime.utc(2026, 10, 9, 12);

Expense _expense(String id, DateTime date, {DateTime? createdAt}) => Expense(
  id: id,
  title: id,
  amountKobo: 100,
  category: Category.other,
  date: date,
  createdAt: createdAt ?? date,
);

void main() {
  test('starts loading, then has data', () async {
    final controller = HomeController(
      expenses: InMemoryExpenseRepository(),
      clock: () => _now,
    );
    addTearDown(controller.dispose);
    expect(controller.isLoading, isTrue);
    await pumpEventQueue();
    expect(controller.isLoading, isFalse);
    expect(controller.week.totalKobo, 0);
  });

  test('recent is newest first, ties broken by createdAt, limited', () async {
    final day = DateTime.utc(2026, 10, 9, 11);
    final controller = HomeController(
      expenses: InMemoryExpenseRepository([
        _expense('old', DateTime.utc(2026, 10, 1)),
        _expense('a', day, createdAt: day),
        _expense('b', day, createdAt: day.add(const Duration(minutes: 1))),
        _expense('newest', DateTime.utc(2026, 10, 9, 11, 30)),
      ]),
      clock: () => _now,
      recentLimit: 3,
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    expect(controller.recent.map((e) => e.id), ['newest', 'b', 'a']);
  });

  test('delete and restore update the summary', () async {
    final repository = InMemoryExpenseRepository.placeholder(_now);
    final controller = HomeController(expenses: repository, clock: () => _now);
    addTearDown(controller.dispose);
    await pumpEventQueue();
    expect(controller.week.totalKobo, 4580000);

    final jollof = controller.recent.first;
    await controller.delete(jollof);
    await pumpEventQueue();
    expect(controller.week.totalKobo, 4580000 - jollof.amountKobo);

    await controller.restore(jollof);
    await pumpEventQueue();
    expect(controller.week.totalKobo, 4580000);
  });

  test('placeholder data matches the Figma Home frame', () async {
    final controller = HomeController(
      expenses: InMemoryExpenseRepository.placeholder(_now),
      clock: () => _now,
    );
    addTearDown(controller.dispose);
    await pumpEventQueue();

    expect(controller.week.totalKobo, 4580000); // ₦45,800
    expect(controller.recent.first.title, 'Jollof rice and chicken');
  });
}
