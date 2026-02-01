/// Centralized SQL schema definitions for the Storage App database.
/// This is the single source of truth for all database schema.
class DatabaseSchema {
  // Current database version
  static const int version = 2;

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

  static const String createContainersTable = '''
    CREATE TABLE IF NOT EXISTS containers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL DEFAULT 'box',
      description TEXT,
      photo_path TEXT,
      parent_location_id INTEGER,
      parent_container_id INTEGER,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (parent_location_id) REFERENCES locations(id) ON DELETE CASCADE,
      FOREIGN KEY (parent_container_id) REFERENCES containers(id) ON DELETE CASCADE,
      CHECK (parent_location_id IS NOT NULL OR parent_container_id IS NOT NULL)
    )
  ''';

  // Indexes
  static const List<String> indexes = [
    'CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(name)',
    'CREATE INDEX IF NOT EXISTS idx_locations_qr_code ON locations(qr_code_id)',
    'CREATE INDEX IF NOT EXISTS idx_items_name ON items(name)',
    'CREATE INDEX IF NOT EXISTS idx_items_location_id ON items(location_id)',
    'CREATE INDEX IF NOT EXISTS idx_containers_name ON containers(name)',
    'CREATE INDEX IF NOT EXISTS idx_containers_parent_location ON containers(parent_location_id)',
    'CREATE INDEX IF NOT EXISTS idx_containers_parent_container ON containers(parent_container_id)',
    'CREATE INDEX IF NOT EXISTS idx_containers_type ON containers(type)',
  ];
}
