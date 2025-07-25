import 'package:hive/hive.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/entities/category_limit.dart';
import '../models/income_entry_model.dart';
import '../models/expense_entry_model.dart';
import '../models/category_limit_model.dart';
import 'finance_local_data_source.dart';

class FinanceLocalDataSourceImpl implements FinanceLocalDataSource {
  static const String incomeBoxName = 'incomeBox';
  static const String expenseBoxName = 'expenseBox';
  static const String categoryLimitBoxName = 'categoryLimitBox';

  @override
  Future<void> addIncomeEntry(IncomeEntry entry) async {
    final box = await Hive.openBox<IncomeEntryModel>(incomeBoxName);
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
    final box = await Hive.openBox<IncomeEntryModel>(incomeBoxName);
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
    final box = await Hive.openBox<ExpenseEntryModel>(expenseBoxName);
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
    final box = await Hive.openBox<ExpenseEntryModel>(expenseBoxName);
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
  Future<void> setCategoryLimit(CategoryLimit limit) async {
    final box = await Hive.openBox<CategoryLimitModel>(categoryLimitBoxName);
    final model = CategoryLimitModel(
      category: limit.category,
      limitAmount: limit.limitAmount,
    );
    await box.put(model.category, model);
  }

  @override
  Future<CategoryLimit?> getCategoryLimit(String category) async {
    final box = await Hive.openBox<CategoryLimitModel>(categoryLimitBoxName);
    final model = box.get(category);
    if (model == null) return null;
    return CategoryLimit(
      category: model.category,
      limitAmount: model.limitAmount,
    );
  }

  @override
  Future<List<CategoryLimit>> getAllCategoryLimits() async {
    final box = await Hive.openBox<CategoryLimitModel>(categoryLimitBoxName);
    return box.values
        .map(
          (e) =>
              CategoryLimit(category: e.category, limitAmount: e.limitAmount),
        )
        .toList();
  }
}
