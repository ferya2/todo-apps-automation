import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/main.dart';
import 'package:todo_app/providers/providers.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  testWidgets('App shows an empty Todo home', (WidgetTester tester) async {
    final helper = DatabaseHelper(
      databaseFactory: databaseFactoryFfiNoIsolate,
      databasePath: inMemoryDatabasePath,
    );
    addTearDown(helper.close);

    await tester.pumpWidget(TodoApp(provider: TodoProvider(TodoDao(helper))));
    await tester.pumpAndSettle();

    // The home screen should render with a "Todo" app bar and an empty body.
    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('No todos yet.'), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });
}
