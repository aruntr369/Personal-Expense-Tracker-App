import '../../domain/entities/category_limit.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/transaction.dart';

abstract class FinanceLocalDataSource {
  Future<void> addIncomeEntry(IncomeEntry entry);
  Future<List<IncomeEntry>> getIncomeEntries({DateTime? month});

  Future<void> addExpenseEntry(ExpenseEntry entry);
  Future<List<ExpenseEntry>> getExpenseEntries({DateTime? month});

  Future<List<Transaction>> getTransactions({DateTime? month});

  Future<void> setCategoryLimit(CategoryLimit limit);
  Future<CategoryLimit?> getCategoryLimit(String category);
  Future<List<CategoryLimit>> getAllCategoryLimits();
}
