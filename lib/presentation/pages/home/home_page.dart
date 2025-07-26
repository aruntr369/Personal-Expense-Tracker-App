import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/injections/dependency_injections.dart';
import '../../../core/routes/app_router.gr.dart';
import '../../bloc/finance/finance_bloc.dart';
import '../../bloc/finance/finance_event.dart';
import '../../bloc/finance/finance_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting =
        now.hour < 12
            ? 'Good morning'
            : now.hour < 18
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance App'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$greeting!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 8),
              const Text(
                'Here is your spending overview for this month:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BlocBuilder<FinanceBloc, FinanceState>(
                    builder: (context, state) {
                      // Handle the loading state
                      if (state is FinanceLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // When entries are loaded, pass them to the chart
                      if (state is EntriesLoaded) {
                        if (state.entries.isEmpty) {
                          return const Center(
                            child: Text("No entries added for this month yet."),
                          );
                        }
                        // Pass the data to your chart widget
                        return FinanceCharts(entries: state.entries);
                      }
                      // Handle the error state
                      if (state is FinanceError) {
                        return Center(child: Text('Error: ${state.message}'));
                      }
                      // Default or initial state
                      return const Center(child: Text("Loading chart data..."));
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Quick Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Income'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            isScrollControlled: true,
                            builder:
                                (_) => BlocProvider.value(
                                  value: BlocProvider.of<FinanceBloc>(context),
                                  child: EntryForm(isIncome: true),
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Add Expense'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            isScrollControlled: true,
                            builder:
                                (_) => BlocProvider.value(
                                  value: BlocProvider.of<FinanceBloc>(context),
                                  child: EntryForm(isIncome: false),
                                ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.summarize),
                        label: const Text('View Summary'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.router.push(const SummaryRoute());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
