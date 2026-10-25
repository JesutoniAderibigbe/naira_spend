import 'package:flutter_test/flutter_test.dart';
import 'package:naira_spend/logic/budget_status.dart';

void main() {
  group('budgetStatus', () {
    // ₦100 limit.
    BudgetStatus status(int spentKobo) =>
        budgetStatus(spentKobo: spentKobo, limitKobo: 10000);

    test('zero spent is fine with the whole limit left', () {
      expect(status(0), const BudgetFine(10000));
    });

    test('79.99% is fine', () => expect(status(7999), const BudgetFine(2001)));

    test('exactly 80% is near limit', () {
      expect(status(8000), const BudgetNearLimit(2000));
    });

    test('99.99% is near limit', () {
      expect(status(9999), const BudgetNearLimit(1));
    });

    test('exactly 100% is at limit', () {
      expect(status(10000), const BudgetAtLimit());
    });

    test('one kobo over is over by ₦0.01', () {
      expect(status(10001), const BudgetOver(1));
      expect(status(10001).label, 'Over by ₦0.01');
    });

    test('over by ₦50', () {
      expect(status(15000), const BudgetOver(5000));
      expect(status(15000).label, 'Over by ₦50');
    });

    test('80% is exact for limits that do not divide evenly', () {
      // 4 / 5 = 80%; 3 / 4 = 75%; 2 / 3 = 66.7%.
      expect(
        budgetStatus(spentKobo: 4, limitKobo: 5),
        const BudgetNearLimit(1),
      );
      expect(budgetStatus(spentKobo: 3, limitKobo: 4), const BudgetFine(1));
      expect(budgetStatus(spentKobo: 2, limitKobo: 3), const BudgetFine(1));
    });

    test('large amounts do not overflow', () {
      expect(
        budgetStatus(spentKobo: 999999999999900, limitKobo: 999999999999900),
        const BudgetAtLimit(),
      );
    });

    test('a zero or negative limit is an error', () {
      expect(
        () => budgetStatus(spentKobo: 0, limitKobo: 0),
        throwsArgumentError,
      );
      expect(
        () => budgetStatus(spentKobo: 0, limitKobo: -1),
        throwsArgumentError,
      );
    });

    test('negative spending is an error', () {
      expect(() => status(-1), throwsArgumentError);
    });
  });

  group('label matches the Figma Budgets frame', () {
    test('fine shows what is left', () {
      expect(const BudgetFine(300000).label, '₦3,000 left');
    });
    test('near limit', () {
      expect(const BudgetNearLimit(100000).label, 'Near limit · ₦1,000 left');
    });
    test('at limit', () {
      expect(const BudgetAtLimit().label, 'At limit · ₦0 left');
    });
    test('over', () {
      expect(const BudgetOver(200000).label, 'Over by ₦2,000');
      expect(const BudgetOver(125050).label, 'Over by ₦1,250.50');
    });
  });
}
