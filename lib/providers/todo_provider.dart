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

  /// The DAO this provider reads from and (later) writes to.
  final TodoDao dao;

  List<Todo> _todos = [];

  /// The current list of todos (read-only view).
  List<Todo> get todos => List.unmodifiable(_todos);

  /// Loads all todos from the DAO, replacing the in-memory list.
  ///
  /// Notifies listeners once the load completes.
  Future<void> loadTodos() async {
    _todos = await dao.getAll();
    notifyListeners();
  }
}
