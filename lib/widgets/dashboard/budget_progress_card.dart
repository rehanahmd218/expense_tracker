import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/budget_provider.dart';
import '../../providers/expenses_provider.dart';

class BudgetProgressCard extends ConsumerWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budget = ref.watch(monthlyBudgetProvider);
    final spent = ref.watch(monthlySpentProvider);
    final progress = (spent / budget).clamp(0.0, 1.0);
    final left = budget - spent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Budget', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: () => _openBudgetEditor(context, ref, budget),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                ),
              ],
            ),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              left >= 0
                  ? '\$${left.toStringAsFixed(2)} left from \$${budget.toStringAsFixed(2)}'
                  : 'Over budget by \$${left.abs().toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBudgetEditor(
    BuildContext context,
    WidgetRef ref,
    double currentBudget,
  ) async {
    final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));
    final newBudget = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set monthly budget'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ '),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.of(ctx).pop(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (newBudget != null && newBudget > 0) {
      ref.read(monthlyBudgetProvider.notifier).updateBudget(newBudget);
    }
  }
}
