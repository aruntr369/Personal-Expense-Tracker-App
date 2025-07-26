import 'transaction.dart';

class ExpenseEntry extends Transaction {
  final String subCategory;

  const ExpenseEntry({
    required super.id,
    required super.category,
    required this.subCategory,
    super.description,
    required super.date,
    required super.amount,
  });

  @override
  List<Object?> get props => super.props..add(subCategory);
}
