import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/models/models.dart';

void main() {
  group('Todo', () {
    test('constructor defaults isCompleted to false', () {
      final todo = Todo(title: 'Write tests');
      expect(todo.isCompleted, isFalse);
    });

    test('createdAt defaults to now', () {
      final before = DateTime.now();
      final todo = Todo(title: 'Write tests');
      final after = DateTime.now();
      expect(todo.createdAt.isBefore(before), isFalse);
      expect(todo.createdAt.isAfter(after), isFalse);
    });

    test('id is null when not persisted', () {
      final todo = Todo(title: 'Write tests');
      expect(todo.id, isNull);
    });

    test('toMap contains the expected fields', () {
      final createdAt = DateTime(2026, 9, 10, 8, 30);
      final todo = Todo(
        id: 7,
        title: 'Buy milk',
        isCompleted: true,
        createdAt: createdAt,
      );

      expect(todo.toMap(), {
        'id': 7,
        'title': 'Buy milk',
        'isCompleted': 1,
        'createdAt': createdAt.millisecondsSinceEpoch,
      });
    });

    test('toMap serializes an uncompleted todo with isCompleted 0', () {
      final todo = Todo(title: 'Buy milk');
      expect(todo.toMap()['isCompleted'], 0);
    });

    test('fromMap parses a completed todo', () {
      final createdAt = DateTime(2026, 9, 10, 8, 30);
      final todo = Todo.fromMap({
        'id': 3,
        'title': 'Walk the dog',
        'isCompleted': 1,
        'createdAt': createdAt.millisecondsSinceEpoch,
      });

      expect(todo.id, 3);
      expect(todo.title, 'Walk the dog');
      expect(todo.isCompleted, isTrue);
      expect(todo.createdAt, createdAt);
    });

    test('fromMap parses an uncompleted todo', () {
      final todo = Todo.fromMap({
        'id': 4,
        'title': 'Walk the dog',
        'isCompleted': 0,
        'createdAt': 0,
      });

      expect(todo.isCompleted, isFalse);
    });

    test('round-trips through toMap and fromMap', () {
      final original = Todo(
        id: 42,
        title: 'Ship it',
        isCompleted: true,
        createdAt: DateTime(2026, 9, 10, 23, 59, 59),
      );

      final restored = Todo.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
