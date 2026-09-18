import 'package:todo_app/data/database_helper.dart';
import 'package:todo_app/models/category.dart';

/// Data access object for the `categories` table.
class CategoryDao {
  /// Creates a DAO backed by the given [DatabaseHelper].
  CategoryDao(this.helper);

  /// The database helper this DAO reads from and writes to.
  final DatabaseHelper helper;

  /// Inserts [category] and returns the new row's auto-generated id.
  ///
  /// The [Category.id] is excluded so SQLite assigns it via `AUTOINCREMENT`.
  Future<int> insert(Category category) async {
    final db = await helper.database;
    final values = Map<String, Object?>.from(category.toMap());
    values.remove('id');
    return db.insert('categories', values);
  }

  /// Returns all categories ordered by insertion order (`id` ascending), or an
  /// empty list if none exist yet.
  Future<List<Category>> getAll() async {
    final db = await helper.database;
    final rows = await db.query('categories', orderBy: 'id ASC');
    return rows.map(Category.fromMap).toList();
  }
}
