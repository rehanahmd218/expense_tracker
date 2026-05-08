import 'expense.dart';

enum ExpenseSort { dateDesc, dateAsc, amountHighToLow, amountLowToHigh, titleAZ }

class ExpenseFilters {
  const ExpenseFilters({
    this.searchQuery = '',
    this.onlyThisMonth = false,
    this.minAmount,
    this.category,
  });

  final String searchQuery;
  final bool onlyThisMonth;
  final double? minAmount;

  /// `null` means all categories.
  final Category? category;

  ExpenseFilters copyWith({
    String? searchQuery,
    bool? onlyThisMonth,
    double? minAmount,
    Category? category,
    bool clearMinAmount = false,
    bool clearCategory = false,
  }) {
    return ExpenseFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      onlyThisMonth: onlyThisMonth ?? this.onlyThisMonth,
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      category: clearCategory ? null : (category ?? this.category),
    );
  }
}
