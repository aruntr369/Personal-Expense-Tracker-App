import 'transaction.dart';

class IncomeEntry extends Transaction {
  const IncomeEntry({
    required super.id,
    required super.category,
    super.description,
    required super.date,
    required super.amount,
  });
}
