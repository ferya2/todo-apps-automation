import 'package:flutter/foundation.dart';

import 'package:todo_app/data/todo_dao.dart';
import 'package:todo_app/models/todo.dart';

/// State management for the todo list.
///
/// Loads todos from [TodoDao] and holds them in memory for the session.
/// Exposes the list to UI widgets (via [ChangeNotifier]) and notifies
/// listeners whenever the list is reloaded.
///
/// Providers never build SQL by hand — they call DAO methods. The DAO is
/// injected so tests can pass a real in-memory DAO or a fake.
class TodoProvider extends ChangeNotifier {
  /// Creates a provider backed by [dao].
  TodoProvider(this.dao);

  /// The DAO this provider reads from and writes to.
  final TodoDao dao;

  List<Todo> _todos = [];

  /// The todo most recently removed by [deleteTodo], retained so
  /// [undoDelete] can restore it.
  Todo? _lastDeleted;

  /// The current list of todos (read-only view).
  List<Todo> get todos => List.unmodifiable(_todos);

  /// Loads all todos from the DAO, replacing the in-memory list.
  ///
  /// Notifies listeners once the load completes.
  Future<void> loadTodos() async {
    _todos = await dao.getAll();
    notifyListeners();
  }

  /// Saves [todo] via the DAO and reloads the list from the database so it
  /// reflects the newly inserted row.
  ///
  /// Notifies listeners once the insert and reload complete.
  Future<void> addTodo(Todo todo) async {
    await dao.insert(todo);
    await loadTodos();
  }

  /// Replaces [todo] in the database with its current field values and reloads
  /// the list so the UI reflects the saved row.
  ///
  /// Notifies listeners once the update and reload complete.
  Future<void> updateTodo(Todo todo) async {
    await dao.update(todo);
    await loadTodos();
  }

  /// Toggles the [Todo.isCompleted] flag on [todo], persists it via the DAO,
  /// and reloads the list so the UI reflects the saved value.
  ///
  /// Notifies listeners once the update and reload complete.
  Future<void> toggleCompleted(Todo todo) async {
    todo.isCompleted = !todo.isCompleted;
    await dao.update(todo);
    await loadTodos();
  }

  /// Deletes [todo] from the database and reloads the list so the UI
  /// reflects the removal.
  ///
  /// The deleted todo is retained so [undoDelete] can restore it. Notifies
  /// listeners once the delete and reload complete.
  Future<void> deleteTodo(Todo todo) async {
    _lastDeleted = todo;
    if (todo.id != null) {
      await dao.delete(todo.id!);
    }
    await loadTodos();
  }

  /// Re-inserts the todo removed by the most recent [deleteTodo] call and
  /// reloads the list so the UI reflects the restoration.
  ///
  /// A no-op when there is nothing to undo. Notifies listeners once the
  /// re-insert and reload complete.
  Future<void> undoDelete() async {
    final todo = _lastDeleted;
    if (todo == null) return;
    await dao.insert(todo);
    _lastDeleted = null;
    await loadTodos();
  }
}
