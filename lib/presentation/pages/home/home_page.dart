import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/income_entry.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../widgets/transaction.dart';
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

class _HomePageView extends StatelessWidget {
  const _HomePageView();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Manage Categories',
            onPressed:
                () => context.router.push(const CategoryManagementRoute()),
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
              return _DashboardContent(entries: state.allEntries);
            }
            return const Center(child: Text("Loading data..."));
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final List<Transaction> entries;

  const _DashboardContent({required this.entries});

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
            const SizedBox(height: 24),
            const Text(
              "Spending Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 80), // Add padding for the FAB
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
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          children: [
            // Each item is wrapped in Expanded to share space equally
            Expanded(
              child: _InfoTile(
                title: 'Income',
                amount: income,
                color: Colors.green,
                icon: Icons.arrow_upward,
              ),
            ),
            // A vertical divider for better separation
            const SizedBox(height: 40, child: VerticalDivider()),
            Expanded(
              child: _InfoTile(
                title: 'Expenses',
                amount: expenses,
                color: Colors.red,
                icon: Icons.arrow_downward,
              ),
            ),
            const SizedBox(height: 40, child: VerticalDivider()),
            Expanded(
              child: _InfoTile(
                title: 'Balance',
                amount: balance,
                color: Theme.of(context).colorScheme.onSurface,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 8),
          // FittedBox scales down the text to prevent overflow
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              NumberFormat.currency(
                locale: 'en_IN',
                symbol: '₹',
              ).format(amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
              maxLines: 1,
            ),
          ),
        ],
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
