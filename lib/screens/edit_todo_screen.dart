import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:todo_app/models/todo.dart';
import 'package:todo_app/providers/todo_provider.dart';
import 'package:todo_app/widgets/due_date_field.dart';
import 'package:todo_app/widgets/priority_field.dart';

/// A screen for editing an existing todo's title, due date, and priority.
///
/// Pre-fills the title field with [Todo.title], the due date field with
/// [Todo.dueDate], and the priority selector with [Todo.priority]. The title
/// field is validated: pressing Save with an empty title shows an error and
/// keeps the screen open. When the title is valid, the todo is persisted via
/// [TodoProvider] and this screen pops back to the previous route.
class EditTodoScreen extends StatefulWidget {
  const EditTodoScreen({super.key, required this.todo});

  /// The todo being edited.
  final Todo todo;

  @override
  State<EditTodoScreen> createState() => _EditTodoScreenState();
}

class _EditTodoScreenState extends State<EditTodoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController = TextEditingController(
    text: widget.todo.title,
  );
  late DateTime? _dueDate = widget.todo.dueDate;
  late TodoPriority _priority = widget.todo.priority;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Validates the form and, if valid, saves the edited todo via the provider
  /// and pops back to the previous route.
  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final todo = Todo(
      id: widget.todo.id,
      title: _titleController.text.trim(),
      isCompleted: widget.todo.isCompleted,
      dueDate: _dueDate,
      priority: _priority,
      createdAt: widget.todo.createdAt,
    );
    context.read<TodoProvider>().updateTodo(todo);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Todo'),
        actions: [
          TextButton(
            onPressed: _save,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'What needs to be done?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                autofocus: true,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              DueDateField(
                dueDate: _dueDate,
                onChanged: (date) => setState(() => _dueDate = date),
              ),
              const SizedBox(height: 16),
              PriorityField(
                priority: _priority,
                onChanged: (priority) => setState(() => _priority = priority),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
