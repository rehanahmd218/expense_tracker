import 'package:flutter/material.dart';

import 'expense.dart';

class BootstrapData {
  const BootstrapData({
    required this.expenses,
    required this.monthlyBudget,
    required this.categoryBudgets,
    required this.themeMode,
  });

  final List<Expense> expenses;
  final double monthlyBudget;
  final Map<Category, double> categoryBudgets;
  final ThemeMode themeMode;
}
