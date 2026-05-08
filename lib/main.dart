import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'database/expense_database.dart';
import 'database/sqflite_init.dart';
import 'providers/bootstrap_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeSqflite();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final bootstrap = await ExpenseDatabase.instance.loadBootstrapData();
  runApp(
    ProviderScope(
      overrides: [
        bootstrapDataProvider.overrideWithValue(bootstrap),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
