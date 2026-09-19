import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/widgets/priority_indicator.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  testWidgets('renders todos from the provider as a ListView', (tester) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final provider = TodoProvider(dao);
    addTearDown(helper.close);

    await dao.insert(Todo(title: 'Buy groceries'));
    await dao.insert(Todo(title: 'Write tests'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Buy groceries'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Write tests'), findsOneWidget);
  });

  testWidgets('tapping a checkbox toggles completion and persists to the DB', (
    tester,
  ) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final provider = TodoProvider(dao);
    addTearDown(helper.close);

    final id = await dao.insert(Todo(title: 'Task'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsOneWidget);
    expect(
      tester.widget(find.byType(Checkbox)),
      isA<Checkbox>().having((c) => c.value, 'value', isFalse),
    );

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    final saved = await dao.getById(id);
    expect(saved!.isCompleted, isTrue);
    expect(provider.todos.single.isCompleted, isTrue);
  });

  testWidgets('shows a colored priority indicator for each todo', (
    tester,
  ) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final provider = TodoProvider(dao);
    addTearDown(helper.close);

    await dao.insert(Todo(title: 'Low task', priority: TodoPriority.low));
    await dao.insert(Todo(title: 'High task', priority: TodoPriority.high));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PriorityIndicator), findsNWidgets(2));
    expect(find.byTooltip('Low priority'), findsOneWidget);
    expect(find.byTooltip('High priority'), findsOneWidget);
  });

  testWidgets('shows a category name on each categorized todo', (tester) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final categoryDao = CategoryDao(helper);
    final provider = TodoProvider(dao, categoryDao: categoryDao);
    addTearDown(helper.close);

    final workId = await categoryDao.insert(Category(name: 'Work'));
    await dao.insert(Todo(title: 'Categorized task', categoryId: workId));
    await dao.insert(Todo(title: 'Uncategorized task'));
    await provider.loadCategories();
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final categorized = find.widgetWithText(ListTile, 'Categorized task');
    expect(
      find.descendant(of: categorized, matching: find.text('Work')),
      findsOneWidget,
    );
    final uncategorized = find.widgetWithText(ListTile, 'Uncategorized task');
    expect(
      find.descendant(of: uncategorized, matching: find.text('Work')),
      findsNothing,
    );
  });
}
