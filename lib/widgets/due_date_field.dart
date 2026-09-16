import 'package:flutter/material.dart';

import 'package:todo_app/utils/date_format.dart';

/// A form field for picking an optional due date.
///
/// Tapping the field opens a [showDatePicker] dialog. The selected date is
/// surfaced through [onChanged]; a clear affordance appears once a date is
/// chosen so the due date can be removed again.
class DueDateField extends StatelessWidget {
  const DueDateField({super.key, required this.onChanged, this.dueDate});

  /// The currently selected due date, or null when there is none.
  final DateTime? dueDate;

  /// Called with the new selection whenever it changes (null to clear it).
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = dueDate;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Due date',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        suffixIcon: date == null
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear due date',
                onPressed: () => onChanged(null),
              ),
      ),
      child: InkWell(
        onTap: () => _pick(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.event, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(date == null ? 'No due date' : formatDate(date)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
