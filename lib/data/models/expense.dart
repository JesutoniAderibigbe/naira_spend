import 'category.dart';

/// One expense. [date] is the day the money was spent, as an instant;
/// it is grouped into days and months in Africa/Lagos time.
class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amountKobo,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int amountKobo;
  final Category category;
  final DateTime date;
  final DateTime createdAt;
}
