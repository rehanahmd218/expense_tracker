import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import 'expenses_provider.dart';

class CategorySlice {
  const CategorySlice({
    required this.category,
    required this.amount,
    required this.fraction,
  });

  final Category category;
  final double amount;
  final double fraction;
}

final monthExpensesProvider = Provider<List<Expense>>((ref) {
  final now = DateTime.now();
  final expenses = ref.watch(expensesProvider);
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .toList();
});

final categoryBreakdownProvider = Provider<List<CategorySlice>>((ref) {
  final month = ref.watch(monthExpensesProvider);
  final total = month.fold<double>(0, (s, e) => s + e.amount);
  if (total <= 0) {
    return Category.values
        .map(
          (c) => CategorySlice(category: c, amount: 0, fraction: 0),
        )
        .toList();
  }

  final byCategory = <Category, double>{
    for (final c in Category.values) c: 0,
  };
  for (final e in month) {
    byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
  }

  return Category.values
      .map(
        (c) => CategorySlice(
          category: c,
          amount: byCategory[c] ?? 0,
          fraction: (byCategory[c] ?? 0) / total,
        ),
      )
      .toList();
});

class DaySpend {
  const DaySpend({required this.day, required this.total});

  final DateTime day;
  final double total;
}

/// Last 7 calendar days ending today (inclusive), daily totals across all expenses.
final lastSevenDaysSpendProvider = Provider<List<DaySpend>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final today = DateTime.now();
  final dayStart = DateTime(today.year, today.month, today.day);

  return List.generate(7, (i) {
    final d = dayStart.subtract(Duration(days: 6 - i));
    final sum = expenses
        .where(
          (e) =>
              e.date.year == d.year &&
              e.date.month == d.month &&
              e.date.day == d.day,
        )
        .fold<double>(0, (s, e) => s + e.amount);
    return DaySpend(day: d, total: sum);
  });
});

final expenseCountProvider = Provider<int>((ref) {
  return ref.watch(expensesProvider).length;
});

final previousMonthSpendProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final prev = DateTime(now.year, now.month - 1);
  final expenses = ref.watch(expensesProvider);
  return expenses
      .where((e) => e.date.year == prev.year && e.date.month == prev.month)
      .fold(0.0, (sum, e) => sum + e.amount);
});
