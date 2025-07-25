// Run: flutter pub run build_runner build to generate Hive type adapters
import 'package:hive/hive.dart';
part 'income_entry_model.g.dart';

@HiveType(typeId: 0)
class IncomeEntryModel extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String category;
  @HiveField(2)
  String? description;
  @HiveField(3)
  DateTime date;
  @HiveField(4)
  double amount;

  IncomeEntryModel({
    required this.id,
    required this.category,
    this.description,
    required this.date,
    required this.amount,
  });
}
