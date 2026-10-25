import 'category.dart';

/// A monthly spending limit for one category
/// (Firestore: users/{uid}/budgets/{category}).
class Budget {
  const Budget({required this.category, required this.monthlyLimitKobo});

  final Category category;
  final int monthlyLimitKobo;

  @override
  bool operator ==(Object other) =>
      other is Budget &&
      other.category == category &&
      other.monthlyLimitKobo == monthlyLimitKobo;

  @override
  int get hashCode => Object.hash(category, monthlyLimitKobo);
}
