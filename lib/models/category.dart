/// A category used to group todos.
///
/// Pure Dart (no Flutter imports) so it is easy to unit test. [id] is null
/// until the category is persisted to the database (it is assigned by SQLite's
/// auto-increment on insert).
class Category {
  Category({this.id, required this.name});

  /// Database row id, or null if the category has not been saved yet.
  final int? id;

  /// The category's display name.
  final String name;

  /// Serializes this category to a map suitable for SQLite.
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name};
  }

  /// Deserializes a category from a SQLite row map (the inverse of [toMap]).
  factory Category.fromMap(Map<String, Object?> map) {
    return Category(id: map['id'] as int?, name: map['name'] as String);
  }
}
