import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../domain/entities/expense_entry.dart';
import '../../../domain/entities/income_entry.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  String? _search;
  String? _category;
  DateTime? _selectedDate;
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: BlocProvider(
        create: (_) => sl<FinanceBloc>()..add(LoadEntries()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by description',
                      ),
                      onChanged: (val) => setState(() => _search = val),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    ),
                    onPressed: () => setState(() => _ascending = !_ascending),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _category,
                      hint: const Text('Filter by category'),
                      isExpanded: true,
                      items: [
                        ...[
                          '',
                          'Salary',
                          'Bonus',
                          'Freelance',
                          'Interest',
                          'Entertainment',
                          'Food',
                          'Transportation',
                          'Shopping',
                          'Utilities',
                          'Other',
                        ].map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.isEmpty ? 'All' : cat),
                          ),
                        ),
                      ],
                      onChanged: (val) => setState(() => _category = val),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        setState(() => _selectedDate = picked);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<FinanceBloc, FinanceState>(
                  builder: (context, state) {
                    if (state is FinanceLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is EntriesLoaded) {
                      var entries = state.entries;
                      // Filter, search, and sort logic
                      if (_search != null && _search!.isNotEmpty) {
                        entries =
                            entries
                                .where(
                                  (e) => (e.description ?? '')
                                      .toLowerCase()
                                      .contains(_search!.toLowerCase()),
                                )
                                .toList();
                      }
                      if (_category != null && _category!.isNotEmpty) {
                        entries =
                            entries
                                .where((e) => e.category == _category)
                                .toList();
                      }
                      if (_selectedDate != null) {
                        entries =
                            entries
                                .where(
                                  (e) =>
                                      e.date.year == _selectedDate!.year &&
                                      e.date.month == _selectedDate!.month &&
                                      e.date.day == _selectedDate!.day,
                                )
                                .toList();
                      }
                      entries.sort(
                        (a, b) =>
                            _ascending
                                ? a.date.compareTo(b.date)
                                : b.date.compareTo(a.date),
                      );
                      // Group by date
                      final Map<String, List<dynamic>> grouped = {};
                      for (var entry in entries) {
                        final dateStr = DateFormat(
                          'yyyy-MM-dd',
                        ).format(entry.date);
                        grouped.putIfAbsent(dateStr, () => []).add(entry);
                      }
                      if (grouped.isEmpty) {
                        return const Center(child: Text('No entries found.'));
                      }
                      return ListView(
                        children:
                            grouped.entries.map((group) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Text(
                                      group.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  ...group.value.map(
                                    (entry) => ListTile(
                                      leading:
                                          entry is IncomeEntry
                                              ? const Icon(
                                                Icons.arrow_downward,
                                                color: Colors.green,
                                              )
                                              : const Icon(
                                                Icons.arrow_upward,
                                                color: Colors.red,
                                              ),
                                      title: Text(
                                        entry.category +
                                            (entry is ExpenseEntry
                                                ? ' (${entry.subCategory})'
                                                : ''),
                                      ),
                                      subtitle: Text(entry.description ?? ''),
                                      trailing: Text(
                                        '${entry.amount.toStringAsFixed(2)}',
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      );
                    } else if (state is FinanceError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('No data.'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
