import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'database_interface.dart';

/// SQLite database service for mobile platforms (Android/iOS)
/// Implements DatabaseInterface using sqflite package
class DatabaseService implements DatabaseInterface {
  static DatabaseService? _instance;
  static Database? _database;

  factory DatabaseService() {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  DatabaseService._internal();

  /// Flag indicating whether FTS5 is available on this device
  /// FTS5 may not be available on some Android devices
  bool _fts5Available = false;

  static const String _databaseName = 'storage_app.db';
  static const int _databaseVersion = 1;

  /// Get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
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

    // Try to create FTS tables for fast search (may not be supported on all devices)
    try {
      await db.execute('''
        CREATE VIRTUAL TABLE ${DatabaseInterface.tableLocationsFts} USING fts5(
          ${DatabaseInterface.colName}, ${DatabaseInterface.colDescription},
          content='${DatabaseInterface.tableLocations}',
          content_rowid='rowid',
          tokenize='porter unicode61'
        )
      ''');

      await db.execute('''
        CREATE VIRTUAL TABLE ${DatabaseInterface.tableItemsFts} USING fts5(
          ${DatabaseInterface.colName}, ${DatabaseInterface.colDescription},
          content='${DatabaseInterface.tableItems}',
          content_rowid='rowid',
          tokenize='porter unicode61'
        )
      ''');

      // Create triggers to keep FTS tables in sync
      await _createFtsTriggers(db, DatabaseInterface.tableLocations, DatabaseInterface.tableLocationsFts);
      await _createFtsTriggers(db, DatabaseInterface.tableItems, DatabaseInterface.tableItemsFts);

      _fts5Available = true;
    } catch (e) {
      // FTS5 not available on this device, will use LIKE queries instead
      _fts5Available = false;
    }
  }

  /// Create FTS triggers for a table
  Future<void> _createFtsTriggers(Database db, String table, String ftsTable) async {
    await db.execute('''
      CREATE TRIGGER ${table}_ai AFTER INSERT ON $table BEGIN
        INSERT INTO $ftsTable(rowid, ${DatabaseInterface.colName}, ${DatabaseInterface.colDescription})
        VALUES (new.rowid, new.${DatabaseInterface.colName}, new.${DatabaseInterface.colDescription});
      END
    ''');

    await db.execute('''
      CREATE TRIGGER ${table}_ad AFTER DELETE ON $table BEGIN
        DELETE FROM $ftsTable WHERE rowid = old.rowid;
      END
    ''');

    await db.execute('''
      CREATE TRIGGER ${table}_au AFTER UPDATE ON $table BEGIN
        UPDATE $ftsTable SET ${DatabaseInterface.colName} = new.${DatabaseInterface.colName}, ${DatabaseInterface.colDescription} = new.${DatabaseInterface.colDescription}
        WHERE rowid = new.rowid;
      END
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations will be handled here
  }

  // ==================== Location Operations ====================

  @override
  Future<Map<String, dynamic>> insertLocation(Map<String, dynamic> location) async {
    final db = await database;
    location['rowid'] = await db.insert(DatabaseInterface.tableLocations, location);
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
    item['rowid'] = await db.insert(DatabaseInterface.tableItems, item);
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
    // Ensure database is initialized so _fts5Available is set
    await database;
    return _fts5Available;
  }

  @override
  Future<Map<String, List<Map<String, dynamic>>>> search(String query) async {
    // Use FTS search if available, otherwise fall back to LIKE queries
    if (_fts5Available) {
      return _searchFts(query);
    } else {
      return searchLike(query);
    }
  }

  /// Search using FTS5 (full-text search)
  Future<Map<String, List<Map<String, dynamic>>>> _searchFts(String query) async {
    final db = await database;
    final searchTerm = query.trim();

    if (searchTerm.isEmpty) {
      return {
        'locations': <Map<String, dynamic>>[],
        'items': <Map<String, dynamic>>[],
      };
    }

    // Search locations using FTS
    final locationResults = await db.rawQuery('''
      SELECT l.* FROM ${DatabaseInterface.tableLocations} l
      INNER JOIN ${DatabaseInterface.tableLocationsFts} fts ON l.rowid = fts.rowid
      WHERE ${DatabaseInterface.tableLocationsFts} MATCH ?
      ORDER BY l.${DatabaseInterface.colCreatedAt} DESC
    ''', [searchTerm]);

    // Search items using FTS
    final itemResults = await db.rawQuery('''
      SELECT i.* FROM ${DatabaseInterface.tableItems} i
      INNER JOIN ${DatabaseInterface.tableItemsFts} fts ON i.rowid = fts.rowid
      WHERE ${DatabaseInterface.tableItemsFts} MATCH ?
      ORDER BY i.${DatabaseInterface.colCreatedAt} DESC
    ''', [searchTerm]);

    return {
      'locations': locationResults,
      'items': itemResults,
    };
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
