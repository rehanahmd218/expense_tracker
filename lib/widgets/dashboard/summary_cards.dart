import 'package:flutter/material.dart';

import '../../models/expense.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.expenses});

  final List<Expense> expenses;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthExpenses = expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .toList();

    final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final monthly = monthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
    final avg = expenses.isEmpty ? 0.0 : total / expenses.length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'This Month',
            value: monthly,
            icon: Icons.calendar_month_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            title: 'Average',
            value: avg,
            icon: Icons.analytics_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Icon(icon, color: scheme.onPrimaryContainer),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(
                    '\$${value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
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
