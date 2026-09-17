import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/add_todo_screen.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/utils/date_format.dart';

/// Wraps [home] in a [ChangeNotifierProvider] backed by [provider] so screens
/// can read the [TodoProvider] (e.g. AddTodoScreen's Save button).
Widget _appWithProvider(TodoProvider provider, Widget home) {
  return ChangeNotifierProvider(
    create: (_) => provider,
    child: MaterialApp(home: home),
  );
}

/// A minimal screen the AddTodoScreen is pushed on top of, so we can verify
/// it is popped again when Save is pressed.
class _BasePage extends StatelessWidget {
  const _BasePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTodoScreen())),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

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

  testWidgets('renders an AppBar, a title field, and a Save button', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithProvider(provider, const AddTodoScreen()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Add Todo'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('No due date'), findsOneWidget);
    expect(find.text('Priority'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
  });

  testWidgets('Save with an empty title shows a validation error and stays', (
    tester,
  ) async {
    await tester.pumpWidget(_appWithProvider(provider, const AddTodoScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.byType(AddTodoScreen), findsOneWidget);
  });

  testWidgets('Save with a valid title pops the screen', (tester) async {
    await tester.pumpWidget(_appWithProvider(provider, const _BasePage()));
    await tester.pumpAndSettle();

    // Open the AddTodoScreen.
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoScreen), findsOneWidget);

    // Fill in a valid title and save.
    await tester.enterText(find.byType(TextFormField), 'Buy groceries');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AddTodoScreen), findsNothing);
  });

  testWidgets('saving a todo persists it to the DB and shows it in the list', (
    tester,
  ) async {
    await provider.loadTodos();

    await tester.pumpWidget(_appWithProvider(provider, const HomeScreen()));
    await tester.pumpAndSettle();

    // Open the AddTodoScreen via the home FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoScreen), findsOneWidget);

    // Enter a title and save.
    await tester.enterText(find.byType(TextFormField), 'Buy groceries');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the home screen, the new todo appears in the list.
    expect(find.byType(AddTodoScreen), findsNothing);
    expect(find.widgetWithText(ListTile, 'Buy groceries'), findsOneWidget);

    // And it was persisted to the database.
    final saved = (await dao.getAll()).single;
    expect(saved.title, 'Buy groceries');
    expect(provider.todos.single.title, 'Buy groceries');
  });

  testWidgets('picking a due date and saving persists it', (tester) async {
    await provider.loadTodos();

    await tester.pumpWidget(_appWithProvider(provider, const HomeScreen()));
    await tester.pumpAndSettle();

    // Open the AddTodoScreen via the home FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Pay rent');
    await tester.pumpAndSettle();

    // Open the date picker and confirm the preselected date (today).
    await tester.tap(find.text('No due date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    expect(find.text(formatDate(todayDate)), findsOneWidget);

    // Save and confirm the due date was persisted.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoScreen), findsNothing);

    final saved = (await dao.getAll()).single;
    expect(saved.title, 'Pay rent');
    expect(saved.dueDate, todayDate);
  });

  testWidgets('picking a priority and saving persists it', (tester) async {
    await provider.loadTodos();

    await tester.pumpWidget(_appWithProvider(provider, const HomeScreen()));
    await tester.pumpAndSettle();

    // Open the AddTodoScreen via the home FAB.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Urgent task');
    await tester.pumpAndSettle();

    // Open the priority dropdown and choose High.
    await tester.tap(find.text('Medium'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.byType(AddTodoScreen), findsNothing);

    final saved = (await dao.getAll()).single;
    expect(saved.title, 'Urgent task');
    expect(saved.priority, TodoPriority.high);
  });
}
