import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../providers/analytics_provider.dart';
import '../providers/expenses_provider.dart';
import '../theme/category_colors.dart';
import '../widgets/insights/category_donut_chart.dart';
import '../widgets/insights/insights_hero_header.dart';
import '../widgets/insights/week_bar_chart.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slices = ref.watch(categoryBreakdownProvider);
    final week = ref.watch(lastSevenDaysSpendProvider);
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InsightsHeroHeader(),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Export snapshot',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Copy this month totals, categories, and last 7 days as plain text.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _copyInsightsSummary(context, ref),
                    icon: const Icon(Icons.copy_all_rounded),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'By category',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share of spending this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  CategoryDonutChart(slices: slices),
                  const SizedBox(height: 12),
                  ...slices.where((s) => s.amount > 0).map((s) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            categoryIcons[s.category],
                            color: s.category.color(scheme),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(s.category.name.toUpperCase()),
                          ),
                          Text(
                            '\$${s.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(s.fraction * 100).clamp(0, 99.9).toStringAsFixed(0)}%',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last 7 days',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily rhythm of your purchases',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  WeekBarChart(days: week),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _copyInsightsSummary(BuildContext context, WidgetRef ref) {
  final monthly = ref.read(monthlySpentProvider);
  final slices = ref.read(categoryBreakdownProvider);
  final week = ref.read(lastSevenDaysSpendProvider);

  final buf = StringBuffer()
    ..writeln('Expense Tracker Pro — snapshot')
    ..writeln('This month total: \$${monthly.toStringAsFixed(2)}')
    ..writeln()
    ..writeln('By category (this month):');
  for (final s in slices.where((x) => x.amount > 0)) {
    buf.writeln(
      '  ${s.category.name}: \$${s.amount.toStringAsFixed(2)} (${(s.fraction * 100).toStringAsFixed(0)}%)',
    );
  }
  buf
    ..writeln()
    ..writeln('Last 7 days:');
  for (final d in week) {
    buf.writeln(
      '  ${formatter.format(d.day)}: \$${d.total.toStringAsFixed(2)}',
    );
  }

  Clipboard.setData(ClipboardData(text: buf.toString()));
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Summary copied to clipboard')),
  );
}
