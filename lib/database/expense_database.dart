import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/bootstrap_data.dart';
import '../models/expense.dart';

class ExpenseDatabase {
  ExpenseDatabase._();

  static final ExpenseDatabase instance = ExpenseDatabase._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'expense_tracker.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            date INTEGER NOT NULL,
            category TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE app_meta (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            monthly_budget REAL NOT NULL,
            theme_mode TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE category_budgets (
            category TEXT PRIMARY KEY,
            cap REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<BootstrapData> loadBootstrapData() async {
    final db = await database;
    await _ensureSeeded(db);

    final expenseRows = await db.query('expenses');
    final expenses = expenseRows.map(_rowToExpense).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final meta = (await db.query(
      'app_meta',
      where: 'id = ?',
      whereArgs: [1],
    )).first;
    final monthlyBudget = (meta['monthly_budget'] as num).toDouble();
    final themeMode = _themeModeFromString(meta['theme_mode'] as String);

    final budgetRows = await db.query('category_budgets');
    final caps = <Category, double>{
      for (final row in budgetRows)
        Category.values.byName(row['category'] as String):
            (row['cap'] as num).toDouble(),
    };

    return BootstrapData(
      expenses: expenses,
      monthlyBudget: monthlyBudget,
      categoryBudgets: caps,
      themeMode: themeMode,
    );
  }

  Future<void> persistExpenses(List<Expense> list) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('expenses');
      final batch = txn.batch();
      for (final e in list) {
        batch.insert('expenses', _expenseToRow(e));
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> persistMonthlyBudget(double value) async {
    final db = await database;
    await db.update(
      'app_meta',
      {'monthly_budget': value},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> persistCategoryBudgets(Map<Category, double> caps) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('category_budgets');
      final batch = txn.batch();
      for (final e in caps.entries) {
        batch.insert('category_budgets', {
          'category': e.key.name,
          'cap': e.value,
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> persistThemeMode(ThemeMode mode) async {
    final db = await database;
    await db.update(
      'app_meta',
      {'theme_mode': _themeModeToString(mode)},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> _ensureSeeded(Database db) async {
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM app_meta'),
    );
    if (count != null && count > 0) return;

    final now = DateTime.now();
    final seed = [
      Expense(
        title: 'Monthly groceries',
        amount: 82.5,
        date: now.subtract(const Duration(days: 1)),
        category: Category.food,
      ),
      Expense(
        title: 'Team lunch',
        amount: 39.9,
        date: now.subtract(const Duration(days: 2)),
        category: Category.food,
      ),
      Expense(
        title: 'Streaming subscription',
        amount: 14.99,
        date: now.subtract(const Duration(days: 4)),
        category: Category.entertainment,
      ),
      Expense(
        title: 'Ride to office',
        amount: 22.0,
        date: now.subtract(const Duration(days: 5)),
        category: Category.travel,
      ),
      Expense(
        title: 'Electricity bill',
        amount: 76.4,
        date: now.subtract(const Duration(days: 7)),
        category: Category.bills,
      ),
      Expense(
        title: 'New headphones',
        amount: 120.0,
        date: now.subtract(const Duration(days: 10)),
        category: Category.shopping,
      ),
    ];

    const defaultCaps = {
      Category.food: 400.0,
      Category.travel: 200.0,
      Category.entertainment: 150.0,
      Category.shopping: 300.0,
      Category.bills: 350.0,
      Category.other: 100.0,
    };

    await db.transaction((txn) async {
      await txn.insert('app_meta', {
        'id': 1,
        'monthly_budget': 1500.0,
        'theme_mode': 'system',
      });
      for (final e in seed) {
        await txn.insert('expenses', _expenseToRow(e));
      }
      for (final e in defaultCaps.entries) {
        await txn.insert('category_budgets', {
          'category': e.key.name,
          'cap': e.value,
        });
      }
    });
  }

  static Map<String, Object?> _expenseToRow(Expense e) => {
    'id': e.id,
    'title': e.title,
    'amount': e.amount,
    'date': e.date.millisecondsSinceEpoch,
    'category': e.category.name,
  };

  static Expense _rowToExpense(Map<String, Object?> row) => Expense(
    id: row['id'] as String,
    title: row['title'] as String,
    amount: (row['amount'] as num).toDouble(),
    date: DateTime.fromMillisecondsSinceEpoch(row['date'] as int),
    category: Category.values.byName(row['category'] as String),
  );

  static String _themeModeToString(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
  };

  static ThemeMode _themeModeFromString(String raw) => switch (raw) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
