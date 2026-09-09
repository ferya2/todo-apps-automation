import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('sqflite, path and provider are wired up', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('CREATE TABLE smoke_test (id INTEGER)');
    await db.close();

    expect(p.join('a', 'b'), 'a/b');
    expect(
      ChangeNotifierProvider<Counter>.value(
        value: Counter(),
        child: const SizedBox(),
      ),
      isA<ChangeNotifierProvider<Counter>>(),
    );
  });
}

/// A minimal [ChangeNotifier] used only to exercise the `provider` import.
class Counter extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }
}
