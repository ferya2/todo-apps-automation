import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/providers/todo_provider.dart';

/// The home screen for the Todo app.
///
/// Renders the todos from the [TodoProvider] as a [ListView]. The first load is
/// kicked off once when the screen mounts. The FloatingActionButton remains a
/// placeholder until the add-todo flow lands.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TodoProvider>().loadTodos();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.watch<TodoProvider>().todos;

    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: todos.isEmpty
          ? const Center()
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(title: Text(todo.title));
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
