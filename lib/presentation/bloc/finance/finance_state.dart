import '../../../domain/entities/transaction.dart';

abstract class FinanceState {}

class FinanceInitial extends FinanceState {}

class FinanceLoading extends FinanceState {}

class FinanceLoaded extends FinanceState {}

class FinanceError extends FinanceState {
  final String message;
  FinanceError(this.message);
}

class EntriesLoaded extends FinanceState {
  final List<Transaction> entries;
  EntriesLoaded(this.entries);
}
