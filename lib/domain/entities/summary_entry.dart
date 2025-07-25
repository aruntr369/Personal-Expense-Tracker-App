class SummaryEntry {
  final DateTime date;
  final double totalIncome;
  final double totalExpense;
  final List<String> entryIds; // IDs of income/expense entries for the date

  SummaryEntry({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.entryIds,
  });
}
