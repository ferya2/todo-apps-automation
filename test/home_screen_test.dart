import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/theme.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  testWidgets(
    'Home screen renders an AppBar, empty body, and FAB placeholder',
    (WidgetTester tester) async {
      final helper = DatabaseHelper(
        databaseFactory: databaseFactoryFfiNoIsolate,
        databasePath: inMemoryDatabasePath,
      );
      addTearDown(helper.close);

      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TodoProvider(TodoDao(helper)),
          child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Todo'), findsOneWidget);

      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip('Add todo'), findsOneWidget);
    },
  );

  testWidgets('swipe-to-dismiss deletes a todo and shows an undo snackbar', (
    WidgetTester tester,
  ) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final provider = TodoProvider(dao);
    addTearDown(helper.close);

    final id = await dao.insert(Todo(title: 'Task to delete'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Task to delete'), findsOneWidget);

    // Swipe the list item from right to left to dismiss it.
    await tester.drag(find.text('Task to delete'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    // The todo is removed from the list and the DB.
    expect(find.text('Task to delete'), findsNothing);
    expect(find.byType(ListTile), findsNothing);
    expect(await dao.getById(id), isNull);

    // An undo snackbar is shown.
    expect(
      find.widgetWithText(SnackBar, 'Task to delete deleted'),
      findsOneWidget,
    );
    expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
  });

  testWidgets('undo restores a dismissed todo to the list and DB', (
    WidgetTester tester,
  ) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    final dao = TodoDao(helper);
    final provider = TodoProvider(dao);
    addTearDown(helper.close);

    final id = await dao.insert(Todo(title: 'Task to delete'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Swipe to dismiss.
    await tester.drag(find.text('Task to delete'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Task to delete'), findsNothing);

    // Tap Undo on the snackbar.
    await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
    await tester.pumpAndSettle();

    // The todo is back in the list and the DB (under a new auto-generated id).
    expect(find.widgetWithText(ListTile, 'Task to delete'), findsOneWidget);
    final rows = await dao.getAll();
    expect(rows.map((t) => t.title), ['Task to delete']);

    // The original row is gone (re-inserted gets a new id).
    expect(await dao.getById(id), isNull);
  });
}
