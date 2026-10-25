import '../models/expense.dart';

/// Reads and writes the signed-in user's expenses.
///
/// The UI and controllers depend on this interface only, so tests and the
/// placeholder build can use [InMemoryExpenseRepository] instead of Firestore.
abstract interface class ExpenseRepository {
  /// Emits the current expenses straight away, then again after every change.
  Stream<List<Expense>> watchExpenses();

  /// Saves [expense]. An empty [Expense.id] gets a new id; an existing id
  /// (e.g. when undoing a delete) is kept.
  Future<void> addExpense(Expense expense);

  Future<void> deleteExpense(String id);
}
