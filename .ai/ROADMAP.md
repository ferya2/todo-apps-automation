# Roadmap — Flutter Todo App (SQLite)

This is the source of truth for **what** to build. The agent picks tasks from
`.ai/TASKS.md` (the day-by-day breakdown). This file tracks features at a higher
level. Tick a box when the whole feature is done.

## Phase 1 — Foundation (Week 1)

- [x] Flutter project scaffold + folder structure
- [x] Dependencies (sqflite, path, provider)
- [x] SQLite `DatabaseHelper` (open/create DB)
- [x] `Todo` model
- [x] Todo DAO: create
- [x] Todo DAO: read / list
- [x] Todo DAO: update
- [x] Todo DAO: delete

## Phase 2 — Core UI (Week 2)

- [x] App theme + home screen scaffold
- [ ] TodoProvider (state management)
- [ ] Todo list view (render from DB)
- [ ] Add todo screen + form
- [ ] Save new todo to DB
- [ ] Toggle "completed" state
- [ ] Edit todo
- [ ] Delete todo (swipe to dismiss)

## Phase 3 — Features (Week 3)

- [ ] Due date + date picker
- [ ] Priority (low / medium / high)
- [ ] `Category` model + table + DAO
- [ ] Assign category to a todo (UI)
- [ ] Filter by status (all / active / completed)
- [ ] Filter by category
- [ ] Search todos by title

## Phase 4 — Polish (Week 4)

- [ ] Sort (by due date / priority)
- [ ] Empty state + loading state
- [ ] Dark mode toggle
- [ ] Local notification on due date
- [ ] Todo detail screen
- [ ] Statistics (completed vs pending)
- [ ] Settings screen
- [ ] Final polish, bug fixes, README

---

**Rule:** the agent does not invent new features. If something is missing, a human
adds it here first.
