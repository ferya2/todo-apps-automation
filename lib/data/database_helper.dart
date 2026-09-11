import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Opens and manages the app's SQLite database.
///
/// Schema version 2. Version 1 created the database with no tables; version 2
/// adds the `todos` table (see [onUpgrade]). All schema changes happen through
/// [DatabaseHelper.onUpgrade] so existing user data is never dropped.
///
/// [databaseFactory] and [databasePath] are optional constructor parameters
/// that allow tests to substitute [sqflite_common_ffi]'s in-memory factory.
/// The rest of the app uses the shared [instance] singleton.
class DatabaseHelper {
  /// Creates a helper.
  ///
  /// Pass [databaseFactory] (e.g. [databaseFactoryFfi]) and
  /// [databasePath] (e.g. [inMemoryDatabasePath]) in tests. In production,
  /// leave them null to use sqflite's platform defaults.
  DatabaseHelper({DatabaseFactory? databaseFactory, String? databasePath})
    : _databaseFactory = databaseFactory,
      _databasePath = databasePath;

  /// The single shared instance used by the rest of the app.
  static final DatabaseHelper instance = DatabaseHelper();

  /// The schema version. Bump this (and add migration logic in [onUpgrade])
  /// whenever the schema changes.
  static const int schemaVersion = 2;

  final DatabaseFactory? _databaseFactory;
  final String? _databasePath;

  Database? _database;

  /// Opens the database (cached after the first call).
  Future<Database> get database async {
    final db = _database;
    if (db != null) return db;

    final effectiveFactory = _databaseFactory ?? databaseFactory;
    final path = _databasePath ?? p.join(await getDatabasesPath(), 'todo.db');

    _database = await effectiveFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onUpgrade: onUpgrade,
      ),
    );
    return _database!;
  }

  /// Migration callback. Called by sqflite when opening a database whose
  /// stored version is lower than [schemaVersion], including the initial
  /// creation from version 0 up to [schemaVersion].
  ///
  /// - v1: database created, no tables.
  /// - v2: adds the `todos` table.
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS todos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          isCompleted INTEGER NOT NULL DEFAULT 0,
          createdAt INTEGER NOT NULL
        )
      ''');
    }
  }

  /// Closes the cached database so it can be re-opened (mainly for tests).
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
