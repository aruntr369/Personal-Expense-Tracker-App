import 'package:get_it/get_it.dart';
import 'package:personal_finance_app/data/datasources/finance_local_data_source.dart'; // Use the abstract class
import 'package:personal_finance_app/data/datasources/finance_local_data_source_impl.dart';
import 'package:personal_finance_app/data/repositories/finance_repository_impl.dart';
import 'package:personal_finance_app/domain/repositories/finance_repository.dart';
import 'package:personal_finance_app/domain/usecases/add_expense_entry.dart';
import 'package:personal_finance_app/domain/usecases/add_income_entry.dart';
import 'package:personal_finance_app/presentation/bloc/finance/finance_bloc.dart';

import '../../domain/usecases/get_category_limits.dart';
import '../../domain/usecases/update_category_limit.dart';
import '../../presentation/bloc/category_management/category_management_bloc.dart';
import '../routes/app_router.dart';

final sl = GetIt.instance;
AppRouter appRouter = AppRouter();

void setupLocator() {
  sl.registerFactory(
    () => FinanceBloc(
      addIncomeEntry: sl(),
      addExpenseEntry: sl(),
      repository: sl(),
    ),
  );

  sl.registerLazySingleton(() => AddIncomeEntry(sl()));
  sl.registerLazySingleton(() => AddExpenseEntry(sl()));

  sl.registerFactory(
    () => CategoryManagementBloc(
      getCategoryLimits: sl(),
      updateCategoryLimit: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCategoryLimits(sl()));
  sl.registerLazySingleton(() => UpdateCategoryLimit(sl()));

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<FinanceLocalDataSource>(
    () => FinanceLocalDataSourceImpl(),
  );
}
