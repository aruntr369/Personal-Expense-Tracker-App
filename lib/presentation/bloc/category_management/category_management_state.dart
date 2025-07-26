import 'package:equatable/equatable.dart';

import '../../../../domain/entities/category_limit.dart';

abstract class CategoryManagementState extends Equatable {
  const CategoryManagementState();
  @override
  List<Object> get props => [];
}

class CategoryManagementInitial extends CategoryManagementState {}

class CategoryManagementLoading extends CategoryManagementState {}

class CategoryManagementError extends CategoryManagementState {
  final String message;
  const CategoryManagementError(this.message);
  @override
  List<Object> get props => [message];
}

class CategoryManagementLoaded extends CategoryManagementState {
  final List<CategoryLimit> categories;
  const CategoryManagementLoaded(this.categories);
  @override
  List<Object> get props => [categories];
}
