import '../entities/income_entry.dart';
import '../entities/expense_entry.dart';
import '../entities/category_limit.dart';
import '../entities/summary_entry.dart';

abstract class FinanceRepository {
  // Income
  Future<void> addIncomeEntry(IncomeEntry entry);
  Future<List<IncomeEntry>> getIncomeEntries({DateTime? month});

  // Expense
  Future<void> addExpenseEntry(ExpenseEntry entry);
  Future<List<ExpenseEntry>> getExpenseEntries({DateTime? month});

  // Category Limit
  Future<void> setCategoryLimit(CategoryLimit limit);
  Future<CategoryLimit?> getCategoryLimit(String category);
  Future<List<CategoryLimit>> getAllCategoryLimits();

  // Summary
  Future<List<SummaryEntry>> getMonthlySummary(DateTime month);

  // Search, Filter, Sort
  Future<List<dynamic>> searchEntries(String query);
  Future<List<dynamic>> filterEntries({String? category, DateTime? date});
  Future<List<dynamic>> sortEntries({bool ascending});
}
