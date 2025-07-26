import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/expense_entry.dart';
import '../../../../domain/entities/transaction.dart';

enum ChartTimeframe { monthly, weekly, daily }

class FinanceCharts extends StatefulWidget {
  final List<Transaction> entries;
  const FinanceCharts({super.key, required this.entries});

  @override
  State<FinanceCharts> createState() => _FinanceChartsState();
}

class _FinanceChartsState extends State<FinanceCharts> {
  ChartTimeframe _selectedTimeframe = ChartTimeframe.monthly;
  int? _touchedIndex;

  final List<Color> _chartColors = [
    Colors.blue.shade400,
    Colors.red.shade400,
    Colors.green.shade400,
    Colors.orange.shade400,
    Colors.purple.shade400,
    Colors.teal.shade400,
    Colors.pink.shade300,
    Colors.amber.shade600,
  ];

  @override
  Widget build(BuildContext context) {
    final allExpenses = widget.entries.whereType<ExpenseEntry>().toList();
    final filteredPieExpenses = _getFilteredExpenses(allExpenses);
    final categoryTotals = _calculateCategoryTotals(filteredPieExpenses);

    return Column(
      children: [
        // --- Pie Chart Section ---
        const Text(
          'Spending by Category',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SegmentedButton<ChartTimeframe>(
          segments: const <ButtonSegment<ChartTimeframe>>[
            ButtonSegment(value: ChartTimeframe.monthly, label: Text('Month')),
            ButtonSegment(value: ChartTimeframe.weekly, label: Text('Week')),
            ButtonSegment(value: ChartTimeframe.daily, label: Text('Day')),
          ],
          selected: {_selectedTimeframe},
          onSelectionChanged: (Set<ChartTimeframe> newSelection) {
            setState(() {
              _selectedTimeframe = newSelection.first;
              _touchedIndex = null;
            });
          },
          style: SegmentedButton.styleFrom(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            selectedBackgroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        if (filteredPieExpenses.isEmpty)
          _buildEmptyState('No expense data for this period.')
        else
          Column(
            children: [
              SizedBox(
                height: 220,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              pieTouchResponse
                                  .touchedSection!
                                  .touchedSectionIndex;
                        });
                      },
                    ),
                    sectionsSpace: 4,
                    centerSpaceRadius: 80,
                    sections: _generatePieSections(categoryTotals),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildLegend(categoryTotals),
            ],
          ),

        const SizedBox(height: 32),

        // --- Weekly Bar Chart Section ---
        const Text(
          'Weekly Spending Pattern',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildWeeklyBarChart(allExpenses),
      ],
    );
  }

  List<ExpenseEntry> _getFilteredExpenses(List<ExpenseEntry> allExpenses) {
    final now = DateTime.now();
    switch (_selectedTimeframe) {
      case ChartTimeframe.monthly:
        return allExpenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
      case ChartTimeframe.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return allExpenses
            .where(
              (e) =>
                  e.date.isAfter(
                    startOfWeek.subtract(const Duration(days: 1)),
                  ) &&
                  e.date.isBefore(endOfWeek.add(const Duration(days: 1))),
            )
            .toList();
      case ChartTimeframe.daily:
        return allExpenses
            .where(
              (e) =>
                  e.date.year == now.year &&
                  e.date.month == now.month &&
                  e.date.day == now.day,
            )
            .toList();
    }
  }

  Map<String, double> _calculateCategoryTotals(List<ExpenseEntry> expenses) {
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    return categoryTotals;
  }

  Widget _buildWeeklyBarChart(List<ExpenseEntry> allExpenses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weeklyExpenses =
        allExpenses
            .where(
              (e) =>
                  e.date.isAfter(
                    startOfWeek.subtract(const Duration(days: 1)),
                  ) &&
                  e.date.isBefore(endOfWeek.add(const Duration(days: 1))),
            )
            .toList();

    if (weeklyExpenses.isEmpty) {
      return _buildEmptyState('No expense data for this week.');
    }

    final weeklyTotals = List<double>.filled(7, 0);
    for (var e in weeklyExpenses) {
      weeklyTotals[e.date.weekday - 1] += e.amount;
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
              (weeklyTotals.isNotEmpty
                  ? weeklyTotals.reduce((a, b) => a > b ? a : b) * 1.2
                  : 100),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = DateFormat(
                  'E',
                ).format(DateTime(2025, 1, 6 + group.x));
                return BarTooltipItem(
                  '$day\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: '₹${rod.toY.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.yellow),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget:
                    (value, meta) => Text(
                      DateFormat('E')
                          .format(DateTime(2025, 1, 6 + value.toInt()))
                          .substring(0, 1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(weeklyTotals.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyTotals[i],
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.7),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieSections(
    Map<String, double> categoryTotals,
  ) {
    final totalValue = categoryTotals.values.fold(
      0.0,
      (sum, element) => sum + element,
    );
    if (totalValue == 0) return [];

    int i = 0;
    return categoryTotals.entries.map((entry) {
      final isTouched = (i == _touchedIndex);
      final percentage = (entry.value / totalValue) * 100;
      final title = percentage > 7 ? '${percentage.toStringAsFixed(0)}%' : '';

      final section = PieChartSectionData(
        color: _chartColors[i % _chartColors.length],
        value: entry.value,
        title: title,
        radius: isTouched ? 35.0 : 30.0,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        borderSide:
            isTouched
                ? BorderSide(
                  color: _chartColors[i % _chartColors.length].withOpacity(0.7),
                  width: 6,
                )
                : BorderSide(color: Colors.black.withOpacity(0)),
      );
      i++;
      return section;
    }).toList();
  }

  Widget _buildLegend(Map<String, double> categoryTotals) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(categoryTotals.length, (index) {
        final category = categoryTotals.keys.elementAt(index);
        final amount = categoryTotals.values.elementAt(index);
        final color = _chartColors[index % _chartColors.length];
        return _LegendItem(color: color, category: category, amount: amount);
      }),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 250,
      alignment: Alignment.center,
      child: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String category;
  final double amount;

  const _LegendItem({
    required this.color,
    required this.category,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(category, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }
}
