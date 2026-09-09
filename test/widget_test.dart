import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/main.dart';

void main() {
  testWidgets('App shows an empty Todo home', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const TodoApp());

    // The home screen should render with a "Todo" app bar and an empty body.
    expect(find.text('Todo'), findsOneWidget);
    expect(find.text('No todos yet.'), findsNothing);
  });
}
