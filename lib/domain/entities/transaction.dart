import 'package:equatable/equatable.dart';

abstract class Transaction extends Equatable {
  final String id;
  final String category;
  final String? description;
  final DateTime date;
  final double amount;

  const Transaction({
    required this.id,
    required this.category,
    this.description,
    required this.date,
    required this.amount,
  });

  @override
  List<Object?> get props => [id, category, description, date, amount];
}
