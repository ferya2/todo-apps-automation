import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/models/models.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/home_screen.dart';

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
}
