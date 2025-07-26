import '../../domain/entities/category_limit.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/income_entry.dart';
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
  Future<void> updateCategoryLimit(CategoryLimit categoryLimit) =>
      localDataSource.updateCategoryLimit(categoryLimit);

  @override
  Future<List<CategoryLimit>> getExpenseCategoryLimits() =>
      localDataSource.getExpenseCategoryLimits();

  @override
  Future<double> getSpentAmountForCategoryInMonth(
    String categoryName,
    DateTime month,
  ) => localDataSource.getSpentAmountForCategoryInMonth(categoryName, month);
}
