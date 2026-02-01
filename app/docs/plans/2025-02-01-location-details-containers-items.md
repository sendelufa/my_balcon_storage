# Location Details Screen: Containers & Items Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create Location/Container Details screen that displays nested containers and items with drill-down navigation.

**Architecture:**
- Single `containers` table with `type` field (box, shelf, bag, closet) - only affects display
- Unlimited nesting via `parent_container_id`
- Reusable `ContentsScreen` works for both Location and Container sources
- Two-letter badge placeholder for container type icons

**Tech Stack:** Flutter, SQLite (sqflite), existing design system (AppCard, AppTheme)

---

### Task 1: Database Schema - Add containers table

**Files:**
- Modify: `lib/database/schema.dart`

**Step 1: Add containers table to schema**

Add to `DatabaseSchema` class:

```dart
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
```

**Step 2: Add indexes**

Add to `indexes` list:

```dart
'CREATE INDEX IF NOT EXISTS idx_containers_name ON containers(name)',
'CREATE INDEX IF NOT EXISTS idx_containers_parent_location ON containers(parent_location_id)',
'CREATE INDEX IF NOT EXISTS idx_containers_parent_container ON containers(parent_container_id)',
'CREATE INDEX IF NOT EXISTS idx_containers_type ON containers(type)',
```

**Step 3: Increment database version**

Change: `static const int version = 1;`
To: `static const int version = 2;`

**Step 4: Add migration logic to database_helper.dart**

**Modify:** `lib/database/database_helper.dart`

Add migration method in `DatabaseHelper`:

```dart
Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute(DatabaseSchema.createContainersTable);
    for (final index in [
      'CREATE INDEX IF NOT EXISTS idx_containers_name ON containers(name)',
      'CREATE INDEX IF NOT EXISTS idx_containers_parent_location ON containers(parent_location_id)',
      'CREATE INDEX IF NOT EXISTS idx_containers_parent_container ON containers(parent_container_id)',
      'CREATE INDEX IF NOT EXISTS idx_containers_type ON containers(type)',
    ]) {
      await db.execute(index);
    }
  }
}
```

And update `_onCreate` to include the containers table:

```dart
Future _onCreate(Database db, int version) async {
  await db.execute(DatabaseSchema.createLocationsTable);
  await db.execute(DatabaseSchema.createItemsTable);
  await db.execute(DatabaseSchema.createContainersTable); // ADD THIS

  for (final index in DatabaseSchema.indexes) {
    await db.execute(index);
  }
  // Also add container indexes here
}
```

**Step 5: Update onCreate to handle open callback**

Modify `_openDatabase` method:

From:
```dart
final db = await openDatabase(
  path,
  version: DatabaseSchema.version,
  onCreate: _onCreate,
);
```

To:
```dart
final db = await openDatabase(
  path,
  version: DatabaseSchema.version,
  onCreate: _onCreate,
  onUpgrade: _onUpgrade, // ADD THIS
);
```

**Step 6: Commit**

```bash
git add lib/database/schema.dart lib/database/database_helper.dart
git commit -m "feat: add containers table to schema with migration"
```

---

### Task 2: Add container_id column to items table

**Files:**
- Modify: `lib/database/schema.dart`
- Modify: `lib/database/database_helper.dart`

**Step 1: Add container_id migration**

In `database_helper.dart`, update `_onUpgrade` to add the column:

```dart
if (oldVersion < 2) {
  await db.execute(DatabaseSchema.createContainersTable);
  // Add container_id to items
  await db.execute('ALTER TABLE items ADD COLUMN container_id INTEGER');
  // Create index
  await db.execute('CREATE INDEX IF NOT EXISTS idx_items_container_id ON items(container_id)');

  // ... container indexes from Task 1
}
```

**Step 2: Update items table schema**

In `schema.dart`, update `createItemsTable`:

```dart
static const String createItemsTable = '''
  CREATE TABLE IF NOT EXISTS items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    photo_path TEXT,
    location_id INTEGER NOT NULL,
    container_id INTEGER,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE,
    FOREIGN KEY (container_id) REFERENCES containers(id) ON DELETE CASCADE
  )
''';
```

**Step 3: Add index to schema indexes**

```dart
'CREATE INDEX IF NOT EXISTS idx_items_container_id ON items(container_id)',
```

