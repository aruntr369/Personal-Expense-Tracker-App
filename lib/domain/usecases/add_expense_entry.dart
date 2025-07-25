import '../entities/expense_entry.dart';
import '../repositories/finance_repository.dart';

class AddExpenseEntry {
  final FinanceRepository repository;
  AddExpenseEntry(this.repository);

  Future<void> call(ExpenseEntry entry) {
    return repository.addExpenseEntry(entry);
  }
}
