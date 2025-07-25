import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../data/models/expense_entry_model.dart';
import '../../../../domain/entities/expense_entry.dart';

class FinanceCharts extends StatelessWidget {
  const FinanceCharts({super.key});

  Future<List<ExpenseEntry>> _fetchExpenses() async {
    final now = DateTime.now();
    final box = await Hive.openBox<ExpenseEntryModel>('expenseBox');
    return box.values
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .map(
          (e) => ExpenseEntry(
            id: e.id,
            category: e.category,
            subCategory: e.subCategory,
            description: e.description,
            date: e.date,
            amount: e.amount,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpenseEntry>>(
      future: _fetchExpenses(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final expenses = snapshot.data!;
        if (expenses.isEmpty) {
          return const Center(child: Text('No expense data for this month.'));
        }
        // Pie chart: spending by category
        final categoryTotals = <String, double>{};
        for (var e in expenses) {
          categoryTotals[e.category] =
              (categoryTotals[e.category] ?? 0) + e.amount;
        }
        final categories = categoryTotals.keys.toList();
        final categorySpending = categoryTotals.values.toList();
        // Bar chart: daily spending
        final daysInMonth = DateUtils.getDaysInMonth(
          DateTime.now().year,
          DateTime.now().month,
        );
        final dailyTotals = List<double>.filled(daysInMonth, 0);
        for (var e in expenses) {
          final day = e.date.day - 1;
          dailyTotals[day] += e.amount;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Spending by Category (Pie Chart)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: List.generate(categories.length, (i) {
                    return PieChartSectionData(
                      value: categorySpending[i],
                      title: categories[i],
                      color: Colors.primaries[i % Colors.primaries.length],
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
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
              'Daily Spending (Bar Chart)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      (dailyTotals.isNotEmpty
                          ? (dailyTotals.reduce((a, b) => a > b ? a : b) + 20)
                          : 100),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, interval: 20),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget:
                            (value, meta) => Text('${value.toInt() + 1}'),
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
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
                          color: Colors.blueAccent,
                          width: 8,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
