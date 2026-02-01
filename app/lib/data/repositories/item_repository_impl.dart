import 'package:sqflite/sqflite.dart';

import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../../database/database_helper.dart';

/// SQLite implementation of [ItemRepository].
///
/// This repository provides CRUD operations for items using
/// the local SQLite database. All operations are asynchronous and
/// throw [RepositoryException] on failure.
///
/// Example usage:
/// ```dart
/// final repository = ItemRepositoryImpl();
/// final items = await repository.getAll();
/// final hammer = await repository.getById(1);
/// final itemsInGarage = await repository.getByLocationId(1);
/// final itemsInBox = await repository.getByContainerId(5);
/// final created = await repository.create(Item(...));
/// ```
class ItemRepositoryImpl implements ItemRepository {
  /// The database helper instance.
  final DatabaseHelper _databaseHelper;

  /// Table name for items.
  static const String _tableName = 'items';

  /// Creates a new [ItemRepositoryImpl] instance.
  ///
  /// If [databaseHelper] is not provided, uses the default singleton instance.
  ItemRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Item>> getAll() async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );

      return maps.map((map) => Item.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve all items',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Item?> getById(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Item id must be positive, got: $id');
      }

      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Item.fromMap(maps.first);
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve item with id: $id',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Item>> getByLocationId(int locationId) async {
    try {
      if (locationId <= 0) {
        throw ArgumentError('Location id must be positive, got: $locationId');
      }

      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'location_id = ? AND container_id IS NULL',
        whereArgs: [locationId],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Item.fromMap(map)).toList();
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve items for location id: $locationId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Item>> getByContainerId(int containerId) async {
    try {
      if (containerId <= 0) {
        throw ArgumentError('Container id must be positive, got: $containerId');
      }

      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'container_id = ?',
        whereArgs: [containerId],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Item.fromMap(map)).toList();
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve items for container id: $containerId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Item>> search(String query) async {
    try {
      if (query.trim().isEmpty) {
        return const [];
      }

      final db = await _databaseHelper.database;
      final searchPattern = '%${query.trim()}%';

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'name LIKE ? OR description LIKE ?',
        whereArgs: [searchPattern, searchPattern],
        orderBy: 'name ASC',
      );

      return maps.map((map) => Item.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to search items with query: "$query"',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Item> create(Item item) async {
    try {
      _validateItemForCreate(item);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      // Verify the location exists
      final locationExists = await db.query(
        'locations',
        where: 'id = ?',
        whereArgs: [item.locationId],
        limit: 1,
      );

      if (locationExists.isEmpty) {
        throw RepositoryException(
          'Location with id ${item.locationId} does not exist',
        );
      }

      final map = item.toMap();
      map.remove('id'); // Remove id for auto-increment
      map['created_at'] = now;
      map['updated_at'] = now;

      final id = await db.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Fetch the newly created item to get all fields
      final created = await getById(id);
      if (created == null) {
        throw RepositoryException(
          'Failed to retrieve created item with id: $id',
        );
      }

      return created;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      throw RepositoryException(
        'Database error while creating item',
        e,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to create item: ${item.name}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Item> update(Item item) async {
    try {
      _validateItemForUpdate(item);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      // Verify the location exists
      final locationExists = await db.query(
        'locations',
        where: 'id = ?',
        whereArgs: [item.locationId],
        limit: 1,
      );

      if (locationExists.isEmpty) {
        throw RepositoryException(
          'Location with id ${item.locationId} does not exist',
        );
      }

      final map = item.toMap();
      map['updated_at'] = now;

      final rowsAffected = await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [item.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (rowsAffected == 0) {
        throw RepositoryException(
          'Item with id ${item.id} not found',
        );
      }

      // Fetch the updated item
      final updated = await getById(item.id);
      if (updated == null) {
        throw RepositoryException(
          'Failed to retrieve updated item with id: ${item.id}',
        );
      }

      return updated;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      throw RepositoryException(
        'Database error while updating item',
        e,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to update item with id: ${item.id}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Item id must be positive, got: $id');
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
      throw RepositoryException(
        'Failed to delete item with id: $id',
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
      throw RepositoryException(
        'Failed to count items',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<int> countByLocationId(int locationId) async {
    try {
      if (locationId <= 0) {
        throw ArgumentError('Location id must be positive, got: $locationId');
      }

      final db = await _databaseHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE location_id = ? AND container_id IS NULL',
        [locationId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to count items for location id: $locationId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<int> countByContainerId(int containerId) async {
    try {
      if (containerId <= 0) {
        throw ArgumentError('Container id must be positive, got: $containerId');
      }

      final db = await _databaseHelper.database;

      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableName WHERE container_id = ?',
        [containerId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to count items for container id: $containerId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  /// Validates an item before creation.
  void _validateItemForCreate(Item item) {
    if (item.name.trim().isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (item.name.length > 255) {
      throw ArgumentError(
        'Item name cannot exceed 255 characters, got: ${item.name.length}',
      );
    }
    if (item.description != null && item.description!.length > 1000) {
      throw ArgumentError(
        'Item description cannot exceed 1000 characters, got: ${item.description!.length}',
      );
    }
    if (item.locationId <= 0) {
      throw ArgumentError(
        'Item locationId must be positive, got: ${item.locationId}',
      );
    }
  }

  /// Validates an item before update.
  void _validateItemForUpdate(Item item) {
    if (item.id <= 0) {
      throw ArgumentError('Item id must be positive, got: ${item.id}');
    }
    _validateItemForCreate(item);
  }

  /// Creates detailed exception information for error reporting.
  static Object _createExceptionDetails(Object error, StackTrace stackTrace) {
    return _ExceptionDetails(error, stackTrace);
  }
}

/// Internal class to capture exception details for debugging.
class _ExceptionDetails {
  final Object error;
  final StackTrace stackTrace;

  const _ExceptionDetails(this.error, this.stackTrace);

  @override
  String toString() => error.toString();
}
