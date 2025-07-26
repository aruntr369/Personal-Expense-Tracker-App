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
