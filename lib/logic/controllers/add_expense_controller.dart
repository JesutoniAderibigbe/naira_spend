import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../../data/repositories/expense_repository.dart';
import '../expense_validation.dart';
import '../lagos_time.dart';
import '../money.dart';

/// State for the Add expense form.
class AddExpenseController extends ChangeNotifier {
  AddExpenseController({
    required ExpenseRepository expenses,
    required this._clock,
  }) : _repository = expenses,
       _day = lagosDay(_clock());

  final ExpenseRepository _repository;
  final DateTime Function() _clock;

  String _amount = '';
  String _title = '';
  Category? _category;
  DateTime _day;
  bool _showErrors = false;
  bool _isSaving = false;

  String get amount => _amount;
  String get title => _title;
  Category? get category => _category;

  /// The Lagos day the money was spent (from [lagosDay]); today by default.
  DateTime get day => _day;
  DateTime get now => _clock();
  bool get isSaving => _isSaving;

  /// Errors appear once the user has tried to save.
  String? get amountError => _showErrors ? validateAmount(_amount) : null;
  String? get titleError => _showErrors ? validateTitle(_title) : null;
  String? get categoryError =>
      _showErrors && _category == null ? 'Pick a category' : null;
  String? get dayError => _showErrors ? validateDay(_day, now) : null;

  bool get _isValid =>
      validateAmount(_amount) == null &&
      validateTitle(_title) == null &&
      _category != null &&
      validateDay(_day, now) == null;

  set amount(String value) {
    _amount = formatNairaInput(value);
    notifyListeners();
  }

  set title(String value) {
    _title = value;
    notifyListeners();
  }

  set category(Category? value) {
    _category = value;
    notifyListeners();
  }

  set day(DateTime value) {
    _day = DateTime.utc(value.year, value.month, value.day);
    notifyListeners();
  }

  /// Validates and saves. Returns true when the expense was saved.
  Future<bool> save() async {
    _showErrors = true;
    if (!_isValid || _isSaving) {
      notifyListeners();
      return false;
    }
    _isSaving = true;
    notifyListeners();

    final now = _clock();
    final isToday = _day == lagosDay(now);
    await _repository.addExpense(
      Expense(
        id: '',
        title: _title.trim(),
        amountKobo: parseNairaToKobo(_amount)!,
        category: _category!,
        // Today keeps the real time, for ordering; other days use noon.
        date: isToday
            ? now
            : lagosDayStart(_day).add(const Duration(hours: 12)),
        createdAt: now,
      ),
    );
    _isSaving = false;
    notifyListeners();
    return true;
  }
}
