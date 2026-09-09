import 'package:flutter/material.dart';

/// The home screen for the Todo app.
///
/// Placeholder: renders an empty home. Real content (the todo list, FAB,
/// theming) will be added incrementally per the roadmap.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: const Center(),
    );
  }
}
