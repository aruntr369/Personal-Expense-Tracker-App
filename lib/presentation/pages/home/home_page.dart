import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../domain/entities/category_limit.dart';
import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/income_entry.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../widgets/transaction.dart';
import 'components/day_summary.dart';
import 'components/entry_form.dart';
import 'components/finance_charts.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinanceBloc>()..add(LoadEntries()),
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatefulWidget {
  const _HomePageView();

  @override
  State<_HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<_HomePageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FinFlow',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Manage Categories',
            onPressed: () async {
              final financeBloc = context.read<FinanceBloc>();
              final router = context.router;
              await router.push(const CategoryManagementRoute());
              if (!mounted) return;
              financeBloc.add(LoadEntries());
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted_outlined),
            tooltip: 'View Full Summary',
            onPressed: () => context.router.push(const SummaryRoute()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddActionSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('New Entry'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<FinanceBloc>().add(LoadEntries());
        },
        child: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading && state is! EntriesLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FinanceError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is EntriesLoaded) {
              return _DashboardContent(
                entries: state.allEntries,
                exceededLimits: state.exceededLimits,
              );
            }
            return const Center(child: Text("Loading data..."));
          },
        ),
      ),
    );
  }

  // Helper methods from previous version (_showAddEntrySheet, etc.) go here
  void _showAddEntrySheet(BuildContext context, {required bool isIncome}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder:
          (_) => BlocProvider.value(
            value: BlocProvider.of<FinanceBloc>(context),
            child: EntryForm(isIncome: isIncome),
          ),
    );
  }

  void _showAddActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.arrow_upward, color: Colors.green),
                title: const Text('Add Income'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showAddEntrySheet(context, isIncome: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward, color: Colors.red),
                title: const Text('Add Expense'),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showAddEntrySheet(context, isIncome: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final List<Transaction> entries;
  final List<CategoryLimit> exceededLimits;

  const _DashboardContent({
    required this.entries,
    required this.exceededLimits,
  });

  @override
  Widget build(BuildContext context) {
    final double totalIncome = entries.whereType<IncomeEntry>().fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final double totalExpenses = entries.whereType<ExpenseEntry>().fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
    final double balance = totalIncome - totalExpenses;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FinancialOverviewCard(
              income: totalIncome,
              expenses: totalExpenses,
              balance: balance,
            ),
            if (exceededLimits.isNotEmpty)
              _LimitWarningCard(exceededLimits: exceededLimits),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FinanceCharts(entries: entries),
              ),
            ),

            const SizedBox(height: 24),
            DailyTransactionsView(entries: entries),

            const SizedBox(height: 24),
            const Text(
              "Recent Transactions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _RecentTransactionsList(entries: entries),
            if (entries.isNotEmpty)
              TextButton(
                onPressed: () => context.router.push(const SummaryRoute()),
                child: const Text('View All Transactions'),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _FinancialOverviewCard extends StatelessWidget {
  final double income;
  final double expenses;
  final double balance;

  const _FinancialOverviewCard({
    required this.income,
    required this.expenses,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade400,
              Colors.purple.shade500,
              Colors.pink.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Total Balance',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(balance),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // ✅ Change: Wrap each tile in Expanded to share space.
                Expanded(
                  child: _IncomeExpenseTile(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: income,
                    color: Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16), // Add spacing between tiles
                Expanded(
                  child: _IncomeExpenseTile(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expenses',
                    amount: expenses,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeExpenseTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _IncomeExpenseTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  currencyFormat.format(amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LimitWarningCard extends StatelessWidget {
  final List<CategoryLimit> exceededLimits;

  const _LimitWarningCard({required this.exceededLimits});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700, width: 1.5),
      ),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Text(
                  "Spending Limit Exceeded",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "You've gone over your budget for the following categories this month:",
              style: TextStyle(color: Colors.amber.shade800),
            ),
            const SizedBox(height: 8),
            ...exceededLimits.map(
              (limit) => Text(
                "• ${limit.category}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsList extends StatelessWidget {
  final List<Transaction> entries;

  const _RecentTransactionsList({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            'No transactions yet.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: List.generate(entries.length > 5 ? 5 : entries.length, (
          index,
        ) {
          final entry = entries[index];
          return TransactionListItem(transaction: entry);
        }),
      ),
    );
  }
}
