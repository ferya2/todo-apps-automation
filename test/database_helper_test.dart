import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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

    test('reports the current schema version', () async {
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

    test(
      'migrates a version 2 database to the current schema, preserving data',
      () async {
        final dir = await Directory.systemTemp.createTemp(
          'todo_migration_test',
        );
        final path = p.join(dir.path, 'todo_v2.db');

        // Build a v2 database with the todos table but no dueDate column.
        final factory = databaseFactoryFfi;
        final v2 = await factory.openDatabase(
          path,
          options: OpenDatabaseOptions(
            version: 2,
            onUpgrade: (db, oldVersion, newVersion) async {
              if (oldVersion < 2) {
                await db.execute('''
                CREATE TABLE IF NOT EXISTS todos (
                  id INTEGER PRIMARY KEY AUTOINCREMENT,
                  title TEXT NOT NULL,
                  isCompleted INTEGER NOT NULL DEFAULT 0,
                  createdAt INTEGER NOT NULL
                )
              ''');
              }
            },
          ),
        );
        final legacyId = await v2.insert('todos', {
          'title': 'Legacy todo',
          'isCompleted': 0,
          'createdAt': 0,
        });
        await v2.close();

        // Re-open with the current helper (schema v3), which should migrate it.
        final migratedHelper = DatabaseHelper(
          databaseFactory: factory,
          databasePath: path,
        );
        final db = await migratedHelper.database;

        expect(await db.getVersion(), DatabaseHelper.schemaVersion);
        final columns = await db.rawQuery('PRAGMA table_info(todos)');
        expect(columns.map((c) => c['name']), contains('dueDate'));

        final rows = await db.query('todos');
        expect(rows.length, 1);
        expect(rows.first['id'], legacyId);
        expect(rows.first['title'], 'Legacy todo');
        expect(rows.first['dueDate'], isNull);

        await migratedHelper.close();
        await dir.delete(recursive: true);
      },
    );
  });
}
