import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';
import '../widgets/expense_form_sheet.dart';
import 'budgets_screen.dart';
import 'home_dashboard.dart';
import 'insights_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _index = 0;

  void _openAddExpenseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const ExpenseFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_index) {
            0 => 'Expense Tracker Pro',
            1 => 'Insights',
            _ => 'Budgets',
          },
        ),
        actions: [
          if (_index == 0) ...[
            IconButton(
              onPressed: () => repeatLatestExpenseSnack(context, ref),
              icon: const Icon(Icons.content_copy_rounded),
              tooltip: 'Repeat latest expense',
            ),
            IconButton(
              onPressed: () => ref.read(themeModeProvider.notifier).cycleMode(),
              icon: Icon(
                switch (currentMode) {
                  ThemeMode.dark => Icons.dark_mode_rounded,
                  ThemeMode.light => Icons.light_mode_rounded,
                  ThemeMode.system => Icons.brightness_auto_rounded,
                },
              ),
            ),
            IconButton(
              onPressed: () => resetFiltersAndSnack(context, ref),
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Reset filters',
            ),
          ],
        ],
      ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: _openAddExpenseSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Expense'),
            )
          : null,
      body: SafeArea(
        child: IndexedStack(
          index: _index,
          children: const [
            HomeDashboard(),
            InsightsScreen(),
            BudgetsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights_rounded),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: Icon(Icons.pie_chart_rounded),
            label: 'Budgets',
          ),
        ],
      ),
    );
  }
}
