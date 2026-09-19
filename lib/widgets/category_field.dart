import 'package:flutter/material.dart';

import 'package:todo_app/models/category.dart';

/// Sentinel dropdown value meaning "no category assigned".
///
/// Category ids are positive (SQLite auto-increment), so 0 is never a real id.
const int _noCategoryValue = 0;

/// A form field for assigning a [Category] to a todo.
///
/// Presents "None" (no category) plus each entry in [categories] as a dropdown
/// and surfaces the selection through [onChanged]. Used by the add and edit
/// screens. The dropdown is disabled when [categories] is empty.
class CategoryField extends StatelessWidget {
  const CategoryField({
    super.key,
    required this.categories,
    required this.categoryId,
    required this.onChanged,
  });

  /// The categories available for assignment.
  final List<Category> categories;

  /// The currently selected category's id, or null when uncategorized.
  final int? categoryId;

  /// Called with the new category id (or null when "None" is selected).
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: categoryId ?? _noCategoryValue,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<int>(
          value: _noCategoryValue,
          child: Text('None'),
        ),
        for (final category in categories)
          DropdownMenuItem<int>(
            value: category.id!,
            child: Text(category.name),
          ),
      ],
      onChanged: categories.isEmpty
          ? null
          : (value) {
              onChanged(value == _noCategoryValue ? null : value);
            },
    );
  }
}
