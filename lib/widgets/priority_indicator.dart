import 'package:flutter/material.dart';

import 'package:todo_app/models/todo.dart';

/// A small colored dot that indicates a todo's [TodoPriority] in the list.
///
/// The color mapping lives in the UI layer (the [Todo] model is pure Dart):
/// low is green, medium is orange, and high is red.
class PriorityIndicator extends StatelessWidget {
  const PriorityIndicator({super.key, required this.priority});

  /// The priority to display.
  final TodoPriority priority;

  /// The color used for the given [priority].
  static Color colorOf(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.low:
        return Colors.green;
      case TodoPriority.medium:
        return Colors.orange;
      case TodoPriority.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${priority.label} priority',
      child: Icon(Icons.circle, size: 14, color: colorOf(priority)),
    );
  }
}
