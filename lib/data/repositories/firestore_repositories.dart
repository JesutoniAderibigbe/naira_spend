import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

import '../models/budget.dart';
import '../models/category.dart';
import '../models/expense.dart';
import 'budget_repository.dart';
import 'expense_repository.dart';

final _log = Logger('firestore');

/// users/{uid}/expenses/{expenseId} (docs/DATA_MODEL.md).
///
/// Writes are not awaited until the server confirms them: Firestore applies
/// them to the local cache at once and syncs when online, so the app works
/// offline. Failures are logged.
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(FirebaseFirestore db, String uid)
    : _collection = db.collection('users').doc(uid).collection('expenses');

  final CollectionReference<Map<String, dynamic>> _collection;

  static Map<String, dynamic> toMap(Expense e) => {
    'title': e.title,
    'amountKobo': e.amountKobo,
    'category': e.category.name,
    'date': Timestamp.fromDate(e.date),
    'createdAt': Timestamp.fromDate(e.createdAt),
  };

  /// Returns null for a document that does not match the data model, so one
  /// bad document cannot break the whole list.
  static Expense? fromDoc(String id, Map<String, dynamic> data) {
    final amount = data['amountKobo'];
    final date = data['date'];
    final createdAt = data['createdAt'];
    final category = Category.values.asNameMap()[data['category']];
    if (amount is! int ||
        amount <= 0 ||
        date is! Timestamp ||
        category == null ||
        data['title'] is! String) {
      _log.warning('Skipping malformed expense $id');
      return null;
    }
    return Expense(
      id: id,
      title: data['title'] as String,
      amountKobo: amount,
      category: category,
      date: date.toDate().toUtc(),
      createdAt: (createdAt is Timestamp ? createdAt : date).toDate().toUtc(),
    );
  }

  @override
  Stream<List<Expense>> watchExpenses() => _collection.snapshots().map(
    (snapshot) => [
      for (final doc in snapshot.docs) ?fromDoc(doc.id, doc.data()),
    ],
  );

  @override
  Future<void> addExpense(Expense expense) async {
    final doc = expense.id.isEmpty
        ? _collection.doc()
        : _collection.doc(expense.id);
    doc.set(toMap(expense)).catchError((Object e) {
      _log.severe('Saving expense ${doc.id} failed', e);
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    _collection.doc(id).delete().catchError((Object e) {
      _log.severe('Deleting expense $id failed', e);
    });
  }
}

/// users/{uid}/budgets/{category} (docs/DATA_MODEL.md).
class FirestoreBudgetRepository implements BudgetRepository {
  FirestoreBudgetRepository(FirebaseFirestore db, String uid)
    : _collection = db.collection('users').doc(uid).collection('budgets');

  final CollectionReference<Map<String, dynamic>> _collection;

  static Budget? fromDoc(String id, Map<String, dynamic> data) {
    final category = Category.values.asNameMap()[id];
    final limit = data['monthlyLimitKobo'];
    if (category == null || limit is! int || limit <= 0) {
      _log.warning('Skipping malformed budget $id');
      return null;
    }
    return Budget(category: category, monthlyLimitKobo: limit);
  }

  @override
  Stream<List<Budget>> watchBudgets() => _collection.snapshots().map(
    (snapshot) => [
      for (final doc in snapshot.docs) ?fromDoc(doc.id, doc.data()),
    ],
  );

  @override
  Future<void> setLimit(Category category, int monthlyLimitKobo) async {
    final doc = _collection.doc(category.name);
    final write = monthlyLimitKobo <= 0
        ? doc.delete()
        : doc.set({'monthlyLimitKobo': monthlyLimitKobo});
    write.catchError((Object e) {
      _log.severe('Saving budget ${category.name} failed', e);
    });
  }
}
