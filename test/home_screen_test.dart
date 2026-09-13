import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:todo_app/data/data.dart';
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
}
