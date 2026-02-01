# ADR-001: Use sqflite with Code-Based Migrations

## Status
Accepted

## Context

A backend developer asked: "Why use code for migrations instead of tools like Liquibase or Flyway?"

This question stems from backend development practices where migration frameworks are standard. However, mobile development has fundamentally different constraints:

1. **Distributed execution**: Migrations run on each user's device independently, not on a centralized server
2. **No external dependencies**: Mobile apps have limited ability to read external SQL files at runtime
3. **Update model**: Schema changes must be bundled with the app binary and applied incrementally as users upgrade
4. **Offline-first**: Migrations must work without network access

## Decision

**Use sqflite with inline SQL migration logic in Dart code.**

The migration system is implemented directly in the application code, using sqflite's built-in versioning system:

- Database is opened with a `version` number: `openDatabase(version: DatabaseSchema.version, ...)`
- `onCreate` callback runs all migrations for new installations
- `onUpgrade` callback receives `oldVersion` and `newVersion` and applies migrations incrementally
- No separate migration tracking table is needed—sqflite handles version tracking internally

## Alternatives Considered

| Alternative | Pros | Cons | Decision |
|-------------|------|------|----------|
| **sqflite (current)** | - Simple and standard<br/>- Lightweight<br/>- Full control over SQL<br/>- No extra dependencies | - Manual migration writing<br/>- No type safety | ✅ **CHOSEN** |
| Drift (Moor) | - Type-safe queries<br/>- Auto-generated migrations<br/>- Reactive by default | - Complex learning curve<br/>- Significant overhead<br/>- Overkill for MVP | ❌ Rejected for complexity |
| Floor | - ORM-like interface<br/>- Annotation-based | - Less popular community<br/>- More abstraction layers<br/>- Slower build times | ❌ Rejected for complexity |
| SQL files + custom runner | - Familiar to backend devs<br/>- Separates SQL from code | - No standard way to execute on device<br/>- Asset loading complexity<br/>- No Flutter standard | ❌ Not practical for mobile |

## Consequences

### Positive

- **Simplicity**: Minimal dependencies, straightforward to understand and debug
- **Standard approach**: sqflite is the de facto standard for SQLite in Flutter
- **Performance**: No ORM overhead, direct SQL execution
- **Flexibility**: Full control over migration logic and schema changes
- **Bundle-size friendly**: No additional runtime migration framework overhead

### Negative

- **Manual migration writing**: Each migration must be hand-written as SQL strings
- **No type safety**: Migrations are string-based, typos only caught at runtime
- **Rollback complexity**: No built-in rollback mechanism (must be implemented manually if needed)
- **Testing burden**: Migration logic must be tested on actual devices/emulators

## Implementation

Migrations are defined in the `DatabaseSchema` class and executed via `DatabaseHelper`:

```dart
// In DatabaseSchema
class DatabaseSchema {
  static const int version = 1;
  static const String createLocationsTable = '''...''';
  static const String createItemsTable = '''...''';
  static const List<String> indexes = [...]；
}

// In DatabaseHelper
await openDatabase(
  path,
  version: DatabaseSchema.version,
  onCreate: _onCreate,
  onUpgrade: _onUpgrade,
);

Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 1 && newVersion >= 1) {
    await _migrateToVersion1(db);
  }
  // Future migrations added here:
  // if (oldVersion < 2 && newVersion >= 2) {
  //   await _migrateToVersion2(db);
  // }
}
```

Each migration is applied sequentially when the database version changes, tracked by sqflite's internal version management.

## References

- sqflite package: https://pub.dev/packages/sqflite
- Project implementation: `lib/src/database/database_schema.dart`
