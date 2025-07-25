class IncomeEntry {
  final String id;
  final String category;
  final String? description;
  final DateTime date;
  final double amount;

  IncomeEntry({
    required this.id,
    required this.category,
    this.description,
    required this.date,
    required this.amount,
  });
}
