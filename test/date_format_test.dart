import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app/utils/date_format.dart';

void main() {
  group('formatDate', () {
    test('pads month and day with leading zeros', () {
      expect(formatDate(DateTime(2026, 3, 2)), '2026-03-02');
    });

    test('formats single-digit components', () {
      expect(formatDate(DateTime(1, 1, 1)), '0001-01-01');
    });

    test('keeps two-digit month and day as-is', () {
      expect(formatDate(DateTime(2030, 12, 31)), '2030-12-31');
    });

    test('ignores the time of day', () {
      expect(formatDate(DateTime(2026, 9, 16, 23, 59, 59)), '2026-09-16');
    });
  });
}
