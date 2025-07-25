class ExpenseEntry {
  final String id;
  final String category;
  final String subCategory;
  final String? description;
  final DateTime date;
  final double amount;

  ExpenseEntry({
    required this.id,
    required this.category,
    required this.subCategory,
    this.description,
    required this.date,
    required this.amount,
  });
}
