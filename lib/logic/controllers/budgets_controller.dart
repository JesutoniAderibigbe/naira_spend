import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../data/models/budget.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../budgets.dart';
import '../spending.dart';

/// State for the Budgets screen: this Lagos month's spending against limits.
class BudgetsController extends ChangeNotifier {
  BudgetsController({
    required BudgetRepository budgets,
    required ExpenseRepository expenses,
    required this._clock,
  }) : _budgetRepository = budgets {
    _subscriptions = [
      budgets.watchBudgets().listen((items) {
        _budgets = items;
        _budgetsLoaded = true;
        notifyListeners();
      }, onError: _onError),
      expenses.watchExpenses().listen((items) {
        _expenses = items;
        _expensesLoaded = true;
        notifyListeners();
      }, onError: _onError),
    ];
  }

  final BudgetRepository _budgetRepository;
  final DateTime Function() _clock;
  late final List<StreamSubscription<Object>> _subscriptions;

  List<Budget> _budgets = const [];
  List<Expense> _expenses = const [];
  bool _budgetsLoaded = false;
  bool _expensesLoaded = false;
  Object? _error;

  bool get isLoading => !(_budgetsLoaded && _expensesLoaded) && _error == null;
  Object? get error => _error;
  DateTime get now => _clock();

  /// Current limits, by category.
  Map<Category, int> get limits => {
    for (final b in _budgets) b.category: b.monthlyLimitKobo,
  };

  List<BudgetLine> get lines =>
      budgetLines(_budgets, monthlyCategoryTotals(_expenses, now));

  List<BudgetLine> get over => overBudget(lines);

  /// Saves new limits; categories set to 0 lose their limit.
  Future<void> saveLimits(Map<Category, int> limits) async {
    final current = this.limits;
    for (final MapEntry(key: category, value: kobo) in limits.entries) {
      if ((current[category] ?? 0) != kobo) {
        await _budgetRepository.setLimit(category, kobo);
      }
    }
  }

  void _onError(Object error) {
    _error = error;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }
}
