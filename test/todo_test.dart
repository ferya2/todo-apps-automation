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

    test('dueDate defaults to null', () {
      final todo = Todo(title: 'Write tests');
      expect(todo.dueDate, isNull);
    });

    test('priority defaults to medium', () {
      final todo = Todo(title: 'Write tests');
      expect(todo.priority, TodoPriority.medium);
    });

    test('toMap contains the expected fields', () {
      final createdAt = DateTime(2026, 9, 10, 8, 30);
      final dueDate = DateTime(2026, 9, 20);
      final todo = Todo(
        id: 7,
        title: 'Buy milk',
        isCompleted: true,
        dueDate: dueDate,
        priority: TodoPriority.high,
        createdAt: createdAt,
      );

      expect(todo.toMap(), {
        'id': 7,
        'title': 'Buy milk',
        'isCompleted': 1,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'priority': 'high',
      });
    });

    test('toMap serializes priority as its enum name', () {
      final todo = Todo(title: 'Buy milk');
      expect(todo.toMap()['priority'], 'medium');
    });

    test(
      'toMap serializes an uncompleted todo with isCompleted 0 and no due date',
      () {
        final todo = Todo(title: 'Buy milk');
        expect(todo.toMap()['isCompleted'], 0);
        expect(todo.toMap()['dueDate'], isNull);
      },
    );

    test('fromMap parses a completed todo', () {
      final createdAt = DateTime(2026, 9, 10, 8, 30);
      final dueDate = DateTime(2026, 9, 25);
      final todo = Todo.fromMap({
        'id': 3,
        'title': 'Walk the dog',
        'isCompleted': 1,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'dueDate': dueDate.millisecondsSinceEpoch,
        'priority': 'low',
      });

      expect(todo.id, 3);
      expect(todo.title, 'Walk the dog');
      expect(todo.isCompleted, isTrue);
      expect(todo.dueDate, dueDate);
      expect(todo.priority, TodoPriority.low);
      expect(todo.createdAt, createdAt);
    });

    test('fromMap defaults priority to medium when the column is missing', () {
      final todo = Todo.fromMap({
        'id': 4,
        'title': 'Walk the dog',
        'isCompleted': 0,
        'createdAt': 0,
      });

      expect(todo.priority, TodoPriority.medium);
    });

    test('fromMap parses an uncompleted todo without a due date', () {
      final todo = Todo.fromMap({
        'id': 4,
        'title': 'Walk the dog',
        'isCompleted': 0,
        'createdAt': 0,
      });

      expect(todo.isCompleted, isFalse);
      expect(todo.dueDate, isNull);
    });

    test('round-trips through toMap and fromMap', () {
      final original = Todo(
        id: 42,
        title: 'Ship it',
        isCompleted: true,
        dueDate: DateTime(2026, 9, 30),
        priority: TodoPriority.high,
        createdAt: DateTime(2026, 9, 10, 23, 59, 59),
      );

      final restored = Todo.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.isCompleted, original.isCompleted);
      expect(restored.dueDate, original.dueDate);
      expect(restored.priority, original.priority);
      expect(restored.createdAt, original.createdAt);
    });
  });
}
