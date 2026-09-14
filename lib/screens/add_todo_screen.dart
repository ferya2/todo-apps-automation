import 'package:flutter/material.dart';

/// A screen for creating a new todo.
///
/// Contains a title text field and a Save button in the app bar. The title
/// field is validated: pressing Save with an empty title shows an error and
/// keeps the screen open. When the title is valid, Save returns to the
/// previous route.
///
/// This screen is UI-only — persistence to the provider/DAO is wired in a
/// later step, so Save does not yet write anything to the database.
class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  /// Validates the form and, if valid, returns to the previous route.
  /// Saving to the database lands in a later step (UI only for now).
  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
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
          child: TextFormField(
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
        ),
      ),
    );
  }
}
