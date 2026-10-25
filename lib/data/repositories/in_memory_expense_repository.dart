import 'dart:async';

import '../models/category.dart';
import '../models/expense.dart';
import 'expense_repository.dart';
import 'current_then_changes.dart';

/// Keeps expenses in memory. Used for placeholder data until Firestore is
/// wired up, and as a fake in tests.
class InMemoryExpenseRepository implements ExpenseRepository {
  InMemoryExpenseRepository([Iterable<Expense> initial = const []])
    : _items = [...initial];

  /// Placeholder data shaped like the Figma Home frame: ₦45,800 over the
  /// 7 Lagos days ending on the day of [now], plus one older expense.
  factory InMemoryExpenseRepository.placeholder(DateTime now) {
    // Noon in Lagos (UTC+1) on the day [daysAgo] before [now].
    DateTime lagosNoon(int daysAgo) {
      final wall = now.toUtc().add(const Duration(hours: 1));
      return DateTime.utc(wall.year, wall.month, wall.day - daysAgo, 11);
    }

    var id = 0;
    Expense expense(
      String title,
      int naira,
      Category category,
      int daysAgo, {
      int minutes = 0,
    }) {
      final date = lagosNoon(daysAgo).add(Duration(minutes: minutes));
      return Expense(
        id: 'placeholder-${id++}',
        title: title,
        amountKobo: naira * 100,
        category: category,
        date: date,
        createdAt: date,
      );
    }

    return InMemoryExpenseRepository([
      expense('Jollof rice and chicken', 4500, Category.food, 0, minutes: 30),
      expense('Danfo to Ojota', 1200, Category.transport, 0),
      expense('10GB data bundle', 5000, Category.data, 1),
      expense('Suya', 3800, Category.food, 2),
      expense('Electricity token', 22000, Category.bills, 3),
      expense('Cinema', 3500, Category.fun, 4),
      expense('Groceries', 4800, Category.food, 5),
      expense('Keke to work', 1000, Category.transport, 6),
      expense('Phone case', 2500, Category.other, 10),
    ]);
  }

  final List<Expense> _items;
  final _changes = StreamController<List<Expense>>.broadcast();

  @override
  Stream<List<Expense>> watchExpenses() =>
      currentThenChanges(() => List.unmodifiable(_items), _changes.stream);

  var _nextId = 0;

  @override
  Future<void> addExpense(Expense expense) async {
    _items.add(
      expense.id.isEmpty
          ? Expense(
              id: 'local-${_nextId++}',
              title: expense.title,
              amountKobo: expense.amountKobo,
              category: expense.category,
              date: expense.date,
              createdAt: expense.createdAt,
            )
          : expense,
    );
    _emit();
  }

  @override
  Future<void> deleteExpense(String id) async {
    _items.removeWhere((e) => e.id == id);
    _emit();
  }

  void _emit() => _changes.add(List.unmodifiable(_items));
}
