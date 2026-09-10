import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('DatabaseHelper', () {
    late DatabaseHelper helper;

    setUp(() {
      helper = DatabaseHelper(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
    });

    tearDown(() async {
      await helper.close();
    });

    test('opens successfully', () async {
      final db = await helper.database;
      expect(db.isOpen, isTrue);
    });

    test('reports schema version 1', () async {
      final db = await helper.database;
      expect(await db.getVersion(), DatabaseHelper.schemaVersion);
    });

    test('caches the same database instance', () async {
      final db1 = await helper.database;
      final db2 = await helper.database;
      expect(identical(db1, db2), isTrue);
    });

    test('close() allows re-opening', () async {
      final db = await helper.database;
      expect(db.isOpen, isTrue);

      await helper.close();

      final db2 = await helper.database;
      expect(db2.isOpen, isTrue);
      expect(identical(db, db2), isFalse);
    });
  });
}
