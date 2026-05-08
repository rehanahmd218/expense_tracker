import 'package:flutter/material.dart';

import '../../models/expense.dart';

class SpendingChart extends StatelessWidget {
  const SpendingChart({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final buckets = [
      for (final category in Category.values)
        ExpenseBucket.forCategory(category: category, allExpenses: expenses),
    ];

    final max = buckets.fold<double>(
      0,
      (current, bucket) => bucket.totalExpenses > current ? bucket.totalExpenses : current,
    );
    final maxSafe = max == 0 ? 1.0 : max;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category Spending', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final bucket in buckets)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: bucket.totalExpenses / maxSafe,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Icon(categoryIcons[bucket.category], size: 18),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
