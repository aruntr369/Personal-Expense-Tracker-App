import '../../domain/entities/category_limit.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/summary_entry.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_local_data_source.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceLocalDataSource localDataSource;
  FinanceRepositoryImpl(this.localDataSource);

  @override
  Future<List<Transaction>> getTransactions({DateTime? month}) {
    return localDataSource.getTransactions(month: month);
  }

  @override
  Future<void> addIncomeEntry(IncomeEntry entry) =>
      localDataSource.addIncomeEntry(entry);

  @override
  Future<List<IncomeEntry>> getIncomeEntries({DateTime? month}) =>
      localDataSource.getIncomeEntries(month: month);

  @override
  Future<void> addExpenseEntry(ExpenseEntry entry) =>
      localDataSource.addExpenseEntry(entry);

  @override
  Future<List<ExpenseEntry>> getExpenseEntries({DateTime? month}) =>
      localDataSource.getExpenseEntries(month: month);

  @override
  Future<void> setCategoryLimit(CategoryLimit limit) =>
      localDataSource.setCategoryLimit(limit);

  @override
  Future<CategoryLimit?> getCategoryLimit(String category) =>
      localDataSource.getCategoryLimit(category);

  @override
  Future<List<CategoryLimit>> getAllCategoryLimits() =>
      localDataSource.getAllCategoryLimits();

  @override
  Future<List<SummaryEntry>> getMonthlySummary(DateTime month) async {
    // Implement summary logic here or delegate to localDataSource
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> searchEntries(String query) {
    // Implement search logic
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> filterEntries({String? category, DateTime? date}) {
    // Implement filter logic
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> sortEntries({bool ascending = true}) {
    // Implement sort logic
    throw UnimplementedError();
  }
}
