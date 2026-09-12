import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('TodoDao', () {
    late DatabaseHelper helper;
    late TodoDao dao;

    setUp(() {
      helper = DatabaseHelper(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      dao = TodoDao(helper);
    });

    tearDown(() async {
      await helper.close();
    });

    test('insert returns a positive id', () async {
      final todo = Todo(title: 'Buy milk');
      final id = await dao.insert(todo);
      expect(id, greaterThan(0));
    });

    test('insert persists the row with its fields', () async {
      final todo = Todo(title: 'Walk the dog', isCompleted: false);
      final id = await dao.insert(todo);

      final db = await helper.database;
      final rows = await db.query('todos', where: 'id = ?', whereArgs: [id]);
      expect(rows.length, 1);
      expect(rows.first['title'], 'Walk the dog');
      expect(rows.first['isCompleted'], 0);
    });

    test('getById returns the inserted todo', () async {
      final todo = Todo(title: 'Buy milk', isCompleted: true);
      final id = await dao.insert(todo);

      final saved = await dao.getById(id);
      expect(saved, isNotNull);
      expect(saved!.id, id);
      expect(saved.title, 'Buy milk');
      expect(saved.isCompleted, true);
      expect(
        saved.createdAt.millisecondsSinceEpoch,
        todo.createdAt.millisecondsSinceEpoch,
      );
    });

    test('getById returns null for a missing id', () async {
      final saved = await dao.getById(999);
      expect(saved, isNull);
    });

    test('getAll returns inserted todos ordered by id', () async {
      final first = await dao.insert(Todo(title: 'First'));
      final second = await dao.insert(Todo(title: 'Second'));

      final todos = await dao.getAll();
      expect(todos.map((t) => t.id), [first, second]);
      expect(todos.map((t) => t.title), ['First', 'Second']);
    });

    test('getAll returns an empty list when there are no todos', () async {
      final todos = await dao.getAll();
      expect(todos, isEmpty);
    });

    group('update', () {
      test('updates the title and isCompleted fields', () async {
        final id = await dao.insert(Todo(title: 'Original'));
        final saved = (await dao.getById(id))!;

        final updated = Todo(
          id: saved.id,
          title: 'Updated title',
          isCompleted: true,
          createdAt: saved.createdAt,
        );
        final changed = await dao.update(updated);

        expect(changed, 1);
        final fetched = await dao.getById(id);
        expect(fetched!.title, 'Updated title');
        expect(fetched.isCompleted, true);
      });

      test('returns 0 when updating a non-existent id', () async {
        final changed = await dao.update(Todo(id: 999, title: 'Ghost'));
        expect(changed, 0);
      });
    });

    group('delete', () {
      test('deletes the todo and returns 1', () async {
        final id = await dao.insert(Todo(title: 'To be deleted'));
        final deleted = await dao.delete(id);

        expect(deleted, 1);
        expect(await dao.getById(id), isNull);
      });

      test('returns 0 when deleting a non-existent id', () async {
        final deleted = await dao.delete(999);
        expect(deleted, 0);
      });
    });
  });
}