**Step 4: Commit**

```bash
git add lib/database/schema.dart lib/database/database_helper.dart
git commit -m "feat: add container_id to items table"
```

---

### Task 3: Create Container entity

**Files:**
- Create: `lib/domain/entities/container.dart`

**Step 1: Create the entity file**

```dart
import 'package:equatable/equatable.dart';

/// Container type enum
enum ContainerType {
  box,
  shelf,
  bag,
  closet,
  drawer,
  cabinet,
  other,
}

/// Container entity representing a storage container.
///
/// Containers can be nested within other containers or locations.
/// The type field determines the icon/visual display only.
class Container extends Equatable {
  /// Unique identifier for the container.
  final int id;

  /// Name of the container (e.g., "Tools Box", "Main Shelf").
  final String name;

  /// Type of container (affects icon/visual display).
  final ContainerType type;

  /// Optional description providing more details about the container.
  final String? description;

  /// Optional file path to the container's photo.
  final String? photoPath;

  /// ID of the location this container is directly in (if not nested).
  final int? parentLocationId;

  /// ID of the parent container (if nested).
  final int? parentContainerId;

  /// Timestamp when the container was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when the container was last updated (milliseconds since epoch).
  final int updatedAt;

  const Container({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.photoPath,
    this.parentLocationId,
    this.parentContainerId,
  });

  /// Creates a [Container] from a map (typically from database row).
  factory Container.fromMap(Map<String, dynamic> map) {
    return Container(
      id: map['id'] as int,
      name: map['name'] as String,
      type: _parseContainerType(map['type'] as String?),
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      parentLocationId: map['parent_location_id'] as int?,
      parentContainerId: map['parent_container_id'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Parses container type from string, defaults to 'box'.
  static ContainerType _parseContainerType(String? type) {
    return ContainerType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => ContainerType.box,
    );
  }

  /// Converts the [Container] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'photo_path': photoPath,
      'parent_location_id': parentLocationId,
      'parent_container_id': parentContainerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Creates a copy of this [Container] with some fields replaced.
  Container copyWith({
    int? id,
    String? name,
    ContainerType? type,
    String? description,
    String? photoPath,
    int? parentLocationId,
    int? parentContainerId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Container(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      parentContainerId: parentContainerId ?? this.parentContainerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Gets the two-letter abbreviation for this container type.
  String get typeAbbreviation {
    switch (type) {
      case ContainerType.box:
        return 'Bo';
      case ContainerType.shelf:
        return 'Sh';
      case ContainerType.bag:
        return 'Ba';
      case ContainerType.closet:
        return 'Cl';
      case ContainerType.drawer:
        return 'Dr';
      case ContainerType.cabinet:
        return 'Ca';
      case ContainerType.other:
        return 'Ot';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        photoPath,
        parentLocationId,
        parentContainerId,
        createdAt,
        updatedAt,
      ];
}
```

**Step 2: Commit**

```bash
git add lib/domain/entities/container.dart
git commit -m "feat: add Container entity"
```

---

### Task 4: Update Item entity with containerId

**Files:**
- Modify: `lib/domain/entities/item.dart`

**Step 1: Add containerId field**

Add to `Item` class:

```dart
/// The ID of the container this item is in (optional).
final int? containerId;
```

**Step 2: Update constructor**

Add to constructor parameters:
```dart
this.containerId,
```

**Step 3: Update fromMap factory**

```dart
factory Item.fromMap(Map<String, dynamic> map) {
  return Item(
    id: map['id'] as int,
    name: map['name'] as String,
    description: map['description'] as String?,
    photoPath: map['photo_path'] as String?,
    locationId: map['location_id'] as int,
    containerId: map['container_id'] as int?,
    createdAt: map['created_at'] as int,
    updatedAt: map['updated_at'] as int,
  );
}
```

**Step 4: Update toMap method**

```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'description': description,
    'photo_path': photoPath,
    'location_id': locationId,
    'container_id': containerId,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
```

**Step 5: Update copyWith method**

```dart
int? containerId,
```
```dart
containerId: containerId ?? this.containerId,
```

**Step 6: Update props**

```dart
List<Object?> get props => [
      id,
      name,
      description,
      photoPath,
      locationId,
      containerId,
      createdAt,
      updatedAt,
    ];
```

**Step 7: Commit**

