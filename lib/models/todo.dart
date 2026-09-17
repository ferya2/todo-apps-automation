/// How urgent a todo is.
///
/// Stored in SQLite as the enum's [TodoPriority.name] (a text column).
enum TodoPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TodoPriority(this.label);

  /// A human-readable, capitalized label for display in the UI.
  final String label;
}

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
    this.dueDate,
    this.priority = TodoPriority.medium,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Database row id, or null if the todo has not been saved yet.
  final int? id;

  /// The todo's text.
  final String title;

  /// Whether the todo has been completed.
  bool isCompleted;

  /// When the todo should be completed by, or null when there is no deadline.
  final DateTime? dueDate;

  /// How urgent the todo is.
  final TodoPriority priority;

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
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority.name,
    };
  }

  /// Deserializes a todo from a SQLite row map (the inverse of [toMap]).
  factory Todo.fromMap(Map<String, Object?> map) {
    return Todo(
      id: map['id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['isCompleted'] as int) == 1,
      dueDate: map['dueDate'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['dueDate'] as int),
      priority: map['priority'] is String
          ? TodoPriority.values.byName(map['priority'] as String)
          : TodoPriority.medium,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
