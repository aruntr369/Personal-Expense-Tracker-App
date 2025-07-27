import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_app/core/styles/app_colors.dart';

import '../../domain/entities/income_entry.dart';
import '../../domain/entities/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction is IncomeEntry;
    final backgroundColor =
        isIncome
            ? Palette.green.withValues(alpha: 0.1)
            : Palette.red.withValues(alpha: 0.1);
    final color = isIncome ? Palette.green : Palette.red;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: backgroundColor,
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          transaction.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          transaction.description ?? 'No description',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(transaction.amount)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
