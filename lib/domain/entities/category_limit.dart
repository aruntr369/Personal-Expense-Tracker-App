import 'package:equatable/equatable.dart';

class CategoryLimit extends Equatable {
  final String category;
  final double limitAmount;

  const CategoryLimit({required this.category, required this.limitAmount});

  @override
  List<Object?> get props => [category, limitAmount];
}
