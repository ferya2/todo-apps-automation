# Development & Validation

## Prerequisites

- Flutter SDK (stable channel)
- Dart (bundled with Flutter)

## Setup

```bash
flutter pub get
```

## Validation commands (the agent MUST run these before committing)

```bash
dart format .        # format
flutter analyze      # static analysis / lint
flutter test         # unit + widget tests
```

All three must pass before a commit is created.

## Running the app locally (human only)

```bash
flutter run
```

## Conventions

- File names: `snake_case.dart`
- Classes: `PascalCase`
- One widget per file when the widget is non-trivial.
- Keep functions short; extract helpers into `utils/`.

## Definition of Done (per daily task)

1. Feature implemented as described in `.ai/TASKS.md`.
2. Tests added/updated and passing.
3. `dart format .` produces no changes.
4. `flutter analyze` reports no new issues.
5. `.ai/ROADMAP.md` checkbox ticked if the feature is complete.
6. One atomic commit + PR.
