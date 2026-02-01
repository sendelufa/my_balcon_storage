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
  /// Runs all migrations to bring database from 0 to current version.
  Future<void> _onCreate(Database db, int version) async {
    // Create all tables first
    await _createTables(db);

    // Then seed all data
    await _seedAllData(db);
  }

  /// Upgrade database from oldVersion to newVersion.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // For development: just recreate everything if upgrading
    // In production, you'd want proper incremental migrations
    await _dropAllTables(db);
    await _createTables(db);
    await _seedAllData(db);
  }

  /// Create all tables with their final schema.
  Future<void> _createTables(Database db) async {
    // Create Locations table
    await db.execute(DatabaseSchema.createLocationsTable);

    // Create Items table (with container_id)
    await db.execute(DatabaseSchema.createItemsTable);

    // Create Containers table
    await db.execute(DatabaseSchema.createContainersTable);

    // Create all indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_locations_qr_code ON locations(qr_code_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_name ON items(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_location_id ON items(location_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_items_container_id ON items(container_id) WHERE container_id IS NOT NULL');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_name ON containers(name)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_parent_location ON containers(parent_location_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_parent_container ON containers(parent_container_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_containers_type ON containers(type)');
  }

  /// Seed all sample data (locations, containers, items).
  Future<void> _seedAllData(Database db) async {
    final now = currentTime;

    // Check if data already exists
    final existingLocations = await db.query('locations', limit: 1);
    if (existingLocations.isNotEmpty) {
      return; // Already seeded
    }

    // Insert locations
    final garageId = await db.insert('locations', {
      'name': 'Garage',
      'description': 'Main storage area in the garage',
      'created_at': now,
      'updated_at': now,
    });

    final basementId = await db.insert('locations', {
      'name': 'Basement',
      'description': 'Storage shelves in the basement',
      'created_at': now,
      'updated_at': now,
    });

    // Insert containers for Garage
    final garageShelfId = await db.insert('containers', {
      'name': 'Wall Shelf',
      'type': 'shelf',
      'description': 'Mounted shelf on the back wall',
      'parent_location_id': garageId,
      'parent_container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    final garageBoxId = await db.insert('containers', {
      'name': 'Tools Box',
      'type': 'box',
      'description': 'Plastic storage box for tools',
      'parent_location_id': garageId,
      'parent_container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    // Insert containers for Basement
    final basementShelfId = await db.insert('containers', {
      'name': 'Metal Rack',
      'type': 'shelf',
      'description': 'Heavy-duty metal storage rack',
      'parent_location_id': basementId,
      'parent_container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    final basementBagId = await db.insert('containers', {
      'name': 'Seasonal Clothes Bag',
      'type': 'bag',
      'description': 'Vacuum-sealed bag for winter clothes',
      'parent_location_id': basementId,
      'parent_container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    // Items directly in locations
    await db.insert('items', {
      'name': 'Christmas Decorations',
      'description': 'Holiday ornaments and lights',
      'location_id': garageId,
      'container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Bicycle',
      'description': 'Mountain bike - stored on floor',
      'location_id': garageId,
      'container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Old Books',
      'description': 'Books stored for safekeeping',
      'location_id': basementId,
      'container_id': null,
      'created_at': now,
      'updated_at': now,
    });

    // Items in Garage containers
    await db.insert('items', {
      'name': 'Extension Cord',
      'description': '50ft outdoor extension cord',
      'location_id': garageId,
      'container_id': garageShelfId,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Screwdriver Set',
      'description': 'Various Phillips and flathead screwdrivers',
      'location_id': garageId,
      'container_id': garageBoxId,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Hammer',
      'description': 'Claw hammer for general use',
      'location_id': garageId,
      'container_id': garageBoxId,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Wrench Set',
      'description': 'Metric and SAE wrenches',
      'location_id': basementId,
      'container_id': basementShelfId,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Winter Coat',
      'description': 'Heavy winter parka',
      'location_id': basementId,
      'container_id': basementBagId,
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('items', {
      'name': 'Winter Boots',
      'description': 'Insulated snow boots',
      'location_id': basementId,
      'container_id': basementBagId,
      'created_at': now,
      'updated_at': now,
    });
  }

  /// Drop all tables (for development reset).
  Future<void> _dropAllTables(Database db) async {
    await db.execute('DROP TABLE IF EXISTS items');
    await db.execute('DROP TABLE IF EXISTS containers');
    await db.execute('DROP TABLE IF EXISTS locations');
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
