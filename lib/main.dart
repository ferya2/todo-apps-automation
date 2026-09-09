import 'package:flutter/material.dart';

import 'package:todo_app/screens/home_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}
