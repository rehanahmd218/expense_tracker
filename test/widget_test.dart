// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:new_expense_tracker/app.dart';
import 'package:new_expense_tracker/models/bootstrap_data.dart';
import 'package:new_expense_tracker/models/expense.dart';
import 'package:new_expense_tracker/providers/bootstrap_provider.dart';

BootstrapData _testBootstrap() {
  return BootstrapData(
    expenses: const [],
    monthlyBudget: 1500,
    categoryBudgets: {
      for (final c in Category.values) c: 100.0,
    },
    themeMode: ThemeMode.system,
  );
}

void main() {
  testWidgets('Renders expense tracker home', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          bootstrapDataProvider.overrideWithValue(_testBootstrap()),
        ],
        child: const ExpenseTrackerApp(),
      ),
    );

    expect(find.text('Expense Tracker Pro'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });
}
