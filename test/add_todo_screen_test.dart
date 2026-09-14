import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/screens/add_todo_screen.dart';

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

/// A minimal page exposing a FAB that pushes the AddTodoScreen, mirroring the
/// navigation wired up in HomeScreen.
class _HomeWithFab extends StatelessWidget {
  const _HomeWithFab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AddTodoScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void main() {
  testWidgets('renders an AppBar, a title field, and a Save button', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddTodoScreen()));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Add Todo'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('Save with an empty title shows a validation error and stays', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddTodoScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a title'), findsOneWidget);
    expect(find.byType(AddTodoScreen), findsOneWidget);
  });

  testWidgets('Save with a valid title pops the screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _BasePage()));
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

  testWidgets('FAB on home opens the AddTodoScreen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: _HomeWithFab()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(AddTodoScreen), findsOneWidget);
  });
}
