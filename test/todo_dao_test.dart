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
  });
}
