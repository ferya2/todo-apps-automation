import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/screens/add_todo_screen.dart';
import 'package:todo_app/screens/edit_todo_screen.dart';

/// The home screen for the Todo app.
///
/// Renders the todos from the [TodoProvider] as a [ListView]. The first load is
/// kicked off once when the screen mounts. The FloatingActionButton opens the
/// [AddTodoScreen]; saving a todo there persists it via the provider.
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
                return Dismissible(
                  key: ValueKey('todo-${todo.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).colorScheme.error,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    final todoProvider = context.read<TodoProvider>();
                    final removedTodo = todo;
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    await todoProvider.deleteTodo(removedTodo);
                    if (!mounted) return;
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('${removedTodo.title} deleted'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            todoProvider.addTodo(removedTodo);
                          },
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(todo.title),
                    trailing: Checkbox(
                      value: todo.isCompleted,
                      onChanged: (_) {
                        context.read<TodoProvider>().toggleCompleted(todo);
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditTodoScreen(todo: todo),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AddTodoScreen()));
        },
        tooltip: 'Add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
