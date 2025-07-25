import '../entities/category_limit.dart';
import '../repositories/finance_repository.dart';

class SetCategoryLimit {
  final FinanceRepository repository;
  SetCategoryLimit(this.repository);

  Future<void> call(CategoryLimit limit) {
    return repository.setCategoryLimit(limit);
  }
}
