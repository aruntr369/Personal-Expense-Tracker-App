import '../entities/category_limit.dart';
import '../repositories/finance_repository.dart';

class UpdateCategoryLimit {
  final FinanceRepository repository;

  UpdateCategoryLimit(this.repository);

  Future<void> call(CategoryLimit categoryLimit) {
    return repository.updateCategoryLimit(categoryLimit);
  }
}
