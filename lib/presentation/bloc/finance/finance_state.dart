import 'package:equatable/equatable.dart';

import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/transaction.dart';

abstract class FinanceState extends Equatable {
  const FinanceState();
  @override
  List<Object?> get props => [];
}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {}

class FinanceError extends FinanceState {
  final String message;
  const FinanceError(this.message);
  @override
  List<Object> get props => [message];
}

class EntriesLoaded extends FinanceState {
  final List<Transaction> allEntries;
  final List<Transaction> filteredEntries;

  final String? searchTerm;
  final String? category;
  final DateTime? date;
  final bool sortAscending;

  const EntriesLoaded({
    required this.allEntries,
    required this.filteredEntries,
    this.searchTerm,
    this.category,
    this.date,
    this.sortAscending = false,
  });

  @override
  List<Object?> get props => [
    allEntries,
    filteredEntries,
    searchTerm,
    category,
    date,
    sortAscending,
  ];
}

class ExpenseLimitWarning extends FinanceState {
  final String message;
  final ExpenseEntry expenseToAdd;

  const ExpenseLimitWarning({
    required this.message,
    required this.expenseToAdd,
  });

  @override
  List<Object?> get props => [message, expenseToAdd];
}