```bash
git add lib/domain/entities/item.dart
git commit -m "feat: add containerId to Item entity"
```

---

### Task 5: Create ContainerRepository interface

**Files:**
- Create: `lib/domain/repositories/container_repository.dart`

**Step 1: Create the repository interface**

```dart
import '../entities/container.dart';

/// Exception thrown when repository operations fail.
class ContainerRepositoryException implements Exception {
  final String message;
  final Object? cause;

  const ContainerRepositoryException(this.message, [this.cause]);

  @override
  String toString() => message;
}

/// Repository interface for [Container] operations.
abstract class ContainerRepository {
  /// Returns all containers, optionally ordered by [orderBy].
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<List<Container>> getAll({String orderBy = 'name ASC'});

  /// Returns a container with the given [id], or null if not found.
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<Container?> getById(int id);

  /// Returns all containers directly in the given [locationId].
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<List<Container>> getByLocationId(int locationId);

  /// Returns all child containers of the given [containerId].
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<List<Container>> getByParentContainerId(int containerId);

  /// Searches containers by name or description matching [query].
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<List<Container>> search(String query);

  /// Creates a new container and returns it with the generated id.
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<Container> create(Container container);

  /// Updates an existing container and returns the updated version.
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<Container> update(Container container);

  /// Deletes the container with the given [id].
  /// Returns true if a container was deleted, false if not found.
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<bool> delete(int id);

  /// Returns the total number of containers.
  ///
  /// Throws [ContainerRepositoryException] on failure.
  Future<int> count();
}
```

**Step 2: Commit**

```bash
git add lib/domain/repositories/container_repository.dart
git commit -m "feat: add ContainerRepository interface"
```

---

### Task 6: Create ContainerRepositoryImpl

**Files:**
- Create: `lib/data/repositories/container_repository_impl.dart`

**Step 1: Create the implementation**

```dart
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/container.dart';
import '../../domain/repositories/container_repository.dart';
import '../../database/database_helper.dart';

/// SQLite implementation of [ContainerRepository].
class ContainerRepositoryImpl implements ContainerRepository {
  final DatabaseHelper _databaseHelper;
  static const String _tableName = 'containers';

  ContainerRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Container>> getAll({String orderBy = 'name ASC'}) async {
    try {
      final db = await _databaseHelper.database;
      final maps = await db.query(_tableName, orderBy: orderBy);
      return maps.map((map) => Container.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to retrieve all containers',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Container?> getById(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Container id must be positive, got: $id');
      }

      final db = await _databaseHelper.database;
      final maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;
      return Container.fromMap(maps.first);
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to retrieve container with id: $id',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Container>> getByLocationId(int locationId) async {
    try {
      if (locationId <= 0) {
        throw ArgumentError('Location id must be positive, got: $locationId');
      }

      final db = await _databaseHelper.database;
      final maps = await db.query(
        _tableName,
        where: 'parent_location_id = ?',
        whereArgs: [locationId],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Container.fromMap(map)).toList();
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to retrieve containers for location: $locationId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Container>> getByParentContainerId(int containerId) async {
    try {
      if (containerId <= 0) {
        throw ArgumentError('Parent container id must be positive, got: $containerId');
      }

      final db = await _databaseHelper.database;
      final maps = await db.query(
        _tableName,
        where: 'parent_container_id = ?',
        whereArgs: [containerId],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Container.fromMap(map)).toList();
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to retrieve child containers of: $containerId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Container>> search(String query) async {
    try {
      if (query.trim().isEmpty) return const [];

      final db = await _databaseHelper.database;
      final pattern = '%${query.trim()}%';

      final maps = await db.query(
        _tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: [pattern, pattern],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Container.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to search containers',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Container> create(Container container) async {
    try {
      _validateForCreate(container);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      final map = container.toMap();
      map.remove('id');
      map['created_at'] = now;
      map['updated_at'] = now;

      final id = await db.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      final created = await getById(id);
      if (created == null) {
        throw ContainerRepositoryException(
          'Failed to retrieve created container with id: $id',
        );
      }

      return created;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to create container: ${container.name}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Container> update(Container container) async {
    try {
      _validateForUpdate(container);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      final map = container.toMap();
      map['updated_at'] = now;

      final rowsAffected = await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [container.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (rowsAffected == 0) {
        throw ContainerRepositoryException(
          'Container with id ${container.id} not found',
        );
      }

      final updated = await getById(container.id);
      if (updated == null) {
        throw ContainerRepositoryException(
          'Failed to retrieve updated container with id: ${container.id}',
        );
      }

      return updated;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to update container with id: ${container.id}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Container id must be positive, got: $id');
      }

      final db = await _databaseHelper.database;
      final rowsAffected = await db.delete(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return rowsAffected > 0;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to delete container with id: $id',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<int> count() async {
    try {
      final db = await _databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to count containers',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  void _validateForCreate(Container container) {
    if (container.name.trim().isEmpty) {
      throw ArgumentError('Container name cannot be empty');
    }
    if (container.name.length > 255) {
      throw ArgumentError('Container name cannot exceed 255 characters');
    }
    if (container.parentLocationId == null && container.parentContainerId == null) {
      throw ArgumentError('Container must have either parentLocationId or parentContainerId');
    }
  }

  void _validateForUpdate(Container container) {
    if (container.id <= 0) {
      throw ArgumentError('Container id must be positive');
    }
    _validateForCreate(container);
  }

  static Object _createExceptionDetails(Object error, StackTrace stackTrace) {
    return _ExceptionDetails(error, stackTrace);
  }
}

class _ExceptionDetails {
  final Object error;
  final StackTrace stackTrace;

  const _ExceptionDetails(this.error, this.stackTrace);

  @override
  String toString() => error.toString();
}
```

