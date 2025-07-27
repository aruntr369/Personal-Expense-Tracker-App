import 'package:flutter/material.dart';

import '../../../../domain/entities/category_limit.dart';

class LimitWarningCard extends StatelessWidget {
  final List<CategoryLimit> exceededLimits;

  const LimitWarningCard({super.key, required this.exceededLimits});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700, width: 1.5),
      ),
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Text(
                  "Spending Limit Exceeded",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "You've gone over budget for:",
              style: TextStyle(color: Colors.amber.shade800),
            ),
            const SizedBox(height: 8),
            ...exceededLimits.map(
              (limit) => Text(
                "• ${limit.category}",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
