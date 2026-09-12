import 'package:flutter/material.dart';

/// The home screen for the Todo app.
///
/// Currently a scaffold: an AppBar with an empty body and a FloatingActionButton
/// placeholder. Real content (the todo list) will be added per the roadmap.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: const Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Add todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