**Step 2: Commit**

```bash
git add lib/data/repositories/container_repository_impl.dart
git commit -m "feat: add ContainerRepositoryImpl"
```

---

### Task 7: Update ItemRepository with container methods

**Files:**
- Modify: `lib/domain/repositories/location_repository.dart`
- Modify: `lib/data/repositories/item_repository_impl.dart` (or create if doesn't exist)

First, check if item repository exists:

**Step 1: Check and update ItemRepository interface**

If `lib/domain/repositories/item_repository.dart` exists, add:

```dart
/// Returns items directly in the given [locationId] (not in a container).
Future<List<Item>> getByLocationId(int locationId);

/// Returns items inside the given [containerId].
Future<List<Item>> getByContainerId(int containerId);
```

**Step 2: Implement in ItemRepositoryImpl**

Add implementations similar to location queries:

```dart
@override
Future<List<Item>> getByLocationId(int locationId) async {
  try {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'location_id = ? AND container_id IS NULL',
      whereArgs: [locationId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  } catch (e, stackTrace) {
    throw ItemRepositoryException(
      'Failed to retrieve items for location: $locationId',
      _createExceptionDetails(e, stackTrace),
    );
  }
}

@override
Future<List<Item>> getByContainerId(int containerId) async {
  try {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      _tableName,
      where: 'container_id = ?',
      whereArgs: [containerId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => Item.fromMap(map)).toList();
  } catch (e, stackTrace) {
    throw ItemRepositoryException(
      'Failed to retrieve items for container: $containerId',
      _createExceptionDetails(e, stackTrace),
    );
  }
}
```

**Step 3: Commit**

```bash
git add lib/domain/repositories/item_repository.dart lib/data/repositories/item_repository_impl.dart
git commit -m "feat: add container-aware queries to ItemRepository"
```

---

### Task 8: Create ContentsScreen widget

**Files:**
- Create: `lib/screens/contents_screen.dart`

**Step 1: Create the reusable contents screen**

```dart
import 'package:flutter/material.dart';
import '../domain/entities/location.dart';
import '../domain/entities/container.dart' as domain;
import '../domain/entities/item.dart';
import '../domain/repositories/location_repository.dart';
import '../domain/repositories/container_repository.dart';
import '../domain/repositories/item_repository.dart';
import '../data/repositories/location_repository_impl.dart';
import '../data/repositories/container_repository_impl.dart';
import '../data/repositories/item_repository_impl.dart';
import '../theme/app_theme.dart';
import '../theme/spacing.dart';
import '../widgets/card.dart';

/// Source for displaying contents - either a Location or a Container.
sealed class ContentsSource {
  String get name;
  int get id;
}

/// Location as the source.
class LocationSource extends ContentsSource {
  final Location location;

  LocationSource(this.location);

  @override
  String get name => location.name;

  @override
  int get id => location.id;
}

/// Container as the source.
class ContainerSource extends ContentsSource {
  final domain.Container container;

  ContainerSource(this.container);

  @override
  String get name => container.name;

  @override
  int get id => container.id;
}

/// Reusable screen showing contents of a Location or Container.
///
/// Displays:
/// - Containers grouped by type (Shelves, Boxes, etc.)
/// - Items not in any container
/// - Drill-down navigation into containers
class ContentsScreen extends StatefulWidget {
  final ContentsSource source;

  const ContentsScreen({
    super.key,
    required this.source,
  });

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  late final LocationRepository _locationRepo;
  late final ContainerRepository _containerRepo;
  late final ItemRepository _itemRepo;

  List<domain.Container> _containers = [];
  List<Item> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _locationRepo = LocationRepositoryImpl();
    _containerRepo = ContainerRepositoryImpl();
    _itemRepo = ItemRepositoryImpl();
    _loadContents();
  }

  Future<void> _loadContents() async {
    try {
      final containers = await _containerRepo.getByLocationId(widget.source.id);
      final items = await _itemRepo.getByLocationId(widget.source.id);

      setState(() {
        _containers = containers;
        _items = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.source.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.source.name)),
        body: Center(child: Text('Error: $_error')),
      );
    }

    // Group containers by type
    final groupedContainers = <domain.ContainerType, List<domain.Container>>{};
    for (final container in _containers) {
      groupedContainers.putIfAbsent(container.type, () => []).add(container);
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.source.name)),
      body: _items.isEmpty && groupedContainers.isEmpty
          ? const Center(child: Text('No items here'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: groupedContainers.length + (_items.isEmpty ? 0 : 1),
              itemBuilder: (context, index) {
                // Calculate which section to show
                final typeIndex = index;
                final types = groupedContainers.keys.toList()..sort((a, b) => a.name.compareTo(b.name));

                if (typeIndex < types.length) {
                  final type = types[typeIndex];
                  final containers = groupedContainers[type]!;
                  return _ContainerSection(
                    type: type,
                    containers: containers,
                    onContainerTap: _navigateToContainer,
                  );
                }

                // Items section
                return _ItemsSection(items: _items);
              },
            ),
    );
  }

  void _navigateToContainer(domain.Container container) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentsScreen(
          source: ContainerSource(container),
        ),
      ),
    );
  }
}

/// Section showing containers of a specific type.
class _ContainerSection extends StatelessWidget {
  final domain.ContainerType type;
  final List<domain.Container> containers;
  final ValueChanged<domain.Container> onContainerTap;

  const _ContainerSection({
    required this.type,
    required this.containers,
    required this.onContainerTap,
  });

  String _getTypeTitle(domain.ContainerType type) {
    switch (type) {
      case domain.ContainerType.box:
        return 'Boxes';
      case domain.ContainerType.shelf:
        return 'Shelves';
      case domain.ContainerType.bag:
        return 'Bags';
      case domain.ContainerType.closet:
        return 'Closets';
      case domain.ContainerType.drawer:
        return 'Drawers';
      case domain.ContainerType.cabinet:
        return 'Cabinets';
      case domain.ContainerType.other:
        return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            '${_getTypeTitle(type)} (${containers.length})',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: AppTypography.weightSemiBold,
            ),
          ),
        ),
        ...List.generate(containers.length, (index) {
          final container = containers[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < containers.length - 1 ? AppSpacing.sm : 0,
            ),
            child: AppCard.list(
              title: container.name,
              subtitle: container.description,
              leadingIcon: null, // Using custom leading below
              onTap: () => onContainerTap(container),
              showDivider: false,
            ),
          );
        }),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

/// Section showing items.
class _ItemsSection extends StatelessWidget {
  final List<Item> items;

  const _ItemsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (items.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Items (${items.length})',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: AppTypography.weightSemiBold,
              ),
            ),
          ),
          ...List.generate(items.length, (index) {
            final item = items[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < items.length - 1 ? AppSpacing.sm : 0,
              ),
              child: AppCard.item(
                name: item.name,
                description: item.description,
              ),
            );
          }),
        ],
      ],
    );
  }
}
```

**Step 2: Commit**

```bash
git add lib/screens/contents_screen.dart
git commit -m "feat: add ContentsScreen for displaying location/container contents"
```

---

### Task 9: Update LocationsListScreen to navigate

**Files:**
- Modify: `lib/screens/locations_list_screen.dart`

**Step 1: Make location cards tappable**

Update the itemBuilder to add onTap:

```dart
itemBuilder: (context, index) {
  final location = _locations[index];
  return AppCard.location(
    name: location.name,
    description: location.description ?? '',
    itemCount: 0,
    onTap: () => _navigateToLocation(location),
  );
},
```

**Step 2: Add navigation method**

```dart
void _navigateToLocation(Location location) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ContentsScreen(
        source: LocationSource(location),
      ),
    ),
  );
}
```

**Step 3: Add import**

```dart
import 'contents_screen.dart';
```

**Step 4: Commit**

```bash
git add lib/screens/locations_list_screen.dart
git commit -m "feat: navigate from location list to contents screen"
```

---

### Task 10: Add type badge to AppCard.list

**Files:**
- Modify: `lib/widgets/card.dart`

**Step 1: Update AppListTileCard to support custom leading widget**

Add `Widget? customLeading` parameter:

```dart
class AppListTileCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? customLeading; // ADD THIS
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showDivider;

  const AppListTileCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.customLeading, // ADD THIS
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.showDivider = true,
  });
```

**Step 2: Update build method to use customLeading**

In the Row children:

```dart
if (customLeading != null) ...[  // ADD THIS CHECK FIRST
  customLeading!,
  const SizedBox(width: AppSpacing.md),
],
if (leadingIcon != null) ...[
  Icon(
    leadingIcon,
    size: 20,
    color: isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight,
  ),
  const SizedBox(width: AppSpacing.md),
],
```

**Step 3: Add typeBadge to AppCard.list factory**

Update the `list` variant in `_buildContent` or create a new approach for showing type badges.

Actually, let's use the trailing slot for type badge. Update AppCard to accept a badge widget.

**Alternative: Create ContainerCard widget**

Create a new simple card for containers with type badge:

```dart
/// Card for displaying containers with type badge.
class ContainerCard extends StatelessWidget {
  final String name;
  final String? description;
  final String typeAbbreviation;
  final VoidCallback? onTap;

  const ContainerCard({
    super.key,
    required this.name,
    this.description,
    required this.typeAbbreviation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Type badge
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryTransparent
                      : AppColors.primarySubtle,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    typeAbbreviation,
                    style: AppTypography.labelSmall.copyWith(
                      color: isDark ? AppColors.primaryLight : AppColors.primary,
                      fontWeight: AppTypography.weightSemiBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        description!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 4: Commit**

```bash
git add lib/widgets/card.dart
git commit -m "feat: add ContainerCard with type badge"
```

---

### Task 11: Update ContentsScreen to use ContainerCard

**Files:**
- Modify: `lib/screens/contents_screen.dart`

**Step 1: Replace AppCard.list with ContainerCard**

In `_ContainerSection`, replace:

```dart
AppCard.list(
  title: container.name,
  subtitle: container.description,
  leadingIcon: null,
  onTap: () => onContainerTap(container),
  showDivider: false,
),
```

With:

```dart
ContainerCard(
  name: container.name,
  description: container.description,
  typeAbbreviation: container.typeAbbreviation,
  onTap: () => onContainerTap(container),
),
```

**Step 2: Commit**

```bash
git add lib/screens/contents_screen.dart
git commit -m "refactor: use ContainerCard in ContentsScreen"
```

---

### Task 12: Verification and Testing

**Step 1: Run flutter analyze**

```bash
flutter analyze
```

Expected: No errors

**Step 2: Test the app flow**

1. Launch app - should see LocationsListScreen
2. Tap a location - should navigate to ContentsScreen
3. Verify empty state shows if no containers/items
4. (After seeding data) Verify containers grouped by type
5. Tap a container - should navigate to its ContentsScreen

**Step 3: Final commit**

```bash
git add .
git commit -m "feat: complete location details screen with containers and items"
```

---

## Summary

This plan creates:
1. `containers` table with nesting support
2. `Container` entity with type enum
3. `ContainerRepository` with CRUD and parent queries
4. Updated `Item` entity with `containerId`
5. `ContentsScreen` - reusable for Location or Container
6. `ContainerCard` with two-letter type badge
7. Navigation from LocationsList → Contents → nested Contents
