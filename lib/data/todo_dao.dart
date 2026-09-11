import 'package:todo_app/data/database_helper.dart';
import 'package:todo_app/models/todo.dart';

/// Data access object for the `todos` table.
class TodoDao {
  /// Creates a DAO backed by the given [DatabaseHelper].
  TodoDao(this.helper);

  /// The database helper this DAO reads from and writes to.
  final DatabaseHelper helper;

  /// Inserts [todo] and returns the new row's auto-generated id.
  ///
  /// The [Todo.id] is excluded so SQLite assigns it via `AUTOINCREMENT`.
  Future<int> insert(Todo todo) async {
    final db = await helper.database;
    final values = Map<String, Object?>.from(todo.toMap());
    values.remove('id');
    return db.insert('todos', values);
  }

  /// Returns all todos ordered by insertion order (`id` ascending), or an
  /// empty list if none exist.
  Future<List<Todo>> getAll() async {
    final db = await helper.database;
    final rows = await db.query('todos', orderBy: 'id ASC');
    return rows.map(Todo.fromMap).toList();
  }

  /// Returns the todo with the given [id], or null if no such row exists.
  Future<Todo?> getById(int id) async {
    final db = await helper.database;
    final rows = await db.query('todos', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Todo.fromMap(rows.first);
  }
}
