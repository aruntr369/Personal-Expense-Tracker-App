import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app/core/styles/app_colors.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../../domain/entities/category_limit.dart';
import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/income_entry.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import 'components/day_summary.dart';
import 'components/entry_form.dart';
import 'components/finance_charts.dart';
import 'components/financial_overview_card.dart';
import 'components/limit_warning_card.dart';
import 'components/recent_transactions_list.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FinFlow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              DateFormat('MMMM yyyy').format(DateTime.now()),
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
        backgroundColor: Palette.primary,
        onPressed: () => _showAddActionSheet(context),

        icon: const Icon(Icons.add, color: Palette.white),
        label: const Text(
          'New Entry',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Palette.white,
            fontSize: 16,
          ),
        ),
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
                leading: const Icon(
                  Icons.arrow_upward,
                  color: Palette.green,
                  size: 30,
                ),
                title: const Text(
                  'Add Income',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showAddEntrySheet(context, isIncome: true);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.arrow_downward,
                  color: Palette.red,
                  size: 30,
                ),
                title: const Text(
                  'Add Expense',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
            FinancialOverviewCard(
              income: totalIncome,
              expenses: totalExpenses,
              balance: balance,
            ),
            if (exceededLimits.isNotEmpty)
              LimitWarningCard(exceededLimits: exceededLimits),

            const SizedBox(height: 24),
            const _SectionHeader(title: "Spending Overview"),
            const SizedBox(height: 16),
            _SpendingChartsCard(entries: entries),

            const SizedBox(height: 24),
            DailyTransactionsView(entries: entries),

            const SizedBox(height: 24),
            const _SectionHeader(title: "Recent Transactions"),
            const SizedBox(height: 16),
            RecentTransactionsList(entries: entries),

            if (entries.isNotEmpty)
              Center(
                child: TextButton(
                  onPressed: () => context.router.push(const SummaryRoute()),
                  child: const Text('View All Transactions'),
                ),
              ),

            const SizedBox(height: 80), // Padding for the FAB
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class _SpendingChartsCard extends StatelessWidget {
  final List<Transaction> entries;
  const _SpendingChartsCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FinanceCharts(entries: entries),
      ),
    );
  }
}
