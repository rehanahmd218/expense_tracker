import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/expense_database.dart';
import 'bootstrap_provider.dart';

class MonthlyBudgetNotifier extends Notifier<double> {
  @override
  double build() => ref.read(bootstrapDataProvider).monthlyBudget;

  void updateBudget(double value) {
    if (value > 0) {
      state = value;
      unawaited(ExpenseDatabase.instance.persistMonthlyBudget(state));
    }
  }
}

final monthlyBudgetProvider =
    NotifierProvider<MonthlyBudgetNotifier, double>(MonthlyBudgetNotifier.new);
