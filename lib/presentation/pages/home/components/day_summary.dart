import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/entities/transaction.dart';
import '../../../widgets/transaction.dart';

class DailyTransactionsView extends StatefulWidget {
  final List<Transaction> entries;
  const DailyTransactionsView({super.key, required this.entries});

  @override
  State<DailyTransactionsView> createState() => _DailyTransactionsViewState();
}

class _DailyTransactionsViewState extends State<DailyTransactionsView> {
  final ScrollController _scrollController = ScrollController();
  late DateTime _selectedDate;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateUtils.dateOnly(DateTime.now());
    _days = _getDaysOfCurrentMonth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Calculate the initial scroll position to center on today's date.
        // Today's date is at index (now.day - 1).
        final todayIndex = DateTime.now().day - 1;
        final chipWidth = 60.0 + 8.0; // chip width + margin
        final scrollPosition =
            (todayIndex * chipWidth) -
            (context.size!.width / 2) +
            (chipWidth / 2);
        _scrollController.jumpTo(scrollPosition);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<DateTime> _getDaysOfCurrentMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final totalDays = DateUtils.getDaysInMonth(now.year, now.month);
    return List.generate(
      totalDays,
      (index) => firstDayOfMonth.add(Duration(days: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsForSelectedDay =
        widget.entries
            .where((tx) => DateUtils.isSameDay(tx.date, _selectedDate))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Daily Transactions",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _days.length,
            itemBuilder: (context, index) {
              final day = _days[index];
              final isSelected = DateUtils.isSameDay(_selectedDate, day);
              return _DateChip(
                date: day,
                isSelected: isSelected,
                onTap: () => setState(() => _selectedDate = day),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (transactionsForSelectedDay.isEmpty)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  "No transactions on this day.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children:
                  transactionsForSelectedDay
                      .map((tx) => TransactionListItem(transaction: tx))
                      .toList(),
            ),
          ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DateChip({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final isToday = DateUtils.isSameDay(date, today);
    final isFuture = date.isAfter(today);
    final colorScheme = Theme.of(context).colorScheme;

    final defaultTextColor = isFuture ? Colors.grey : colorScheme.onSurface;
    final defaultSubtitleColor =
        isFuture ? Colors.grey : colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border:
              isToday && !isSelected
                  ? Border.all(color: colorScheme.primary)
                  : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday ? "Today" : DateFormat('E').format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.onPrimary : defaultTextColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d').format(date),
              style: TextStyle(
                color:
                    isSelected ? colorScheme.onPrimary : defaultSubtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
