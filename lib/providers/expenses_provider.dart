import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/expense_database.dart';
import '../models/expense.dart';
import '../models/expense_filter.dart';
import 'bootstrap_provider.dart';
import 'filter_provider.dart';

class ExpensesNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    return List<Expense>.from(ref.read(bootstrapDataProvider).expenses);
  }

  void _persist() {
    unawaited(ExpenseDatabase.instance.persistExpenses(state));
  }

  void addExpense(Expense expense) {
    state = [...state, expense];
    _persist();
  }

  void removeExpense(Expense expense) {
    state = state.where((item) => item.id != expense.id).toList();
    _persist();
  }

  void insertAt(int index, Expense expense) {
    final updated = [...state];
    updated.insert(index.clamp(0, updated.length), expense);
    state = updated;
    _persist();
  }

  Expense? repeatLatestExpense() {
    if (state.isEmpty) {
      return null;
    }

    final latest = state.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final repeated = Expense(
      title: '${latest.title} (Repeat)',
      amount: latest.amount,
      date: DateTime.now(),
      category: latest.category,
    );
    state = [...state, repeated];
    _persist();
    return repeated;
  }
}

final expensesProvider = NotifierProvider<ExpensesNotifier, List<Expense>>(
  ExpensesNotifier.new,
);

final visibleExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider);
  final filters = ref.watch(expenseFiltersProvider);
  final sort = ref.watch(expenseSortProvider);

  var filtered = expenses.where((expense) {
    final titlePass = expense.title.toLowerCase().contains(
      filters.searchQuery.toLowerCase(),
    );
    final minPass = filters.minAmount == null || expense.amount >= filters.minAmount!;
    final monthPass =
        !filters.onlyThisMonth ||
        (expense.date.month == DateTime.now().month &&
            expense.date.year == DateTime.now().year);
    final categoryPass =
        filters.category == null || expense.category == filters.category;
    return titlePass && minPass && monthPass && categoryPass;
  }).toList();

  filtered.sort((a, b) {
    return switch (sort) {
      ExpenseSort.dateDesc => b.date.compareTo(a.date),
      ExpenseSort.dateAsc => a.date.compareTo(b.date),
      ExpenseSort.amountHighToLow => b.amount.compareTo(a.amount),
      ExpenseSort.amountLowToHigh => a.amount.compareTo(b.amount),
      ExpenseSort.titleAZ => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
    };
  });
  return filtered;
});

final monthlySpentProvider = Provider<double>((ref) {
  final now = DateTime.now();
  final expenses = ref.watch(expensesProvider);
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold(0.0, (sum, e) => sum + e.amount);
});

final totalSpentProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});
