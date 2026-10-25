import 'dart:async';

import '../models/budget.dart';
import '../models/category.dart';
import 'current_then_changes.dart';

/// Reads and writes the signed-in user's monthly limits.
abstract interface class BudgetRepository {
  /// Emits the current budgets straight away, then after every change.
  Stream<List<Budget>> watchBudgets();

  /// Sets the limit for [category]; a limit of 0 removes it.
  Future<void> setLimit(Category category, int monthlyLimitKobo);
}

/// Keeps budgets in memory, for placeholder data and tests.
class InMemoryBudgetRepository implements BudgetRepository {
  InMemoryBudgetRepository([Iterable<Budget> initial = const []])
    : _budgets = {for (final b in initial) b.category: b};

  final Map<Category, Budget> _budgets;
  final _changes = StreamController<List<Budget>>.broadcast();

  List<Budget> get _snapshot => List.unmodifiable(_budgets.values);

  @override
  Stream<List<Budget>> watchBudgets() =>
      currentThenChanges(() => _snapshot, _changes.stream);

  @override
  Future<void> setLimit(Category category, int monthlyLimitKobo) async {
    if (monthlyLimitKobo <= 0) {
      _budgets.remove(category);
    } else {
      _budgets[category] = Budget(
        category: category,
        monthlyLimitKobo: monthlyLimitKobo,
      );
    }
    _changes.add(_snapshot);
  }
}
