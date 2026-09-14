import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  group('TodoProvider', () {
    late DatabaseHelper helper;
    late TodoDao dao;
    late TodoProvider provider;

    setUp(() {
      helper = DatabaseHelper(
        databaseFactory: databaseFactoryFfi,
        databasePath: inMemoryDatabasePath,
      );
      dao = TodoDao(helper);
      provider = TodoProvider(dao);
    });

    tearDown(() async {
      await helper.close();
    });

    test('starts with an empty list', () {
      expect(provider.todos, isEmpty);
    });

    test('loadTodos loads todos from the DAO', () async {
      await dao.insert(Todo(title: 'First'));
      await dao.insert(Todo(title: 'Second'));

      await provider.loadTodos();

      expect(provider.todos, isNotEmpty);
      expect(provider.todos.map((t) => t.title), ['First', 'Second']);
    });

    test('loadTodos returns an empty list when there are no todos', () async {
      await provider.loadTodos();
      expect(provider.todos, isEmpty);
    });

    test('loadTodos replaces the existing list on reload', () async {
      await dao.insert(Todo(title: 'Original'));
      await provider.loadTodos();
      expect(provider.todos.map((t) => t.title), ['Original']);

      await dao.insert(Todo(title: 'Second'));
      await provider.loadTodos();
      expect(provider.todos.map((t) => t.title), ['Original', 'Second']);
    });

    test('notifies listeners when todos are loaded', () async {
      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.loadTodos();

      expect(notified, isTrue);
    });

    test('addTodo inserts the todo via the DAO and reloads the list', () async {
      await provider.addTodo(Todo(title: 'Buy groceries'));

      final saved = (await dao.getAll()).single;
      expect(saved.title, 'Buy groceries');
      expect(provider.todos.single.title, 'Buy groceries');
    });

    test('addTodo appends to existing todos and notifies listeners', () async {
      await dao.insert(Todo(title: 'Existing'));
      await provider.loadTodos();

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.addTodo(Todo(title: 'New one'));

      expect(notified, isTrue);
      expect(provider.todos.map((t) => t.title), ['Existing', 'New one']);
      expect((await dao.getAll()).length, 2);
    });
  });
}
