import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/expense_database.dart';
import '../models/expense.dart';
import 'analytics_provider.dart';
import 'bootstrap_provider.dart';

/// Per-category caps (monthly). Editable from Budgets screen.
class CategoryBudgetsNotifier extends Notifier<Map<Category, double>> {
  @override
  Map<Category, double> build() =>
      Map<Category, double>.from(ref.read(bootstrapDataProvider).categoryBudgets);

  void setCap(Category category, double value) {
    if (value <= 0) return;
    state = {...state, category: value};
    unawaited(ExpenseDatabase.instance.persistCategoryBudgets(state));
  }
}

final categoryBudgetsProvider =
    NotifierProvider<CategoryBudgetsNotifier, Map<Category, double>>(
  CategoryBudgetsNotifier.new,
);

class CategorySpendVsBudget {
  const CategorySpendVsBudget({
    required this.category,
    required this.spent,
    required this.cap,
  });

  final Category category;
  final double spent;
  final double cap;

  double get ratio => cap <= 0 ? 0 : (spent / cap).clamp(0.0, double.infinity);
  bool get isOver => spent > cap;
}

final categorySpendVsBudgetProvider =
    Provider<List<CategorySpendVsBudget>>((ref) {
  final caps = ref.watch(categoryBudgetsProvider);
  final month = ref.watch(monthExpensesProvider);
  final spentBy = <Category, double>{
    for (final c in Category.values) c: 0,
  };
  for (final e in month) {
    spentBy[e.category] = (spentBy[e.category] ?? 0) + e.amount;
  }
  return Category.values
      .map(
        (c) => CategorySpendVsBudget(
          category: c,
          spent: spentBy[c] ?? 0,
          cap: caps[c] ?? 0,
        ),
      )
      .toList();
});
