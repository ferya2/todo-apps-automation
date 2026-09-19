import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/edit_todo_screen.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/utils/date_format.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late DatabaseHelper helper;
  late TodoDao dao;
  late TodoProvider provider;

  setUp(() {
    helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    dao = TodoDao(helper);
    provider = TodoProvider(dao);
  });

  tearDown(() async {
    await helper.close();
  });

  testWidgets('renders an Edit Todo AppBar, a prefilled field, and Save', (
    tester,
  ) async {
    final todo = Todo(title: 'Original title');
    final id = await dao.insert(todo);
    final saved = (await dao.getById(id))!;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: MaterialApp(home: EditTodoScreen(todo: saved)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Edit Todo'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Original title'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Save with an empty title shows a validation error and stays', (
    tester,
  ) async {
    final todo = Todo(title: 'Original title');
    final id = await dao.insert(todo);
    final saved = (await dao.getById(id))!;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: MaterialApp(home: EditTodoScreen(todo: saved)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.byType(EditTodoScreen), findsOneWidget);
  });

  testWidgets('tapping a todo opens the edit screen prefilled with its title', (
    tester,
  ) async {
    await dao.insert(Todo(title: 'Buy groceries'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Buy groceries'));
    await tester.pumpAndSettle();

    expect(find.byType(EditTodoScreen), findsOneWidget);
    expect(find.text('Buy groceries'), findsOneWidget);
  });

  testWidgets('editing a title saves it to the DB and shows it in the list', (
    tester,
  ) async {
    final id = await dao.insert(Todo(title: 'Original title'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit screen.
    await tester.tap(find.widgetWithText(ListTile, 'Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsOneWidget);

    // Change the title and save.
    await tester.enterText(find.byType(TextFormField), 'Renamed title');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the home screen, the updated title appears in the list.
    expect(find.byType(EditTodoScreen), findsNothing);
    expect(find.widgetWithText(ListTile, 'Renamed title'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Original title'), findsNothing);

    // And it was persisted to the database.
    final saved = await dao.getById(id);
    expect(saved!.title, 'Renamed title');
    expect(provider.todos.single.title, 'Renamed title');
  });

  testWidgets('pre-fills an existing due date and saves it', (tester) async {
    final dueDate = DateTime(2026, 9, 20);
    final id = await dao.insert(
      Todo(title: 'Original title', dueDate: dueDate),
    );
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit screen; the due date field is pre-filled.
    await tester.tap(find.widgetWithText(ListTile, 'Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsOneWidget);
    expect(find.text(formatDate(dueDate)), findsOneWidget);

    // Save without changing anything; the due date is preserved.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsNothing);

    final saved = await dao.getById(id);
    expect(saved!.dueDate, dueDate);
  });

  testWidgets('pre-fills an existing priority and saves a change', (
    tester,
  ) async {
    final id = await dao.insert(
      Todo(title: 'Original title', priority: TodoPriority.high),
    );
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit screen; the priority selector is pre-filled with High.
    await tester.tap(find.widgetWithText(ListTile, 'Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    // Change the priority to Low and save.
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsNothing);

    final saved = await dao.getById(id);
    expect(saved!.priority, TodoPriority.low);
  });

  testWidgets('pre-fills an existing category and saves a change', (
    tester,
  ) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );

    final todoDao = TodoDao(helper);
    final categoryDao = CategoryDao(helper);
    final provider = TodoProvider(todoDao, categoryDao: categoryDao);

    addTearDown(helper.close);

    final workId = await categoryDao.insert(Category(name: 'Work'));
    final personalId = await categoryDao.insert(Category(name: 'Personal'));
    final id = await todoDao.insert(
      Todo(title: 'Original title', categoryId: workId),
    );
    await provider.loadCategories();
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Open the edit screen; the category selector is pre-filled with Work.
    await tester.tap(find.widgetWithText(ListTile, 'Original title'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);

    // Change the category to Personal and save.
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Personal').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(EditTodoScreen), findsNothing);

    final saved = await todoDao.getById(id);
    expect(saved!.categoryId, personalId);
  });
}
