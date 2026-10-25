import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../spending.dart';

/// State for the Home screen: this week's spending and recent expenses.
class HomeController extends ChangeNotifier {
  HomeController({
    required ExpenseRepository expenses,
    required this._clock,
    this.recentLimit = 5,
  }) : _repository = expenses {
    _subscription = _repository.watchExpenses().listen(
      (items) {
        _expenses = items;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _error = error;
        notifyListeners();
      },
    );
  }

  final ExpenseRepository _repository;
  final DateTime Function() _clock;
  final int recentLimit;
  late final StreamSubscription<List<Expense>> _subscription;

  List<Expense> _expenses = const [];
  bool _isLoading = true;
  Object? _error;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  DateTime get now => _clock();

  WeeklySummary get week => weeklySummary(_expenses, now);

  /// Newest first, by spend date and then by when it was added.
  List<Expense> get recent {
    final sorted = [..._expenses]
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.createdAt.compareTo(a.createdAt);
      });
    return sorted.take(recentLimit).toList();
  }

  Future<void> delete(Expense expense) => _repository.deleteExpense(expense.id);

  /// Puts back an expense removed by [delete] (for "Undo").
  Future<void> restore(Expense expense) => _repository.addExpense(expense);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
