import 'package:flutter/foundation.dart' hide Category;

import 'package:todo_app/data/category_dao.dart';
import 'package:todo_app/data/todo_dao.dart';
import 'package:todo_app/models/category.dart';
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
  ///
  /// Pass [categoryDao] to also load the categories available for assignment;
  /// it is optional so tests that only exercise todos can leave it out.
  TodoProvider(this.dao, {CategoryDao? categoryDao})
    : _categoryDao = categoryDao;

  /// The DAO this provider reads from and writes to.
  final TodoDao dao;

  final CategoryDao? _categoryDao;

  List<Todo> _todos = [];
  List<Category> _categories = [];

  /// The current list of todos (read-only view).
  List<Todo> get todos => List.unmodifiable(_todos);

  /// The current list of categories available for assignment.
  List<Category> get categories => List.unmodifiable(_categories);

  /// Loads all todos from the DAO, replacing the in-memory list.
  ///
  /// Notifies listeners once the load completes.
  Future<void> loadTodos() async {
    _todos = await dao.getAll();
    notifyListeners();
  }

  /// Loads all categories from [CategoryDao], replacing the in-memory list.
  ///
  /// Notifies listeners once the load completes. No-op when the provider was
  /// created without a [CategoryDao].
  Future<void> loadCategories() async {
    final categoryDao = _categoryDao;
    if (categoryDao == null) return;
    _categories = await categoryDao.getAll();
    notifyListeners();
  }

  /// Returns the name of the category with the given [id], or null when [id]
  /// is null or no such category is loaded.
  String? categoryNameFor(int? id) {
    if (id == null) return null;
    for (final category in _categories) {
      if (category.id == id) return category.name;
    }
    return null;
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
}
