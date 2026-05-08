import 'package:flutter/material.dart';

import '../models/expense.dart';

/// Distinct accents per category for charts and cards.
extension CategoryExpenseColors on Category {
  Color color(ColorScheme scheme) {
    switch (this) {
      case Category.food:
        return const Color(0xFFF59E0B);
      case Category.travel:
        return const Color(0xFF3B82F6);
      case Category.entertainment:
        return const Color(0xFFA855F7);
      case Category.shopping:
        return const Color(0xFFEC4899);
      case Category.bills:
        return const Color(0xFF10B981);
      case Category.other:
        return scheme.outlineVariant;
    }
  }
}
