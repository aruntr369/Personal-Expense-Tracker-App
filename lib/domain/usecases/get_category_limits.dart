import '../entities/category_limit.dart';
import '../repositories/finance_repository.dart';

class GetCategoryLimits {
  final FinanceRepository repository;

  GetCategoryLimits(this.repository);

  Future<List<CategoryLimit>> call() {
    return repository.getExpenseCategoryLimits();
  }
}
