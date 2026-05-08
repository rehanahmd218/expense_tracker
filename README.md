**Expense Tracker Pro**

A lightweight personal expense tracker built with Flutter. It stores expenses locally using `sqflite`, supports budgets and categories, provides analytics/insights, and includes a responsive material UI with light/dark themes.

**Quick Start**
- **Prerequisites**: Flutter SDK (see https://flutter.dev). The project uses Dart SDK >= 3.11.
- **Install dependencies**: `flutter pub get`
- **Run on device/emulator**: `flutter run`

**Project Structure (key files)**
- **Main entry**: [lib/main.dart](lib/main.dart#L1)
- **App widget**: [lib/app.dart](lib/app.dart#L1)
- **Database init + access**: [lib/database/expense_database.dart](lib/database/expense_database.dart#L1) and [lib/database/sqflite_init.dart](lib/database/sqflite_init.dart#L1)
- **Main UI shell**: [lib/screens/main_shell_screen.dart](lib/screens/main_shell_screen.dart#L1)
- **Screens**: budgets, insights, dashboard (see `lib/screens/`)

**Features**
- **Add / Edit / Remove expenses** with categories and notes.
- **Persistent local storage** using `sqflite` (Android/iOS) and `sqflite_common_ffi` for desktop/dev.
- **Budgets & category budgets** to track spending against limits.
- **Analytics & insights** with charts and summaries to review spending patterns.
- **Theming**: light and dark themes with a theme toggle provider.
- **State management**: implemented using `flutter_riverpod` providers.

**Usage Notes**
- The app initializes a local database on startup. See `lib/database/sqflite_init.dart` for platform-specific initialization.
- To change supported locales or formatting, adjust `intl` usages and locale settings.
- For development on desktop, `sqflite_common_ffi` is included to run the same database code.

**Development tips**
- Run unit or widget tests with: `flutter test`
- Format code: `flutter format .`
- Add new providers under `lib/providers/` and wire them into the UI via `ProviderScope` overrides when needed.

**Where to look next**
- Data model: `lib/models/expense.dart`
- Providers: `lib/providers/` (analytics, budgets, expenses, theme, filters)
- Widgets: `lib/widgets/` (charts, expense form, lists)

**Contributing**
- Feel free to open issues or PRs. Keep changes small and focused. Add tests for new logic.

