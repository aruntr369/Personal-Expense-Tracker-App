// Run: flutter pub run build_runner build to generate Hive type adapters
import 'package:hive/hive.dart';
part 'expense_entry_model.g.dart';

@HiveType(typeId: 1)
class ExpenseEntryModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String category;
  @HiveField(2)
  String subCategory;
  @HiveField(3)
  String? description;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  double amount;

  ExpenseEntryModel({
    required this.id,
    required this.category,
    required this.subCategory,
    this.description,
    required this.date,
    required this.amount,
  });
}
