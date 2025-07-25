// Ensure you have flutter_bloc in your pubspec.yaml and run flutter pub get
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/usecases/add_income_entry.dart';
import '../../domain/usecases/add_expense_entry.dart';
import '../../domain/repositories/finance_repository.dart';

// Events
abstract class FinanceEvent {}

class AddIncome extends FinanceEvent {
  final IncomeEntry entry;
  AddIncome(this.entry);
}

class AddExpense extends FinanceEvent {
  final ExpenseEntry entry;
  AddExpense(this.entry);
}

class LoadEntries extends FinanceEvent {
  final DateTime? month;
  LoadEntries({this.month});
}

// States
abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}

class EntriesLoaded extends FinanceState {
  final List<dynamic> entries;
  EntriesLoaded(this.entries);
}

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
      emit(FinanceLoading());
      try {
        await addIncomeEntry(event.entry);
        emit(FinanceLoaded());
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
    on<AddExpense>((event, emit) async {
      emit(FinanceLoading());
      try {
        await addExpenseEntry(event.entry);
        emit(FinanceLoaded());
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
    on<LoadEntries>((event, emit) async {
      emit(FinanceLoading());
      try {
        final incomes = await repository.getIncomeEntries(month: event.month);
        final expenses = await repository.getExpenseEntries(month: event.month);
        emit(EntriesLoaded([...incomes, ...expenses]));
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });
  }
}
