import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/data/models/budget.dart';
import 'package:naira_spend/data/models/category.dart';
import 'package:naira_spend/data/models/expense.dart';
import 'package:naira_spend/data/repositories/firestore_repositories.dart';

final _date = DateTime.utc(2026, 10, 9, 12);

Expense _expense({String id = ''}) => Expense(
  id: id,
  title: 'Suya',
  amountKobo: 250000,
  category: Category.food,
  date: _date,
  createdAt: _date,
);

void main() {
  late FakeFirebaseFirestore db;

  setUp(() => db = FakeFirebaseFirestore());

  group('FirestoreExpenseRepository', () {
    test('writes to users/{uid}/expenses in the data model shape', () async {
      await FirestoreExpenseRepository(db, 'u1').addExpense(_expense());
      await pumpEventQueue();

      final docs = await db.collection('users/u1/expenses').get();
      expect(docs.docs, hasLength(1));
      expect(docs.docs.single.data(), {
        'title': 'Suya',
        'amountKobo': 250000,
        'category': 'food',
        'date': Timestamp.fromDate(_date),
        'createdAt': Timestamp.fromDate(_date),
      });
    });

    test('round-trips through watchExpenses', () async {
      final repo = FirestoreExpenseRepository(db, 'u1');
      await repo.addExpense(_expense(id: 'e1'));
      await pumpEventQueue();

      final [expense] = await repo.watchExpenses().first;
      expect(expense.id, 'e1');
      expect(expense.title, 'Suya');
      expect(expense.amountKobo, 250000);
      expect(expense.category, Category.food);
      expect(expense.date, _date);
    });

    test('keeps users apart', () async {
      await FirestoreExpenseRepository(db, 'u1').addExpense(_expense());
      await pumpEventQueue();
      expect(
        await FirestoreExpenseRepository(db, 'u2').watchExpenses().first,
        isEmpty,
      );
    });

    test('delete removes the document', () async {
      final repo = FirestoreExpenseRepository(db, 'u1');
      await repo.addExpense(_expense(id: 'e1'));
      await repo.deleteExpense('e1');
      await pumpEventQueue();
      expect(await repo.watchExpenses().first, isEmpty);
    });

    test('malformed documents are skipped, not fatal', () async {
      final col = db.collection('users/u1/expenses');
      await col.doc('bad1').set({'title': 'x', 'amountKobo': 1.5});
      await col.doc('bad2').set({
        'title': 'x',
        'amountKobo': 100,
        'category': 'cars',
        'date': Timestamp.fromDate(_date),
      });
      await col.doc('bad3').set({
        'title': 'x',
        'amountKobo': 0,
        'category': 'food',
        'date': Timestamp.fromDate(_date),
      });
      await col
          .doc('ok')
          .set(FirestoreExpenseRepository.toMap(_expense(id: 'ok')));
      final list = await FirestoreExpenseRepository(
        db,
        'u1',
      ).watchExpenses().first;
      expect(list.map((e) => e.id), ['ok']);
    });
  });

  group('FirestoreBudgetRepository', () {
    test('writes users/{uid}/budgets/{category}', () async {
      final repo = FirestoreBudgetRepository(db, 'u1');
      await repo.setLimit(Category.food, 1500000);
      await pumpEventQueue();

      final doc = await db.doc('users/u1/budgets/food').get();
      expect(doc.data(), {'monthlyLimitKobo': 1500000});
      expect(await repo.watchBudgets().first, [
        const Budget(category: Category.food, monthlyLimitKobo: 1500000),
      ]);
    });

    test('a limit of 0 deletes the budget', () async {
      final repo = FirestoreBudgetRepository(db, 'u1');
      await repo.setLimit(Category.food, 1500000);
      await repo.setLimit(Category.food, 0);
      await pumpEventQueue();
      expect((await db.doc('users/u1/budgets/food').get()).exists, isFalse);
    });

    test('unknown categories and bad limits are skipped', () async {
      await db.doc('users/u1/budgets/cars').set({'monthlyLimitKobo': 100});
      await db.doc('users/u1/budgets/fun').set({'monthlyLimitKobo': -5});
      expect(
        await FirestoreBudgetRepository(db, 'u1').watchBudgets().first,
        isEmpty,
      );
    });
  });
}
