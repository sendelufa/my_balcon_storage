/// Centralized SQL schema definitions for the Storage App database.
/// This is the single source of truth for all database schema.
class DatabaseSchema {
  // Current database version
  static const int version = 1;

  // Tables
  static const String createLocationsTable = '''
    CREATE TABLE IF NOT EXISTS locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      photo_path TEXT,
      qr_code_id TEXT UNIQUE,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  ''';

  static const String createItemsTable = '''
    CREATE TABLE IF NOT EXISTS items (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      photo_path TEXT,
      location_id INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
    )
  ''';

  // Indexes
  static const List<String> indexes = [
    'CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(name)',
    'CREATE INDEX IF NOT EXISTS idx_locations_qr_code ON locations(qr_code_id)',
    'CREATE INDEX IF NOT EXISTS idx_items_name ON items(name)',
    'CREATE INDEX IF NOT EXISTS idx_items_location_id ON items(location_id)',
  ];
}
