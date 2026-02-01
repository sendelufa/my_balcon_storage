# Task 1.2.4: Create Locations Table Migration

**Task ID:** 1.2.4
**Task:** Create Locations table migration
**Acceptance Criteria:** Table created successfully on app first launch
**Estimated Hours:** 2
**Status:** COMPLETED

## Description
Implement migration logic to create the Locations table on app first launch. This task establishes the migration framework for future schema changes.

## Implementation

### Migration Structure

**File:** `/app/lib/database/database_helper.dart`

Created a formal migration system with:

1. **`_onCreate`** - Entry point for fresh database installation, runs all migrations
2. **`_onUpgrade`** - Handles database version upgrades incrementally
3. **`_migrateToVersion1`** - Migration to version 1 (Locations + Items tables)

### Migration Flow

```
Fresh Install:
onCreate(version=1) → _migrateToVersion1()

Future Upgrade (e.g., version 1 → 2):
onUpgrade(oldVersion=1, newVersion=2) → _migrateToVersion2()
```

### Key Design Decisions

1. **Incremental migrations** - Each version has its own migration method
2. **Version-gated execution** - `onUpgrade` checks version ranges before running migrations
3. **Shared code** - Both `_onCreate` and `_onUpgrade` can call the same migration methods
4. **Uses DatabaseSchema** - SQL statements come from the centralized schema class

### Code Added

```dart
/// Upgrade database from oldVersion to newVersion.
/// Applies migrations incrementally for each version step.
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 1 && newVersion >= 1) {
    await _migrateToVersion1(db);
  }
  // Future migrations:
  // if (oldVersion < 2 && newVersion >= 2) {
  //   await _migrateToVersion2(db);
  // }
}

/// Migration to version 1: Create Locations and Items tables.
Future<void> _migrateToVersion1(Database db) async {
  await db.execute(DatabaseSchema.createLocationsTable);
  await db.execute(DatabaseSchema.createItemsTable);

  for (final indexSql in DatabaseSchema.indexes) {
    await db.execute(indexSql);
  }
}
```

## Verification

### Unit Tests
All existing tests pass (10 tests):

| Test | Status |
|------|--------|
| `database creates successfully` | ✅ |
| `locations table has correct schema` | ✅ |
| `items table has correct schema` | ✅ |
| `all indexes are created` | ✅ |
| `foreign key cascade delete works` | ✅ |
| `database close works properly` | ✅ |
| `CRUD operations work for locations` | ✅ |
| `CRUD operations work for items` | ✅ |
| `qr_code_id unique constraint works` | ✅ |

**Test Command:**
```bash
flutter test
```

### Manual Verification
- Fresh database install creates all tables correctly
- Locations table has all required columns
- Indexes are created on name columns
- Foreign key cascade delete works

## Files Modified
- `/app/lib/database/database_helper.dart` - Added `_onUpgrade` and `_migrateToVersion1` methods

## Completion Date
2026-02-01
