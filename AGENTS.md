# AI Development Instructions

## Project

This is a **cross-platform mobile Todo List application** built with **Flutter**,
using **SQLite** (local, on-device) as the only data store. There is no backend
server; all data lives on the device.

Target platform: **Android & iOS** (mobile first).

## Stack

- **Framework:** Flutter (Dart)
- **Local database:** SQLite via the `sqflite` package
- **State management:** `provider` (keep it simple; do not introduce Bloc/Riverpod
  unless the roadmap explicitly asks for it)
- **Testing:** `flutter_test` (widget tests) + `sqflite_common_ffi` for DB unit tests

## Architecture

Use a **layered / feature-based architecture**:

```
lib/
├── main.dart
├── data/          # SQLite: database helper, DAOs
├── models/        # plain Dart data classes (Todo, Category, ...)
├── providers/     # state management (ChangeNotifier)
├── screens/       # full pages
├── widgets/       # reusable UI components
└── utils/         # helpers (date formatting, sorting, filtering)
```

Do NOT introduce a new architectural pattern unless the task explicitly requires it.

## Development Rules

- Follow existing coding conventions and folder structure.
- Do not rewrite unrelated code.
- **Keep changes small — one task from `.ai/TASKS.md` per run.**
- Add unit tests for all database (DAO) and business logic (filter/sort/validation).
- Add a widget test when you add or change a screen/widget, where practical.
- Do not remove existing tests.
- Do not introduce a new dependency unless the task requires it; justify it in the PR.
- Never hardcode secrets. This app has none — do not add any.
- Keep every widget/file focused and readable.
- Do NOT edit the `version:` field in `pubspec.yaml` — it is managed
  automatically by the release workflow (semantic-release).
- Do NOT add any AI attribution (no `Co-Authored-By`, no "Generated with
  Claude", no bot signatures) to commits or PR descriptions.

## Budget Awareness (IMPORTANT)

This project runs on **OpenRouter free-tier models** with a limited daily request
budget. Therefore:

- Do **exactly ONE** task per run (the next unchecked day in `.ai/TASKS.md`).
- Prefer the smallest correct implementation.
- Do not refactor the whole codebase in one run.
- Do not read every file — read only what the current task needs.

## Before Finishing

Run, in order:

- `dart format .`
- `flutter analyze`
- `flutter test`

Only create a commit if **all** checks pass. If a task cannot be completed safely
or cleanly, make no changes.

## Commit Format

```
<type>(<scope>): <description>
```

Example:

```
feat(todo): add SQLite insert for todo items
```
