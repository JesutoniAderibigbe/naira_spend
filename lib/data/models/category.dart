/// Spending categories. The names match the Firestore `category` values.
enum Category {
  food('Food'),
  transport('Transport'),
  data('Data'),
  bills('Bills'),
  fun('Fun'),
  other('Other');

  const Category(this.label);

  /// Name shown to the user.
  final String label;
}
