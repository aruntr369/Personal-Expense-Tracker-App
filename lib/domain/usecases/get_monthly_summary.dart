import '../entities/summary_entry.dart';
import '../repositories/finance_repository.dart';

class GetMonthlySummary {
  final FinanceRepository repository;
  GetMonthlySummary(this.repository);

  Future<List<SummaryEntry>> call(DateTime month) {
    return repository.getMonthlySummary(month);
  }
}
