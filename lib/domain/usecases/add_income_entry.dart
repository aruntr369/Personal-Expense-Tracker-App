import '../entities/income_entry.dart';
import '../repositories/finance_repository.dart';

class AddIncomeEntry {
  final FinanceRepository repository;
  AddIncomeEntry(this.repository);

  Future<void> call(IncomeEntry entry) {
    return repository.addIncomeEntry(entry);
  }
}
