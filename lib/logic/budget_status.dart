import 'money.dart';

/// Where a category's spending stands against its monthly limit.
///
/// Under 80% is [BudgetFine], 80% up to (not including) 100% is
/// [BudgetNearLimit], exactly 100% is [BudgetAtLimit] and above 100% is
/// [BudgetOver]. The status is always shown in words ([label]), worded as in
/// the Figma Budgets frame.
sealed class BudgetStatus {
  const BudgetStatus();

  String get label;
}

class BudgetFine extends BudgetStatus {
  const BudgetFine(this.leftKobo);

  final int leftKobo;

  @override
  String get label => '${formatNaira(leftKobo)} left';

  @override
  bool operator ==(Object other) =>
      other is BudgetFine && other.leftKobo == leftKobo;

  @override
  int get hashCode => Object.hash(BudgetFine, leftKobo);
}

class BudgetNearLimit extends BudgetStatus {
  const BudgetNearLimit(this.leftKobo);

  final int leftKobo;

  @override
  String get label => 'Near limit · ${formatNaira(leftKobo)} left';

  @override
  bool operator ==(Object other) =>
      other is BudgetNearLimit && other.leftKobo == leftKobo;

  @override
  int get hashCode => Object.hash(BudgetNearLimit, leftKobo);
}

class BudgetAtLimit extends BudgetStatus {
  const BudgetAtLimit();

  @override
  String get label => 'At limit · ${formatNaira(0)} left';

  @override
  bool operator ==(Object other) => other is BudgetAtLimit;

  @override
  int get hashCode => (BudgetAtLimit).hashCode;
}

class BudgetOver extends BudgetStatus {
  const BudgetOver(this.overByKobo);

  final int overByKobo;

  @override
  String get label => 'Over by ${formatNaira(overByKobo)}';

  @override
  bool operator ==(Object other) =>
      other is BudgetOver && other.overByKobo == overByKobo;

  @override
  int get hashCode => Object.hash(BudgetOver, overByKobo);
}

/// The status of [spentKobo] against a positive [limitKobo].
///
/// Uses integer maths only, so 80% and 100% are exact.
BudgetStatus budgetStatus({required int spentKobo, required int limitKobo}) {
  if (limitKobo <= 0) {
    throw ArgumentError.value(limitKobo, 'limitKobo', 'must be positive');
  }
  if (spentKobo < 0) {
    throw ArgumentError.value(spentKobo, 'spentKobo', 'must not be negative');
  }
  final left = limitKobo - spentKobo;
  if (spentKobo * 100 < limitKobo * 80) return BudgetFine(left);
  if (spentKobo < limitKobo) return BudgetNearLimit(left);
  if (spentKobo == limitKobo) return const BudgetAtLimit();
  return BudgetOver(-left);
}
