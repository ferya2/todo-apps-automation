# Todo App

A cross-platform mobile **Todo List** app built with **Flutter** and **SQLite**
(local, on-device — no backend). Built incrementally by an autonomous AI
development agent: one small, reviewed task per day.

## Tech Stack

- Flutter (Dart)
- SQLite via `sqflite`
- `provider` for state management

## How It's Built

- Features are planned in [.ai/ROADMAP.md](.ai/ROADMAP.md) and broken into a
  30-day plan in [.ai/TASKS.md](.ai/TASKS.md).
- A daily GitHub Actions workflow picks one task, implements it, runs
  `dart format` / `flutter analyze` / `flutter test`, and opens a Pull Request.
- Releases (versioned APK) are cut automatically on merge to `main` via
  semantic-release.

## Getting Started

```bash
flutter pub get
flutter run
```

## Progress

<!-- The agent appends one short bullet here per completed task. -->

- Project scaffolding and autonomous CI/CD pipeline set up.
- Day 01: project scaffold — created the `data/`, `models/`, `providers/`,
  `screens/`, `widgets/`, `utils/` folder structure with placeholder files;
  app runs and shows an empty Todo home.
- Day 02: added dependencies — `sqflite`, `path`, `provider`
  (`sqflite_common_ffi` for tests) with a wiring smoke test.
- Day 03: added `DatabaseHelper` singleton — opens/creates SQLite DB (schema v1,
  no tables) with an `onUpgrade` hook, unit-tested with `sqflite_common_ffi`.
- Day 04: added the `Todo` model — `id`, `title`, `isCompleted`, `createdAt`
  with `toMap()` / `fromMap()` and full unit tests.
- Day 05: added the `todos` table (schema v2 migration) and `TodoDao.insert`,
  which returns the auto-generated id; unit-tested with `sqflite_common_ffi`.
- Day 06: added `TodoDao.getAll()` and `TodoDao.getById(id)` with round-trip
  unit tests (insert then read).
- Day 07: added `TodoDao.update(todo)` and `TodoDao.delete(id)` with unit tests
  for field updates, non-existent rows, and round-trip delete.
- Day 08: added `AppTheme` (Material 3 colors + typography) and a `HomeScreen`
  scaffold with an AppBar, an empty body, and a FAB placeholder; widget-tested.
- Day 09: added `TodoProvider` (ChangeNotifier) that loads todos from `TodoDao`
  and exposes the list; unit-tested with an in-memory DAO.
- Day 10: rendered the provider's todos as a `ListView` on the home screen,
  wired the app to a `TodoProvider`, and added a widget test with seeded data.
- Day 11: added an `AddTodoScreen` with a title field and Save button (UI only);
  the home FAB now opens it. Empty-title validation via widget test.
- Day 12: wired the add screen → provider → DAO so saving a new todo persists it
  to SQLite and it appears in the list; tested the full flow end-to-end.
- Day 13: added a completion checkbox to each list item — tapping it toggles
  `isCompleted` via `TodoProvider.toggleCompleted` → `TodoDao.update` → SQLite;
  tested the provider logic and the checkbox widget interaction with an in-memory DB.
- Day 14: added an `EditTodoScreen` — tapping a todo on the home screen opens it
  prefilled with the title; saving updates the DB via `TodoProvider.updateTodo`
  and refreshes the list. Tested the full edit flow.
- Day 16: added an optional `dueDate` to the todo model and `todos` table (schema
  v3 migration) plus a `DueDateField` date picker in the add/edit forms; picked
  dates are persisted and re-displayed. Tested the model round-trip, the v2→v3
  migration, and the picker flow in both screens.
- Day 17: added `priority` (low/medium/high enum) to the todo model and `todos`
  table (schema v4 migration) plus a `PriorityField` selector in the add/edit
  forms and a colored `PriorityIndicator` dot in the list. Tested the model +
  DAO round-trip, the v3→v4 migration, and the selector/indicator widgets.
- Day 18: added a `Category` model and `categories` table (schema v5 migration)
  plus a `CategoryDao` (`insert` / `getAll`); unit-tested the model, the DAO,
  and the v4→v5 migration.
