/// A single todo item.
///
/// Pure Dart (no Flutter imports) so it is easy to unit test. [id] is null
/// until the todo is persisted to the database (it is assigned by SQLite's
/// auto-increment on insert).
class Todo {
  Todo({
    this.id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Database row id, or null if the todo has not been saved yet.
  final int? id;

  /// The todo's text.
  final String title;

  /// Whether the todo has been completed.
  bool isCompleted;

  /// When the todo was created.
  final DateTime createdAt;

  /// Serializes this todo to a map suitable for SQLite (dates and booleans
  /// stored as ints).
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  /// Deserializes a todo from a SQLite row map (the inverse of [toMap]).
  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
