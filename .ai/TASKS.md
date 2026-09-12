# Daily Tasks — 30 Day Plan

One task per day. Each task is deliberately **small** so a single autonomous run
stays within the OpenRouter free-tier daily budget. The agent works on the **first
unchecked** day, completes it, ticks the box, and opens a PR.

> Scope discipline: if a day feels too big, do the minimum that is complete and
> tested, and leave the rest as a new day. Never bundle two days into one run.

---

## Week 1 — Foundation

- [x] **Day 01 — Project scaffold.** Initialize the Flutter project. Create the
  folder structure from `AGENTS.md` (`data/`, `models/`, `providers/`, `screens/`,
  `widgets/`, `utils/`) with placeholder files. App runs and shows an empty home.
- [x] **Day 02 — Dependencies.** Add `sqflite`, `path`, `provider` to
  `pubspec.yaml`. Run `flutter pub get`. No feature yet — just wiring + a smoke test.
- [x] **Day 03 — DatabaseHelper.** Create a singleton `DatabaseHelper` in `data/`
  that opens/creates the SQLite DB (schema version 1, no tables yet). Unit test it
  opens successfully with `sqflite_common_ffi`.
- [x] **Day 04 — Todo model.** Create the `Todo` model in `models/` (id, title,
  isCompleted, createdAt). Add `toMap()` / `fromMap()`. Full unit test.
- [x] **Day 05 — todos table + insert DAO.** Add the `todos` table to the schema.
  Create `TodoDao.insert(todo)`. Unit test insert returns an id.
- [x] **Day 06 — read DAO.** Add `TodoDao.getAll()` and `TodoDao.getById(id)`.
  Unit test round-trip (insert then read).
- [x] **Day 07 — update & delete DAO.** Added `TodoDao.update(todo)` and
  `TodoDao.delete(id)` with unit tests.

## Week 2 — Core UI

- [x] **Day 08 — Theme + home scaffold.** App theme (colors, typography) and a
  `HomeScreen` with an AppBar and an empty body + FAB placeholder. Widget test it
  renders.
- [ ] **Day 09 — TodoProvider.** Create `TodoProvider` (ChangeNotifier) that loads
  todos from `TodoDao` and exposes the list. Unit test with an in-memory DAO.
- [ ] **Day 10 — Todo list view.** Render the todos from the provider as a
  `ListView` on the home screen. Widget test with seeded data.
- [ ] **Day 11 — Add todo screen.** Create an `AddTodoScreen` with a title text
  field and a save button (UI only, validation for empty title). Widget test.
- [ ] **Day 12 — Save new todo.** Wire the add screen → provider → DAO so a new
  todo persists and appears in the list. Test the flow.
- [ ] **Day 13 — Toggle completed.** Add a checkbox on each list item that toggles
  `isCompleted` and persists it. Test the toggle updates the DB.
- [ ] **Day 14 — Edit todo.** Tapping a todo opens an edit screen; saving updates
  the DB and list. Test the update flow.

## Week 3 — Features

- [ ] **Day 15 — Delete todo.** Swipe-to-dismiss removes a todo from DB and list,
  with an undo snackbar. Test deletion.
- [ ] **Day 16 — Due date.** Add `dueDate` to the model/table (migration to schema
  v2) + a date picker in the add/edit form. Test model + migration.
- [ ] **Day 17 — Priority.** Add `priority` (low/medium/high enum) to model/table
  (migration) + a selector in the form + a colored indicator in the list. Test.
- [ ] **Day 18 — Category model + table.** Add `Category` model and `categories`
  table (migration) + `CategoryDao` (insert/getAll). Unit test the DAO.
- [ ] **Day 19 — Assign category.** Add `categoryId` to todos (migration) + a
  category dropdown in the form. Show the category name on the list item. Test.
- [ ] **Day 20 — Filter by status.** Add a filter (all / active / completed) in the
  provider + a UI control (tabs or chips). Unit test the filter logic in `utils/`.
- [ ] **Day 21 — Filter by category.** Add category filtering to the provider + UI.
  Unit test the filter logic.

## Week 4 — Polish

- [ ] **Day 22 — Search.** Add a search field that filters todos by title
  (case-insensitive). Unit test the search logic in `utils/`.
- [ ] **Day 23 — Sort.** Sort todos by due date or priority (provider + UI toggle).
  Unit test the sort comparators in `utils/`.
- [ ] **Day 24 — Empty & loading states.** Show a friendly empty state and a loading
  indicator while the DB query runs. Widget test both states.
- [ ] **Day 25 — Dark mode.** Add a light/dark theme toggle persisted via a simple
  settings table or shared_preferences. Test the toggle logic.
- [ ] **Day 26 — Todo detail screen.** A read-only detail screen showing all fields
  (title, due date, priority, category, status). Widget test.
- [ ] **Day 27 — Local notification.** Schedule a local notification at a todo's due
  date (add `flutter_local_notifications`). Test the scheduling helper (pure logic).
- [ ] **Day 28 — Statistics.** A small stats section: total, completed, pending
  counts + completion %. Unit test the counting logic in `utils/`.
- [ ] **Day 29 — Settings screen.** A settings screen (theme toggle, maybe clear-all
  with confirmation). Widget test.
- [ ] **Day 30 — Final polish.** Fix small bugs, tidy widgets, write the app
  `README.md` (features, screenshots placeholder, how to run). No new features.

---

### Notes for the human (product owner)

- Adjust or reorder freely **before** the agent reaches a day.
- If OpenRouter's free budget still gets tight, split a heavy day (16, 17, 19) into
  two: one day for the model/migration + test, the next for the UI.
