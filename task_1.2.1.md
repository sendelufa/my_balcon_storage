# Task 1.2.1: Design SQLite Schema for Locations Table

**Task ID:** 1.2.1
**Task:** Design SQLite schema for Locations table
**Acceptance Criteria:** Schema documented with fields: id, name, description, photo_path, created_at, updated_at
**Estimated Hours:** 2
**Status:** COMPLETED

## Description
Design the SQLite schema for the Locations table that will store physical storage locations in the app.

## Schema Design

### Locations Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INTEGER | PRIMARY KEY AUTOINCREMENT | Unique identifier |
| `name` | TEXT | NOT NULL | Location name (required) |
| `description` | TEXT | | Optional description |
| `photo_path` | TEXT | | Path to photo in app storage |
| `qr_code_id` | TEXT | UNIQUE | QR code identifier (Phase 2) |
| `created_at` | INTEGER | NOT NULL | Unix timestamp (ms) |
| `updated_at` | INTEGER | NOT NULL | Unix timestamp (ms) |

### Indexes
- `idx_locations_name` - For fast name searches
- `idx_locations_qr_code` - For QR code lookups (Phase 2)

### SQL Definition
```sql
CREATE TABLE IF NOT EXISTS locations (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    photo_path TEXT,
    qr_code_id TEXT UNIQUE,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_locations_name ON locations(name);
CREATE INDEX IF NOT EXISTS idx_locations_qr_code ON locations(qr_code_id);
```

## File Created
- `/app/lib/database/schema.dart` - `DatabaseSchema` class with centralized SQL definitions

**Note:** The schema was originally designed in `schema.sql` but was refactored to a Dart class for better integration with the database helper and future migration support.

## Completion Date
2026-02-01
