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
    await _migrateToVersion2(db);
    await _migrateToVersion3(db);
  }

  /// Upgrade database from oldVersion to newVersion.
  /// Applies migrations incrementally for each version step.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Apply migrations incrementally
    if (oldVersion < 1 && newVersion >= 1) {
      await _migrateToVersion1(db);
    }
    if (oldVersion < 2 && newVersion >= 2) {
      await _migrateToVersion2(db);
    }
    if (oldVersion < 3 && newVersion >= 3) {
      await _migrateToVersion3(db);
    }
  }

  /// Migration to version 1: Create Locations and Items tables.
  Future<void> _migrateToVersion1(Database db) async {
    // Create Locations table
    await db.execute(DatabaseSchema.createLocationsTable);

    // Create Items table
    await db.execute(DatabaseSchema.createItemsTable);

    // Create indexes for version 1
    await db.execute('CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_locations_qr_code ON locations(qr_code_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_name ON items(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_location_id ON items(location_id)');

    // Seed initial sample data
    await _seedDatabase(db);
  }

  /// Migration to version 2: Create Containers table.
  Future<void> _migrateToVersion2(Database db) async {
    // Create Containers table
    await db.execute(DatabaseSchema.createContainersTable);

    // Create indexes for containers
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_name ON containers(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_parent_location ON containers(parent_location_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_parent_container ON containers(parent_container_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_type ON containers(type)');
  }

  /// Migration to version 3: Add container_id to items table.
  Future<void> _migrateToVersion3(Database db) async {
    // Add container_id column to items
    await db.execute('ALTER TABLE items ADD COLUMN container_id INTEGER');

    // Create index
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_container_id ON items(container_id)');

    // Also add container_id FK constraint (SQLite limitation: can't add FK via ALTER TABLE)
    // For existing databases, we'll rely on app-level validation
    // New databases will have the FK from the schema
  }

  /// Seed database with sample data for first run.
  /// Creates 2 locations with 2 items each.
  Future<void> _seedDatabase(Database db) async {
    final now = currentTime;

    // Insert sample locations
    final location1Id = await db.insert('locations', {
      'name': 'Garage',
      'description': 'Main storage area in the garage',
      'created_at': now,
      'updated_at': now,
    });

    final location2Id = await db.insert('locations', {
      'name': 'Basement',
      'description': 'Storage shelves in the basement',
      'created_at': now,
      'updated_at': now,
    });

    // Insert sample items for Garage (location1Id)
    await db.insert('items', {
      'name': 'Christmas Decorations',
      'description': 'Holiday ornaments and lights',
      'location_id': location1Id,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Camping Gear',
      'description': 'Tent, sleeping bags, and camping equipment',
      'location_id': location1Id,
      'created_at': now,
      'updated_at': now,
    });

    // Insert sample items for Basement (location2Id)
    await db.insert('items', {
      'name': 'Tools',
      'description': 'Power tools and hand tools',
      'location_id': location2Id,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Old Books',
      'description': 'Books stored for safekeeping',
      'location_id': location2Id,
      'created_at': now,
      'updated_at': now,
    });
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
