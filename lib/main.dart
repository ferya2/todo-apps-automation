import 'package:flutter/material.dart';

import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/theme.dart';

void main() {
  runApp(const TodoApp());
}

/// The root widget of the Todo app.
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
