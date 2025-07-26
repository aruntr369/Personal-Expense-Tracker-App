import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/income_entry.dart';

abstract class FinanceEvent {}

class AddIncome extends FinanceEvent {
  final IncomeEntry entry;
  AddIncome(this.entry);
}

class AddExpense extends FinanceEvent {
  final ExpenseEntry entry;
  AddExpense(this.entry);
}

class LoadEntries extends FinanceEvent {
  final DateTime? month;
  LoadEntries({this.month});
}

class FilterAndSortEntries extends FinanceEvent {
  final String? searchTerm;
  final String? category;
  final DateTime? date;
  final bool? sortAscending;

  FilterAndSortEntries({
    this.searchTerm,
    this.category,
    this.date,
    this.sortAscending,
  });
}

class AddExpenseWithConfirmation extends FinanceEvent {
  final ExpenseEntry entry;
  AddExpenseWithConfirmation(this.entry);
}
