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

    final id = await dao.insert(Todo(title: 'To be deleted'));
    await provider.loadTodos();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => provider,
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // The todo is visible as a ListTile.
    expect(find.widgetWithText(ListTile, 'To be deleted'), findsOneWidget);

    // Swipe the Dismissible off-screen.
    final dismissible = find.byKey(ValueKey('todo-$id'));
    await tester.drag(dismissible, const Offset(-1000, 0));
    await tester.pumpAndSettle();

    // The todo is gone from the list.
    expect(find.widgetWithText(ListTile, 'To be deleted'), findsNothing);
    // An undo snackbar appears.
    expect(find.text('Undo'), findsOneWidget);

    // Tap Undo to restore the todo.
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    // The todo is back.
    expect(find.widgetWithText(ListTile, 'To be deleted'), findsOneWidget);
  });
}
