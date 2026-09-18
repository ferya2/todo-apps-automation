import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/models/models.dart';

void main() {
  group('Category', () {
    test('id is null when not persisted', () {
      final category = Category(name: 'Work');
      expect(category.id, isNull);
    });

    test('toMap contains the expected fields', () {
      final category = Category(id: 7, name: 'Home');
      expect(category.toMap(), {'id': 7, 'name': 'Home'});
    });

    test('toMap serializes a category without an id', () {
      final category = Category(name: 'Work');
      expect(category.toMap()['id'], isNull);
      expect(category.toMap()['name'], 'Work');
    });

    test('fromMap parses a persisted category', () {
      final category = Category.fromMap({'id': 3, 'name': 'Shopping'});
      expect(category.id, 3);
      expect(category.name, 'Shopping');
    });

    test('round-trips through toMap and fromMap', () {
      final original = Category(id: 42, name: 'Groceries');

      final restored = Category.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
    });
  });
}
