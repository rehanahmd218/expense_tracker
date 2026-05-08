import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/expense.dart';
import '../../models/expense_filter.dart';
import '../../providers/filter_provider.dart';
import '../../theme/category_colors.dart';

class FilterSortBar extends ConsumerStatefulWidget {
  const FilterSortBar({super.key});

  @override
  ConsumerState<FilterSortBar> createState() => _FilterSortBarState();
}

class _FilterSortBarState extends ConsumerState<FilterSortBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(expenseFiltersProvider);
    final selectedSort = ref.watch(expenseSortProvider);
    if (_searchController.text != filters.searchQuery) {
      _searchController.value = TextEditingValue(
        text: filters.searchQuery,
        selection: TextSelection.collapsed(offset: filters.searchQuery.length),
      );
    }

    const ctrlH = 52.0;
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              onChanged: ref.read(expenseFiltersProvider.notifier).setSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilledButton.tonal(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, ctrlH),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () => ref
                      .read(expenseFiltersProvider.notifier)
                      .toggleThisMonth(!filters.onlyThisMonth),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filters.onlyThisMonth
                            ? Icons.check_circle_rounded
                            : Icons.calendar_month_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text('This Month'),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: ctrlH,
                    child: DropdownButtonFormField<ExpenseSort>(
                      key: ValueKey(selectedSort),
                      initialValue: selectedSort,
                      isExpanded: true,
                      isDense: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: InputDecoration(
                        hintText: 'Sort',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: scheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ExpenseSort.dateDesc,
                          child: Text('Latest first'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseSort.dateAsc,
                          child: Text('Oldest first'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseSort.amountHighToLow,
                          child: Text('Amount high -> low'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseSort.amountLowToHigh,
                          child: Text('Amount low -> high'),
                        ),
                        DropdownMenuItem(
                          value: ExpenseSort.titleAZ,
                          child: Text('Title A -> Z'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(expenseSortProvider.notifier).setSort(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: filters.category == null,
                  onSelected: (_) =>
                      ref.read(expenseFiltersProvider.notifier).setCategory(null),
                ),
                ...Category.values.map(
                  (c) => FilterChip(
                    avatar: Icon(
                      categoryIcons[c],
                      size: 18,
                      color: c.color(scheme),
                    ),
                    label: Text(c.name.toUpperCase()),
                    selected: filters.category == c,
                    onSelected: (_) =>
                        ref.read(expenseFiltersProvider.notifier).setCategory(c),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Any Amount'),
                  selected: filters.minAmount == null,
                  onSelected: (_) =>
                      ref.read(expenseFiltersProvider.notifier).setMinAmount(null),
                ),
                ChoiceChip(
                  label: const Text('>= \$20'),
                  selected: filters.minAmount == 20,
                  onSelected: (_) =>
                      ref.read(expenseFiltersProvider.notifier).setMinAmount(20),
                ),
                ChoiceChip(
                  label: const Text('>= \$50'),
                  selected: filters.minAmount == 50,
                  onSelected: (_) =>
                      ref.read(expenseFiltersProvider.notifier).setMinAmount(50),
                ),
                ChoiceChip(
                  label: const Text('>= \$100'),
                  selected: filters.minAmount == 100,
                  onSelected: (_) =>
                      ref.read(expenseFiltersProvider.notifier).setMinAmount(100),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
