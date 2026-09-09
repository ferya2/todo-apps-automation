# Architecture

## Overview

A single-module Flutter mobile app. No network, no backend. All state is derived
from a local **SQLite** database and held in memory via `provider` during a session.

```
┌──────────────────────────────────────────────┐
│                   UI Layer                    │
│   screens/  +  widgets/                       │
│   (Flutter widgets, listen to providers)      │
└───────────────────────┬──────────────────────┘
                        │ read/notify
                        ▼
┌──────────────────────────────────────────────┐
│               State Layer                     │
│   providers/  (ChangeNotifier)                │
│   holds the current list, filters, sorting    │
└───────────────────────┬──────────────────────┘
                        │ calls
                        ▼
┌──────────────────────────────────────────────┐
│                Data Layer                     │
│   data/  DAOs  +  DatabaseHelper              │
│   models/  plain data classes                 │
└───────────────────────┬──────────────────────┘
                        │ SQL
                        ▼
┌──────────────────────────────────────────────┐
│                  SQLite                       │
│            (on-device, sqflite)               │
└──────────────────────────────────────────────┘
```

## Rules of the layers

- **UI** never talks to SQLite directly. It goes through a provider.
- **Providers** never build SQL by hand. They call DAO methods.
- **DAOs** are the only place that touches SQLite.
- **Models** are pure Dart (no Flutter imports), so they are easy to unit test.

## Database

- One `DatabaseHelper` (singleton) opens/creates the DB and holds the schema version.
- Schema changes go through `onUpgrade` migrations — never drop user data casually.
- Tables grow over the roadmap: `todos` first, then `categories`, etc.

## Testing strategy

| Layer      | How it is tested                                  |
|------------|---------------------------------------------------|
| models     | pure unit tests                                   |
| utils      | pure unit tests (filter, sort, date format)       |
| data/DAO   | unit tests with `sqflite_common_ffi` (in-memory)  |
| providers  | unit tests with a fake/in-memory DAO              |
| screens    | widget tests where practical                      |

Business logic must always be testable **without** a running device/emulator.
