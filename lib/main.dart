import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/injections/dependency_injections.dart';
import 'data/datasources/finance_local_data_source_impl.dart';
import 'data/models/category_limit_model.dart';
import 'data/models/expense_entry_model.dart';
import 'data/models/income_entry_model.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/usecases/add_expense_entry.dart';
import 'domain/usecases/add_income_entry.dart';
import 'presentation/bloc/finance_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(IncomeEntryModelAdapter());
  Hive.registerAdapter(ExpenseEntryModelAdapter());
  Hive.registerAdapter(CategoryLimitModelAdapter());

  // Set up data source, repository, and use cases
  final localDataSource = FinanceLocalDataSourceImpl();
  final repository = FinanceRepositoryImpl(localDataSource);
  final addIncomeEntry = AddIncomeEntry(repository);
  final addExpenseEntry = AddExpenseEntry(repository);

  runApp(
    MyApp(
      addIncomeEntry: addIncomeEntry,
      addExpenseEntry: addExpenseEntry,
      repository: repository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final AddIncomeEntry addIncomeEntry;
  final AddExpenseEntry addExpenseEntry;
  final FinanceRepository repository;
  const MyApp({
    super.key,
    required this.addIncomeEntry,
    required this.addExpenseEntry,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => FinanceBloc(
            addIncomeEntry: addIncomeEntry,
            addExpenseEntry: addExpenseEntry,
            repository: repository,
          ),
      child: MaterialApp.router(
        title: 'Personal Finance App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: appRouter.config(),
      ),
    );
  }
}
