import 'package:flutter/material.dart';

import '../../../../domain/entities/transaction.dart';
import '../../../widgets/transaction.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Transaction> entries;

  const RecentTransactionsList({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              'No transactions yet.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: List.generate(entries.length > 5 ? 5 : entries.length, (
          index,
        ) {
          final entry = entries[index];
          return TransactionListItem(transaction: entry);
        }),
      ),
    );
  }
}
