import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../insights.dart';

/// State for the Insights screen.
class InsightsController extends ChangeNotifier {
  InsightsController({
    required ExpenseRepository expenses,
    required this._clock,
  }) {
    _subscription = expenses.watchExpenses().listen(
      (items) {
        _expenses = items;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _error = error;
        notifyListeners();
      },
    );
  }

  final DateTime Function() _clock;
  late final StreamSubscription<List<Expense>> _subscription;

  List<Expense> _expenses = const [];
  bool _isLoading = true;
  Object? _error;
  InsightsPeriod _period = InsightsPeriod.last30Days;

  bool get isLoading => _isLoading;
  Object? get error => _error;
  DateTime get now => _clock();
  InsightsPeriod get period => _period;

  set period(InsightsPeriod value) {
    if (value == _period) return;
    _period = value;
    notifyListeners();
  }

  InsightsSummary get summary => insightsSummary(_expenses, _period, now);

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
