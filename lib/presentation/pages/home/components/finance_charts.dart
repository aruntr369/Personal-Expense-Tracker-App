import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../domain/entities/expense_entry.dart';
import '../../../../domain/entities/transaction.dart';

class FinanceCharts extends StatelessWidget {
  // 1. Accept the list of all transactions
  final List<Transaction> entries;

  const FinanceCharts({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // 2. Remove the FutureBuilder and _fetchExpenses method.
    //    Filter the incoming entries to get only the expenses.
    final expenses = entries.whereType<ExpenseEntry>().toList();

    if (expenses.isEmpty) {
      return const Center(
        child: Text(
          'No expense data for this month to display.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // --- The rest of your chart logic remains the same ---

    // Pie chart: spending by category
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final categories = categoryTotals.keys.toList();

    // Bar chart: daily spending
    final daysInMonth = DateUtils.getDaysInMonth(
      DateTime.now().year,
      DateTime.now().month,
    );
    final dailyTotals = List<double>.filled(daysInMonth, 0);
    for (var e in expenses) {
      final day = e.date.day - 1; // day is 1-based, index is 0-based
      if (day >= 0 && day < daysInMonth) {
        dailyTotals[day] += e.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Spending by Category',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: List.generate(categories.length, (i) {
                final category = categories[i];
                final total = categoryTotals[category]!;
                return PieChartSectionData(
                  value: total,
                  title: '${category}\n(${total.toStringAsFixed(0)})',
                  color: Colors.primaries[i % Colors.primaries.length].shade300,
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Daily Spending',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY:
                  (dailyTotals.isNotEmpty
                      ? dailyTotals.reduce((a, b) => a > b ? a : b) * 1.2
                      : 100),
              barTouchData: BarTouchData(enabled: false),
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
                          '${value.toInt() + 1}',
                          style: const TextStyle(fontSize: 10),
                        ),
                    interval: 4, // Show every 5th day
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
              barGroups: List.generate(dailyTotals.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: dailyTotals[i],
                      color: Colors.deepPurple.shade300,
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
