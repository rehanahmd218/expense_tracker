import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../providers/analytics_provider.dart';

class WeekBarChart extends StatelessWidget {
  const WeekBarChart({super.key, required this.days});

  final List<DaySpend> days;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxVal = days.fold<double>(
      0,
      (m, d) => d.total > m ? d.total : m,
    );
    final scale = maxVal <= 0 ? 1.0 : maxVal;
    final labelFmt = DateFormat.E();

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
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
                          heightFactor: maxVal <= 0
                              ? 0.08
                              : (d.total <= 0
                                      ? 0.04
                                      : (d.total / scale).clamp(0.12, 1.0))
                                  .toDouble(),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  scheme.primary,
                                  scheme.tertiary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labelFmt.format(d.day),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
