# Task 1.2.2: Design SQLite Schema for Items Table

**Task ID:** 1.2.2
**Task:** Design SQLite schema for Items table
**Acceptance Criteria:** Schema documented with fields: id, name, description, photo_path, location_id, created_at, updated_at
**Estimated Hours:** 2
**Status:** COMPLETED

## Description
Design the SQLite schema for the Items table that will store items within each storage location.

## Schema Design

### Items Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier |
| `name` | TEXT | NOT NULL | Item name (required) |
| `description` | TEXT | | Optional description |
| `photo_path` | TEXT | | Path to photo in app storage |
| `location_id` | INTEGER | NOT NULL, FK | Reference to locations.id |
| `created_at` | INTEGER | NOT NULL | Unix timestamp (ms) |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (ms) |

### Foreign Key
- `location_id` → `locations.id` with `ON DELETE CASCADE`
  - When a location is deleted, all its items are also deleted

### Indexes
- `idx_items_name` - For fast name searches
- `idx_items_location_id` - For getting all items in a location

### SQL Definition
```sql
CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    photo_path TEXT,
    location_id INTEGER NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_items_name ON items(name);
CREATE INDEX IF NOT EXISTS idx_items_location_id ON items(location_id);
```

## File Updated
- `/app/lib/database/schema.dart` - Added items table to `DatabaseSchema` class

**Note:** The schema was originally designed in `schema.sql` but was refactored to a Dart class for better integration with the database helper and future migration support.

## Completion Date
2026-02-01
