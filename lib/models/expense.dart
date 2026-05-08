import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

enum Category { food, travel, entertainment, shopping, bills, other }

const uuid = Uuid();
var formatter = DateFormat.yMd();

const categoryIcons = {
  Category.food: Icons.fastfood,
  Category.travel: Icons.flight,
  Category.entertainment: Icons.movie,
  Category.shopping: Icons.shopping_cart,
  Category.bills: Icons.receipt,
  Category.other: Icons.category,
};

class Expense {
  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    String? id,
  }) : id = id ?? uuid.v4();

  final String title;
  final double amount;
  final DateTime date;
  final String id;
  final Category category;

  String get formattedDate {
    return formatter.format(date);
  }
}

class ExpenseBucket {
  final Category category;
  final List<Expense> expenses;

  const ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory({
    required this.category,
    List<Expense> allExpenses = const [],
  }) : expenses =
           allExpenses
               .where((expense) => expense.category == category)
               .toList();

  double get totalExpenses {
    double total = 0.0;
    for (var expense in expenses) {
      total += expense.amount;
    }
    return total;
  }
}
