import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
import '../../widgets/transaction.dart';

@RoutePage()
class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FinanceBloc>()..add(LoadEntries()),
      child: const _SummaryView(),
    );
  }
}

class _SummaryView extends StatefulWidget {
  const _SummaryView();

  @override
  State<_SummaryView> createState() => _SummaryViewState();
}

class _SummaryViewState extends State<_SummaryView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final state = context.read<FinanceBloc>().state;
    if (state is EntriesLoaded) {
      context.read<FinanceBloc>().add(
        FilterAndSortEntries(
          searchTerm: _searchController.text,
          category: state.category,
          date: state.date,
        ),
      );
    }
  }

  void _showFilterSheet(BuildContext context, EntriesLoaded currentState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return BlocProvider.value(
          value: BlocProvider.of<FinanceBloc>(context),
          child: _FilterSheet(currentState: currentState),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinanceBloc, FinanceState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Transaction History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              if (state is EntriesLoaded)
                IconButton(
                  tooltip: 'Sort by Date',
                  icon: Icon(
                    state.sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                  ),
                  onPressed:
                      () => context.read<FinanceBloc>().add(
                        FilterAndSortEntries(
                          sortAscending: !state.sortAscending,
                        ),
                      ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _buildFilterBar(context, state),
                if (state is EntriesLoaded) _buildActiveFilters(context, state),
                const SizedBox(height: 8),
                Expanded(child: _buildContent(context, state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, FinanceState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by description...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: EdgeInsets.zero,
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _searchController.clear,
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
            onPressed:
                state is EntriesLoaded
                    ? () => _showFilterSheet(context, state)
                    : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, EntriesLoaded state) {
    bool hasFilters = state.category != null || state.date != null;
    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (state.category != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text('Category: ${state.category}'),
                      onDeleted:
                          () => context.read<FinanceBloc>().add(
                            FilterAndSortEntries(
                              category: null,
                              date: state.date,
                            ),
                          ),
                    ),
                  ),
                if (state.date != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(
                        'Date: ${DateFormat.yMMMd().format(state.date!)}',
                      ),
                      onDeleted:
                          () => context.read<FinanceBloc>().add(
                            FilterAndSortEntries(
                              category: state.category,
                              date: null,
                            ),
                          ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed:
                () => context.read<FinanceBloc>().add(
                  FilterAndSortEntries(category: null, date: null),
                ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, FinanceState state) {
    if (state is FinanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is EntriesLoaded) {
      if (state.filteredEntries.isEmpty) {
        return const Center(child: Text('No matching entries found.'));
      }

      final grouped = _groupEntriesByDate(state.filteredEntries);

      return ListView.builder(
        itemCount: grouped.length,
        itemBuilder: (context, index) {
          final date = grouped.keys.elementAt(index);
          final transactions = grouped[date]!;
          return StickyHeader(
            header: _DateHeader(date: date),
            content: Column(
              children:
                  transactions
                      .map((tx) => TransactionListItem(transaction: tx))
                      .toList(),
            ),
          );
        },
      );
    }
    if (state is FinanceError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    return const Center(child: Text('No transactions found.'));
  }

  Map<DateTime, List<Transaction>> _groupEntriesByDate(
    List<Transaction> entries,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (var entry in entries) {
      final date = DateUtils.dateOnly(entry.date);
      grouped.putIfAbsent(date, () => []).add(entry);
    }
    return grouped;
  }
}

class _FilterSheet extends StatefulWidget {
  final EntriesLoaded currentState;
  const _FilterSheet({required this.currentState});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.currentState.category;
    _selectedDate = widget.currentState.date;
  }

  @override
  Widget build(BuildContext context) {
    final uniqueCategories =
        widget.currentState.allEntries.map((e) => e.category).toSet().toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filters', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            hint: const Text('Filter by category'),
            isExpanded: true,
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Categories'),
              ),
              ...uniqueCategories.map(
                (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
              ),
            ],
            onChanged: (val) => setState(() => _selectedCategory = val),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _selectedDate == null
                  ? 'Filter by date'
                  : DateFormat.yMMMd().format(_selectedDate!),
            ),
            trailing:
                _selectedDate == null
                    ? const Icon(Icons.calendar_today)
                    : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _selectedDate = null),
                    ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            child: const Text('Apply Filters'),
            onPressed: () {
              context.read<FinanceBloc>().add(
                FilterAndSortEntries(
                  category: _selectedCategory,
                  date: _selectedDate,
                ),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

// These custom list item widgets remain the same as the previous response
class _DateHeader extends StatelessWidget {
  final DateTime date;
  const _DateHeader({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        DateFormat('EEEE, d MMMM yyyy').format(date),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
