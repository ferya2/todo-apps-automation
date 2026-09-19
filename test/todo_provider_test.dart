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
      provider = TodoProvider(dao, categoryDao: CategoryDao(helper));
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

    test(
      'updateTodo updates the todo via the DAO and reloads the list',
      () async {
        final id = await dao.insert(Todo(title: 'Original'));
        final existing = (await dao.getById(id))!;
        await provider.loadTodos();

        await provider.updateTodo(
          Todo(
            id: existing.id,
            title: 'Renamed',
            isCompleted: existing.isCompleted,
            createdAt: existing.createdAt,
          ),
        );

        final saved = await dao.getById(id);
        expect(saved!.title, 'Renamed');
        expect(provider.todos.single.title, 'Renamed');
      },
    );

    test('updateTodo notifies listeners', () async {
      final id = await dao.insert(Todo(title: 'Original'));
      final existing = (await dao.getById(id))!;
      await provider.loadTodos();

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.updateTodo(
        Todo(
          id: existing.id,
          title: 'Renamed',
          isCompleted: existing.isCompleted,
          createdAt: existing.createdAt,
        ),
      );

      expect(notified, isTrue);
    });

    test('toggleCompleted flips isCompleted to true and persists', () async {
      final id = await dao.insert(Todo(title: 'Task'));
      await provider.loadTodos();

      await provider.toggleCompleted(provider.todos.single);

      final saved = await dao.getById(id);
      expect(saved!.isCompleted, isTrue);
      expect(provider.todos.single.isCompleted, isTrue);
    });

    test(
      'toggleCompleted flips isCompleted back to false and persists',
      () async {
        final todo = Todo(title: 'Task')..isCompleted = true;
        final id = await dao.insert(todo);
        await provider.loadTodos();

        await provider.toggleCompleted(provider.todos.single);

        final saved = await dao.getById(id);
        expect(saved!.isCompleted, isFalse);
        expect(provider.todos.single.isCompleted, isFalse);
      },
    );

    test('toggleCompleted notifies listeners', () async {
      await dao.insert(Todo(title: 'Task'));
      await provider.loadTodos();

      var notified = false;
      provider.addListener(() {
        notified = true;
      });

      await provider.toggleCompleted(provider.todos.single);

      expect(notified, isTrue);
    });

    group('categories', () {
      test('starts with an empty category list', () {
        expect(provider.categories, isEmpty);
      });

      test('loadCategories loads categories from the DAO', () async {
        final categoryDao = CategoryDao(helper);
        await categoryDao.insert(Category(name: 'Work'));
        await categoryDao.insert(Category(name: 'Personal'));

        await provider.loadCategories();

        expect(provider.categories.map((c) => c.name), ['Work', 'Personal']);
      });

      test('loadCategories notifies listeners', () async {
        var notified = false;
        provider.addListener(() {
          notified = true;
        });

        await provider.loadCategories();

        expect(notified, isTrue);
      });

      test('loadCategories is a no-op when no CategoryDao is wired', () async {
        final plainProvider = TodoProvider(dao);
        await plainProvider.loadCategories();
        expect(plainProvider.categories, isEmpty);
      });

      test('categoryNameFor resolves a loaded category name', () async {
        final id = await CategoryDao(helper).insert(Category(name: 'Home'));

        await provider.loadCategories();

        expect(provider.categoryNameFor(id), 'Home');
      });

      test('categoryNameFor returns null for null or unknown ids', () async {
        await provider.loadCategories();

        expect(provider.categoryNameFor(null), isNull);
        expect(provider.categoryNameFor(999), isNull);
      });
    });
  });
}
