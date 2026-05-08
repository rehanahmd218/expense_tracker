import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/expense_database.dart';
import 'bootstrap_provider.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(bootstrapDataProvider).themeMode;

  void _persist() {
    unawaited(ExpenseDatabase.instance.persistThemeMode(state));
  }

  void cycleMode() {
    state = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    _persist();
  }

  void setMode(ThemeMode mode) {
    state = mode;
    _persist();
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
