import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'database_interface.dart';

/// SQLite database service for web platform
/// Implements DatabaseInterface using sqflite_common_ffi package
class DatabaseServiceWeb implements DatabaseInterface {
  static DatabaseServiceWeb? _instance;
  static Database? _database;

  factory DatabaseServiceWeb() {
    _instance ??= DatabaseServiceWeb._internal();
    return _instance!;
  }

  DatabaseServiceWeb._internal();

  static const String _databaseName = 'storage_app_web.db';
  static const int _databaseVersion = 1;

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    // Initialize FFI
    sqfliteFfiInit();

    // Create database factory for web
    final databaseFactory = databaseFactoryFfi;

    // For web, use in-memory database with IndexedDB persistence
    // The path will be handled by sqflite_common_ffi web implementation
    final dbPath = join(_databaseName);

    return await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
        singleInstance: true,
      ),
    );
  }

  /// Configure database options
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Create locations table
    await db.execute('''
      CREATE TABLE ${DatabaseInterface.tableLocations} (
        ${DatabaseInterface.colId} TEXT PRIMARY KEY,
        ${DatabaseInterface.colName} TEXT NOT NULL,
        ${DatabaseInterface.colDescription} TEXT,
        ${DatabaseInterface.colPhotoPath} TEXT,
        ${DatabaseInterface.colCreatedAt} INTEGER NOT NULL,
        ${DatabaseInterface.colUpdatedAt} INTEGER NOT NULL,
        ${DatabaseInterface.colSortOrder} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create items table
    await db.execute('''
      CREATE TABLE ${DatabaseInterface.tableItems} (
        ${DatabaseInterface.colId} TEXT PRIMARY KEY,
        ${DatabaseInterface.colName} TEXT NOT NULL,
        ${DatabaseInterface.colDescription} TEXT,
        ${DatabaseInterface.colPhotoPath} TEXT,
        ${DatabaseInterface.colLocationId} TEXT NOT NULL,
        ${DatabaseInterface.colCreatedAt} INTEGER NOT NULL,
        ${DatabaseInterface.colUpdatedAt} INTEGER NOT NULL,
        ${DatabaseInterface.colSortOrder} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${DatabaseInterface.colLocationId}) REFERENCES ${DatabaseInterface.tableLocations}(${DatabaseInterface.colId}) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_items_location_id ON ${DatabaseInterface.tableItems}(${DatabaseInterface.colLocationId})
    ''');

    await db.execute('''
      CREATE INDEX idx_locations_created_at ON ${DatabaseInterface.tableLocations}(${DatabaseInterface.colCreatedAt} DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_items_created_at ON ${DatabaseInterface.tableItems}(${DatabaseInterface.colCreatedAt} DESC)
    ''');

    // Note: FTS (Full-Text Search) is not available in sqflite_common_ffi
    // We'll use LIKE queries for search on web
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
  }

  // ==================== Location Operations ====================

  @override
  Future<Map<String, dynamic>> insertLocation(Map<String, dynamic> location) async {
    final db = await database;
    final id = await db.insert(DatabaseInterface.tableLocations, location);
    location['rowid'] = id;
    return location;
  }

  @override
  Future<int> updateLocation(String id, Map<String, dynamic> values) async {
    final db = await database;
    values[DatabaseInterface.colUpdatedAt] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      DatabaseInterface.tableLocations,
      values,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteLocation(String id) async {
    final db = await database;
    return await db.delete(
      DatabaseInterface.tableLocations,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, dynamic>?> getLocationById(String id) async {
    final db = await database;
    final results = await db.query(
      DatabaseInterface.tableLocations,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final db = await database;
    return await db.query(
      DatabaseInterface.tableLocations,
      orderBy: '${DatabaseInterface.colSortOrder} ASC, ${DatabaseInterface.colCreatedAt} DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getLocationWithItemCount() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT
        l.*,
        (SELECT COUNT(*) FROM ${DatabaseInterface.tableItems} WHERE ${DatabaseInterface.colLocationId} = l.${DatabaseInterface.colId}) as item_count
      FROM ${DatabaseInterface.tableLocations} l
      ORDER BY l.${DatabaseInterface.colSortOrder} ASC, l.${DatabaseInterface.colCreatedAt} DESC
    ''');
  }

  // ==================== Item Operations ====================

  @override
  Future<Map<String, dynamic>> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    final id = await db.insert(DatabaseInterface.tableItems, item);
    item['rowid'] = id;
    return item;
  }

  @override
  Future<int> updateItem(String id, Map<String, dynamic> values) async {
    final db = await database;
    values[DatabaseInterface.colUpdatedAt] = DateTime.now().millisecondsSinceEpoch;
    return await db.update(
      DatabaseInterface.tableItems,
      values,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteItem(String id) async {
    final db = await database;
    return await db.delete(
      DatabaseInterface.tableItems,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Map<String, dynamic>?> getItemById(String id) async {
    final db = await database;
    final results = await db.query(
      DatabaseInterface.tableItems,
      where: '${DatabaseInterface.colId} = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  @override
  Future<List<Map<String, dynamic>>> getItemsByLocation(String locationId) async {
    final db = await database;
    return await db.query(
      DatabaseInterface.tableItems,
      where: '${DatabaseInterface.colLocationId} = ?',
      whereArgs: [locationId],
      orderBy: '${DatabaseInterface.colSortOrder} ASC, ${DatabaseInterface.colCreatedAt} DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getAllItems() async {
    final db = await database;
    return await db.query(
      DatabaseInterface.tableItems,
      orderBy: '${DatabaseInterface.colSortOrder} ASC, ${DatabaseInterface.colCreatedAt} DESC',
    );
  }

  // ==================== Search Operations ====================

  @override
  Future<bool> isFts5Available() async {
    // FTS5 is not available on web platform
    return false;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> search(String query) async {
    // Web doesn't support FTS, use LIKE search directly
    return searchLike(query);
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> searchLike(String query) async {
    final db = await database;
    final searchTerm = '%$query%';

    final locationResults = await db.query(
      DatabaseInterface.tableLocations,
      where: '${DatabaseInterface.colName} LIKE ? OR ${DatabaseInterface.colDescription} LIKE ?',
      whereArgs: [searchTerm, searchTerm],
      orderBy: '${DatabaseInterface.colCreatedAt} DESC',
    );

    final itemResults = await db.query(
      DatabaseInterface.tableItems,
      where: '${DatabaseInterface.colName} LIKE ? OR ${DatabaseInterface.colDescription} LIKE ?',
      whereArgs: [searchTerm, searchTerm],
      orderBy: '${DatabaseInterface.colCreatedAt} DESC',
    );

    return {
      'locations': locationResults,
      'items': itemResults,
    };
  }

  // ==================== Utility Operations ====================

  @override
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(DatabaseInterface.tableItems);
    await db.delete(DatabaseInterface.tableLocations);
  }

  @override
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
