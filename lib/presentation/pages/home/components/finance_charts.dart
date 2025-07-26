import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/expense_entry.dart';
import '../../../../domain/entities/income_entry.dart';
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
    final filteredPieExpenses = _getFilteredExpenses();

    return Column(
      children: [
        const Text(
          'Weekly Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildMonthlyOverviewBarChart(),
        const SizedBox(height: 32),

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
        _buildPieChart(filteredPieExpenses),
      ],
    );
  }

  Widget _buildMonthlyOverviewBarChart() {
    final now = DateTime.now();
    final monthlyTransactions =
        widget.entries
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();

    if (monthlyTransactions.isEmpty) {
      return _buildEmptyState('No data for this month\'s overview.');
    }

    final weeklyIncomeTotals = List<double>.filled(5, 0.0);
    final weeklyExpenseTotals = List<double>.filled(5, 0.0);

    for (var transaction in monthlyTransactions) {
      final weekIndex = _getWeekOfMonth(transaction.date);
      if (transaction is IncomeEntry) {
        weeklyIncomeTotals[weekIndex] += transaction.amount;
      } else if (transaction is ExpenseEntry) {
        weeklyExpenseTotals[weekIndex] += transaction.amount;
      }
    }

    final double maxIncome =
        weeklyIncomeTotals.isNotEmpty
            ? weeklyIncomeTotals.reduce((a, b) => a > b ? a : b)
            : 0;
    final double maxExpense =
        weeklyExpenseTotals.isNotEmpty
            ? weeklyExpenseTotals.reduce((a, b) => a > b ? a : b)
            : 0;
    final double highestValue = maxIncome > maxExpense ? maxIncome : maxExpense;
    final double maxY = highestValue == 0 ? 1000 : highestValue * 1.2;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.grey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label =
                    rod.color == Colors.deepPurple.shade400
                        ? 'Income'
                        : 'Expense';
                return BarTooltipItem(
                  '${label}\n',
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
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 56,
                interval: maxY / 5,
                getTitlesWidget: (value, meta) {
                  final formatter = NumberFormat.compactCurrency(
                    locale: 'en_IN',
                    symbol: '₹',
                    decimalDigits: 1,
                  );

                  return Text(formatter.format(value));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'Week ${value.toInt() + 1}',
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            // Use the same interval for the grid lines
            horizontalInterval: maxY / 4,
          ),
          barGroups: List.generate(4, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: weeklyIncomeTotals[i],
                  color: Colors.deepPurple.shade400,
                  width: 15,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                BarChartRodData(
                  toY: weeklyExpenseTotals[i],
                  color: Colors.orange.shade400,
                  width: 15,
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

  int _getWeekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final dayOfWeek = firstDayOfMonth.weekday;
    final dayOfMonth = date.day;
    return ((dayOfMonth + dayOfWeek - 2) / 7).floor();
  }

  List<ExpenseEntry> _getFilteredExpenses() {
    final allExpenses = widget.entries.whereType<ExpenseEntry>().toList();
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

  Widget _buildPieChart(List<ExpenseEntry> expenses) {
    if (expenses.isEmpty) {
      return _buildEmptyState('No expense data for this period.');
    }
    final categoryTotals = _calculateCategoryTotals(expenses);
    return Column(
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
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
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
    );
  }

  Map<String, double> _calculateCategoryTotals(List<ExpenseEntry> expenses) {
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    return categoryTotals;
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
                  color: _chartColors[i % _chartColors.length].withValues(
                    alpha: 0.7,
                  ),
                  width: 6,
                )
                : BorderSide(color: Colors.black.withValues(alpha: 0)),
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
