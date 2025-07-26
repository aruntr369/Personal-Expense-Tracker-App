import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/injections/dependency_injections.dart';
import 'core/styles/app_theme.dart';
import 'data/models/category_limit_model.dart';
import 'data/models/expense_entry_model.dart';
import 'data/models/income_entry_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  await Hive.initFlutter();
  Hive.registerAdapter(IncomeEntryModelAdapter());
  Hive.registerAdapter(ExpenseEntryModelAdapter());
  Hive.registerAdapter(CategoryLimitModelAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FinFlow',
      theme: AppTheme.theme,
      routerConfig: appRouter.config(),
    );
  }
}
