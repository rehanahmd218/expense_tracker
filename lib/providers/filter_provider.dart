import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/expense.dart';
import '../models/expense_filter.dart';

class ExpenseFiltersNotifier extends Notifier<ExpenseFilters> {
  @override
  ExpenseFilters build() => const ExpenseFilters();

  void setSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void toggleThisMonth(bool value) {
    state = state.copyWith(onlyThisMonth: value);
  }

  void setMinAmount(double? value) {
    state = value == null
        ? state.copyWith(clearMinAmount: true)
        : state.copyWith(minAmount: value);
  }

  void setCategory(Category? value) {
    state = value == null
        ? state.copyWith(clearCategory: true)
        : state.copyWith(category: value);
  }

  void reset() {
    state = const ExpenseFilters();
  }
}

class ExpenseSortNotifier extends Notifier<ExpenseSort> {
  @override
  ExpenseSort build() => ExpenseSort.dateDesc;

  void setSort(ExpenseSort sort) {
    state = sort;
  }

  void reset() {
    state = ExpenseSort.dateDesc;
  }
}

final expenseFiltersProvider =
    NotifierProvider<ExpenseFiltersNotifier, ExpenseFilters>(
      ExpenseFiltersNotifier.new,
    );

final expenseSortProvider = NotifierProvider<ExpenseSortNotifier, ExpenseSort>(
  ExpenseSortNotifier.new,
);
