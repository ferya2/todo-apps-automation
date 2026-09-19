import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/data/data.dart';
import 'package:todo_app/providers/providers.dart';
import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/theme.dart';

void main() {
  runApp(const TodoApp());
}

/// The root widget of the Todo app.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key, this.provider});

  /// The provider backing the UI, or null to create the default one wired to
  /// the shared [DatabaseHelper] singleton. Tests inject their own provider.
  final TodoProvider? provider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          provider ??
          TodoProvider(
            TodoDao(DatabaseHelper.instance),
            categoryDao: CategoryDao(DatabaseHelper.instance),
          ),
      child: MaterialApp(
        title: 'Todo',
        theme: AppTheme.light,
        home: const HomeScreen(),
      ),
    );
  }
}
