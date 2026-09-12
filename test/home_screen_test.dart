import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/theme.dart';

void main() {
  testWidgets(
    'Home screen renders an AppBar, empty body, and FAB placeholder',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const HomeScreen()),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.widgetWithText(AppBar, 'Todo'), findsOneWidget);

      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byTooltip('Add todo'), findsOneWidget);
    },
  );
}
