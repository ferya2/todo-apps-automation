import 'package:flutter/material.dart';

import 'package:todo_app/models/todo.dart';

/// A form field for choosing a todo's [TodoPriority].
///
/// Presents the priorities as a dropdown and surfaces the selection through
/// [onChanged]. Used by the add and edit screens.
class PriorityField extends StatelessWidget {
  const PriorityField({
    super.key,
    required this.priority,
    required this.onChanged,
  });

  /// The currently selected priority.
  final TodoPriority priority;

  /// Called with the new selection whenever it changes.
  final ValueChanged<TodoPriority> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TodoPriority>(
      initialValue: priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        border: OutlineInputBorder(),
      ),
      items: [
        for (final value in TodoPriority.values)
          DropdownMenuItem<TodoPriority>(
            value: value,
            child: Text(value.label),
          ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
