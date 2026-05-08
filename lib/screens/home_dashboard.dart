import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../providers/expenses_provider.dart';
import '../providers/filter_provider.dart';
import '../widgets/dashboard/budget_progress_card.dart';
import '../widgets/dashboard/filter_sort_bar.dart';
import '../widgets/dashboard/spending_chart.dart';
import '../widgets/dashboard/summary_cards.dart';
import '../widgets/expenses/expenses_list.dart';

class HomeDashboard extends ConsumerWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleExpenses = ref.watch(visibleExpensesProvider);
    final allExpenses = ref.watch(expensesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          SummaryCards(expenses: allExpenses),
          const SizedBox(height: 12),
          const BudgetProgressCard(),
          const SizedBox(height: 12),
          SpendingChart(expenses: allExpenses),
          const SizedBox(height: 12),
          const FilterSortBar(),
          const SizedBox(height: 12),
          ExpensesList(
            expenses: visibleExpenses,
            onRemoveExpense: (expense) => _onRemoveExpense(context, ref, expense),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ],
      ),
    );
  }

  void _onRemoveExpense(BuildContext context, WidgetRef ref, Expense expense) {
    final expenses = ref.read(expensesProvider);
    final index = expenses.indexWhere((item) => item.id == expense.id);
    ref.read(expensesProvider.notifier).removeExpense(expense);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${expense.title}" removed'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () =>
              ref.read(expensesProvider.notifier).insertAt(index, expense),
        ),
      ),
    );
  }
}

void resetFiltersAndSnack(BuildContext context, WidgetRef ref) {
  ref.read(expenseFiltersProvider.notifier).reset();
  ref.read(expenseSortProvider.notifier).reset();
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Filters reset')),
  );
}

void repeatLatestExpenseSnack(BuildContext context, WidgetRef ref) {
  final repeated = ref.read(expensesProvider.notifier).repeatLatestExpense();
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        repeated == null
            ? 'No expense available to repeat'
            : '"${repeated.title}" added',
      ),
    ),
  );
}
