// Ensure you have flutter_bloc in your pubspec.yaml and run flutter pub get
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/category_limit.dart';
import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/transaction.dart';
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
        // Fetch category limits
        final categoryLimits = await repository.getExpenseCategoryLimits();
        final categoryLimit = categoryLimits.firstWhere(
          (c) => c.category == event.entry.category,
          orElse:
              () => CategoryLimit(
                category: event.entry.category,
                limitAmount: 0.0,
              ),
        );

        // Check if a limit is set (limitAmount > 0)
        if (categoryLimit.limitAmount > 0) {
          final spentAmount = await repository.getSpentAmountForCategoryInMonth(
            event.entry.category,
            event.entry.date,
          );

          // Use your property name: limitAmount
          if ((spentAmount + event.entry.amount) > categoryLimit.limitAmount) {
            emit(
              ExpenseLimitWarning(
                message:
                    'Adding this expense will exceed your monthly limit for ${categoryLimit.category}.',
                expenseToAdd: event.entry,
              ),
            );
            return;
          }
        }

        await addExpenseEntry(event.entry);
        add(LoadEntries());
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });

    on<AddExpenseWithConfirmation>((event, emit) async {
      await addExpenseEntry(event.entry);
      add(LoadEntries());
    });

    on<LoadEntries>((event, emit) async {
      emit(FinanceLoading());
      try {
        final transactions = await repository.getTransactions(
          month: event.month,
        );
        final categoryLimits = await repository.getExpenseCategoryLimits();

        final List<CategoryLimit> exceededLimits = [];
        for (var limit in categoryLimits) {
          // Only check categories that have a limit set
          if (limit.limitAmount > 0) {
            // Calculate total spent for this category
            double totalSpent = transactions
                .whereType<ExpenseEntry>()
                .where((e) => e.category == limit.category)
                .fold(0.0, (sum, item) => sum + item.amount);

            if (totalSpent > limit.limitAmount) {
              exceededLimits.add(limit);
            }
          }
        }

        transactions.sort((a, b) => b.date.compareTo(a.date));
        emit(
          EntriesLoaded(
            allEntries: transactions,
            filteredEntries: transactions,
            exceededLimits: exceededLimits,
          ),
        );
      } catch (e) {
        emit(FinanceError(e.toString()));
      }
    });

    on<FilterAndSortEntries>((event, emit) {
      final currentState = state;
      if (currentState is EntriesLoaded) {
        List<Transaction> filtered = List.from(currentState.allEntries);

        // Search by description
        if (event.searchTerm != null && event.searchTerm!.isNotEmpty) {
          filtered =
              filtered
                  .where(
                    (e) => (e.description ?? '').toLowerCase().contains(
                      event.searchTerm!.toLowerCase(),
                    ),
                  )
                  .toList();
        }

        // Filter by category
        if (event.category != null && event.category!.isNotEmpty) {
          filtered =
              filtered.where((e) => e.category == event.category).toList();
        }

        // Filter by date
        if (event.date != null) {
          filtered =
              filtered
                  .where(
                    (e) =>
                        e.date.year == event.date!.year &&
                        e.date.month == event.date!.month &&
                        e.date.day == event.date!.day,
                  )
                  .toList();
        }

        // Sort by date
        final sortAsc = event.sortAscending ?? currentState.sortAscending;
        filtered.sort(
          (a, b) =>
              sortAsc ? a.date.compareTo(b.date) : b.date.compareTo(a.date),
        );

        emit(
          EntriesLoaded(
            allEntries: currentState.allEntries,
            filteredEntries: filtered,
            searchTerm: event.searchTerm,
            category: event.category,
            date: event.date,
            sortAscending: sortAsc,
          ),
        );
      }
    });
  }
}
