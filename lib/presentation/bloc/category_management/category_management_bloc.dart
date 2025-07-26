import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/usecases/get_category_limits.dart';
import '../../../../domain/usecases/update_category_limit.dart';
import 'category_management_event.dart';
import 'category_management_state.dart';

class CategoryManagementBloc
    extends Bloc<CategoryManagementEvent, CategoryManagementState> {
  final GetCategoryLimits getCategoryLimits;
  final UpdateCategoryLimit updateCategoryLimit;

  CategoryManagementBloc({
    required this.getCategoryLimits,
    required this.updateCategoryLimit,
  }) : super(CategoryManagementInitial()) {
    on<LoadCategoryLimits>(_onLoadCategoryLimits);
    on<UpdateLimit>(_onUpdateLimit);
  }

  Future<void> _onLoadCategoryLimits(
    LoadCategoryLimits event,
    Emitter<CategoryManagementState> emit,
  ) async {
    emit(CategoryManagementLoading());
    try {
      final categories = await getCategoryLimits();
      emit(CategoryManagementLoaded(categories));
    } catch (e) {
      emit(CategoryManagementError(e.toString()));
    }
  }

  Future<void> _onUpdateLimit(
    UpdateLimit event,
    Emitter<CategoryManagementState> emit,
  ) async {
    try {
      await updateCategoryLimit(event.categoryLimit);
      add(LoadCategoryLimits());
    } catch (e) {
      emit(
        CategoryManagementError("Failed to update limit. Please try again."),
      );
    }
  }
}
