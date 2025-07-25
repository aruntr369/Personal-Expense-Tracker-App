// Run: flutter pub run build_runner build to generate Hive type adapters
import 'package:hive/hive.dart';
part 'category_limit_model.g.dart';

@HiveType(typeId: 2)
class CategoryLimitModel extends HiveObject {
  @HiveField(0)
  String category;
  @HiveField(1)
  double limitAmount;

  CategoryLimitModel({required this.category, required this.limitAmount});
}
