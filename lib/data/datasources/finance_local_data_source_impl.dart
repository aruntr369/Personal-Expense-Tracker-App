import 'package:hive/hive.dart';

import '../../core/utils/constants/app_constants.dart';
import '../../domain/entities/category_limit.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/transaction.dart';
import '../models/category_limit_model.dart';
import '../models/expense_entry_model.dart';
import '../models/income_entry_model.dart';
import 'finance_local_data_source.dart';

class FinanceLocalDataSourceImpl implements FinanceLocalDataSource {
  @override
  Future<List<Transaction>> getTransactions({DateTime? month}) async {
    final incomes = await getIncomeEntries();

    final expenses = await getExpenseEntries();

    // Combine and sort
    final allTransactions = [...incomes, ...expenses];
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    return allTransactions;
  }

  @override
  Future<void> addIncomeEntry(IncomeEntry entry) async {
    final box = await Hive.openBox<IncomeEntryModel>(HiveNames.incomeBoxName);
    final model = IncomeEntryModel(
      id: entry.id,
      category: entry.category,
      description: entry.description,
      date: entry.date,
      amount: entry.amount,
    );
    await box.put(model.id, model);
  }

  @override
  Future<List<IncomeEntry>> getIncomeEntries({DateTime? month}) async {
    final box = await Hive.openBox<IncomeEntryModel>(HiveNames.incomeBoxName);
    final entries =
        box.values
            .where((e) {
              if (month == null) return true;
              return e.date.year == month.year && e.date.month == month.month;
            })
            .map(
              (e) => IncomeEntry(
                id: e.id,
                category: e.category,
                description: e.description,
                date: e.date,
                amount: e.amount,
              ),
            )
            .toList();
    return entries;
  }

  @override
  Future<void> addExpenseEntry(ExpenseEntry entry) async {
    final box = await Hive.openBox<ExpenseEntryModel>(HiveNames.expenseBoxName);
    final model = ExpenseEntryModel(
      id: entry.id,
      category: entry.category,
      subCategory: entry.subCategory,
      description: entry.description,
      date: entry.date,
      amount: entry.amount,
    );
    await box.put(model.id, model);
  }

  @override
  Future<List<ExpenseEntry>> getExpenseEntries({DateTime? month}) async {
    final box = await Hive.openBox<ExpenseEntryModel>(HiveNames.expenseBoxName);
    final entries =
        box.values
            .where((e) {
              if (month == null) return true;
              return e.date.year == month.year && e.date.month == month.month;
            })
            .map(
              (e) => ExpenseEntry(
                id: e.id,
                category: e.category,
                subCategory: e.subCategory,
                description: e.description,
                date: e.date,
                amount: e.amount,
              ),
            )
            .toList();
    return entries;
  }

  @override
  Future<void> updateCategoryLimit(CategoryLimit categoryLimit) async {
    final box = await Hive.openBox<CategoryLimitModel>(
      HiveNames.categoryLimitBoxName,
    );
    await box.put(
      categoryLimit.category,
      CategoryLimitModel(
        category: categoryLimit.category,
        limitAmount: categoryLimit.limitAmount,
      ),
    );
  }

  @override
  Future<List<CategoryLimit>> getExpenseCategoryLimits() async {
    final box = await Hive.openBox<CategoryLimitModel>(
      HiveNames.categoryLimitBoxName,
    );
    final defaultCategories = CategoryTypes.expense;
    for (var catName in defaultCategories) {
      if (!box.containsKey(catName)) {
        await box.put(
          catName,
          CategoryLimitModel(category: catName, limitAmount: 0.0),
        );
      }
    }
    return box.values.map((model) => model.toDomain()).toList();
  }

  @override
  Future<double> getSpentAmountForCategoryInMonth(
    String categoryName,
    DateTime month,
  ) async {
    final box = await Hive.openBox<ExpenseEntryModel>(HiveNames.expenseBoxName);

    final relevantExpenses = box.values.where(
      (expense) =>
          expense.category == categoryName &&
          expense.date.year == month.year &&
          expense.date.month == month.month,
    );

    final double totalSpent = relevantExpenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );

    return totalSpent;
  }
}
