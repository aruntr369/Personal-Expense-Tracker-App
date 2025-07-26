import 'package:hive/hive.dart';
import 'package:personal_finance_app/domain/entities/category_limit.dart';

part 'category_limit_model.g.dart';

@HiveType(typeId: 2)
class CategoryLimitModel extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final double limitAmount;

  CategoryLimitModel({required this.category, required this.limitAmount});

  CategoryLimit toDomain() =>
      CategoryLimit(category: category, limitAmount: limitAmount);
}
