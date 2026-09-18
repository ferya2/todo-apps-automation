import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  group('CategoryDao', () {
    late DatabaseHelper helper;
    late CategoryDao dao;

    setUp(() {
      helper = DatabaseHelper(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      dao = CategoryDao(helper);
    });

    tearDown(() async {
      await helper.close();
    });

    test('insert returns a positive id', () async {
      final id = await dao.insert(Category(name: 'Work'));
      expect(id, greaterThan(0));
    });

    test('insert persists the row with its fields', () async {
      final id = await dao.insert(Category(name: 'Home'));

      final db = await helper.database;
      final rows = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: [id],
      );
      expect(rows.length, 1);
      expect(rows.first['id'], id);
      expect(rows.first['name'], 'Home');
    });

    test('getAll returns inserted categories ordered by id', () async {
      final first = await dao.insert(Category(name: 'Work'));
      final second = await dao.insert(Category(name: 'Personal'));

      final categories = await dao.getAll();
      expect(categories.map((c) => c.id), [first, second]);
      expect(categories.map((c) => c.name), ['Work', 'Personal']);
    });

    test('getAll returns an empty list when there are no categories', () async {
      final categories = await dao.getAll();
      expect(categories, isEmpty);
    });
  });
}
