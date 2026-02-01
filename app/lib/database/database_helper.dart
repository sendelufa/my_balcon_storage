import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'schema.dart';

/// SQLite database helper for Storage App.
/// Manages database connection, creation, and schema migrations.
class DatabaseHelper {
  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Database instance
  static Database? _database;

  // Database configuration
  static const String _databaseName = 'storage_app.db';

  /// Get the database instance, creating it if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database.
  Future<Database> _initDatabase() async {
    // Get the path to the database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    // Open the database, creating it if it doesn't exist
    return await openDatabase(
      path,
      version: DatabaseSchema.version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  /// Configure database settings (enable foreign keys).
  Future<void> _onConfigure(Database db) async {
    // Enable foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables on first run.
  /// Runs all migrations from version 0 to current version.
  Future<void> _onCreate(Database db, int version) async {
    // Run all migrations to bring database from 0 to current version
    await _migrateToVersion1(db);
  }

  /// Upgrade database from oldVersion to newVersion.
  /// Applies migrations incrementally for each version step.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Apply migrations incrementally
    if (oldVersion < 1 && newVersion >= 1) {
      await _migrateToVersion1(db);
    }
    // Future migrations will be added here:
    // if (oldVersion < 2 && newVersion >= 2) {
    //   await _migrateToVersion2(db);
    // }
  }

  /// Migration to version 1: Create Locations and Items tables.
  Future<void> _migrateToVersion1(Database db) async {
    // Create Locations table
    await db.execute(DatabaseSchema.createLocationsTable);

    // Create Items table
    await db.execute(DatabaseSchema.createItemsTable);

    // Create indexes
    for (final indexSql in DatabaseSchema.indexes) {
      await db.execute(indexSql);
    }
  }

  /// Close the database connection.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Get current timestamp in milliseconds.
  int get currentTime => DateTime.now().millisecondsSinceEpoch;
}
