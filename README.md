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
