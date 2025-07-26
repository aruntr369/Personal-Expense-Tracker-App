import '../entities/category_limit.dart';
import '../entities/expense_entry.dart';
import '../entities/income_entry.dart';
import '../entities/transaction.dart';

abstract class FinanceRepository {
  // Income
  Future<void> addIncomeEntry(IncomeEntry entry);
  Future<List<IncomeEntry>> getIncomeEntries({DateTime? month});

  // Expense
  Future<void> addExpenseEntry(ExpenseEntry entry);
  Future<List<ExpenseEntry>> getExpenseEntries({DateTime? month});

  Future<List<Transaction>> getTransactions({DateTime? month});

  // Category Limit
  Future<void> updateCategoryLimit(CategoryLimit categoryLimit);
  Future<List<CategoryLimit>> getExpenseCategoryLimits();
  Future<double> getSpentAmountForCategoryInMonth(
    String categoryName,
    DateTime month,
  );
}
