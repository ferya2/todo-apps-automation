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
  });
}
