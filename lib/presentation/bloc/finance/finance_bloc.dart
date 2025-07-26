// Ensure you have flutter_bloc in your pubspec.yaml and run flutter pub get
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/finance_repository.dart';
import '../../../domain/usecases/add_expense_entry.dart';
import '../../../domain/usecases/add_income_entry.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final AddIncomeEntry addIncomeEntry;
  final AddExpenseEntry addExpenseEntry;
  final FinanceRepository repository;

  FinanceBloc({
    required this.addIncomeEntry,
    required this.addExpenseEntry,
    required this.repository,
  }) : super(FinanceInitial()) {
    on<AddIncome>((event, emit) async {
      try {
        await addIncomeEntry(event.entry);
        add(LoadEntries());
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
    on<AddExpense>((event, emit) async {
      try {
        await addExpenseEntry(event.entry);
        add(LoadEntries());
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
    on<LoadEntries>((event, emit) async {
      emit(FinanceLoading());
      try {
        final transactions = await repository.getTransactions(
          month: event.month,
        );
        emit(EntriesLoaded(transactions));
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
  }
}
