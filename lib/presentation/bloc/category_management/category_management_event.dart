import 'package:equatable/equatable.dart';

import '../../../../domain/entities/category_limit.dart';

abstract class CategoryManagementEvent extends Equatable {
  const CategoryManagementEvent();
  @override
  List<Object> get props => [];
}

class LoadCategoryLimits extends CategoryManagementEvent {}

class UpdateLimit extends CategoryManagementEvent {
  final CategoryLimit categoryLimit;

  const UpdateLimit(this.categoryLimit);

  @override
  List<Object> get props => [categoryLimit];
}
