import 'package:sqflite/sqflite.dart';

import '../../domain/entities/container.dart';
import '../../domain/repositories/container_repository.dart';
import '../../database/database_helper.dart';

/// SQLite implementation of [ContainerRepository].
///
/// This repository provides CRUD operations for containers using
/// the local SQLite database. All operations are asynchronous and
/// throw [ContainerRepositoryException] on failure.
///
/// Example usage:
/// ```dart
/// final repository = ContainerRepositoryImpl();
/// final containers = await repository.getAll();
/// final box = await repository.getById(1);
/// final created = await repository.create(Container(...));
/// ```
class ContainerRepositoryImpl implements ContainerRepository {
  /// The database helper instance.
  final DatabaseHelper _databaseHelper;

  /// Table name for containers.
  static const String _tableName = 'containers';

  /// Creates a new [ContainerRepositoryImpl] instance.
  ///
  /// If [databaseHelper] is not provided, uses the default singleton instance.
  ContainerRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Container>> getAll({String orderBy = 'name ASC'}) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: orderBy,
      );

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

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

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

      final List<Map<String, dynamic>> maps = await db.query(
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
        'Failed to retrieve containers for location with id: $locationId',
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

      final List<Map<String, dynamic>> maps = await db.query(
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
        'Failed to retrieve containers for parent container with id: $containerId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Container>> search(String query) async {
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

      return maps.map((map) => Container.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to search containers with query: "$query"',
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
      map.remove('id'); // Remove id for auto-increment
      map['created_at'] = now;
      map['updated_at'] = now;

      final id = await db.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Fetch the newly created container to get all fields
      final created = await getById(id);
      if (created == null) {
        throw ContainerRepositoryException(
          'Failed to retrieve created container with id: $id',
        );
      }

      return created;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      throw ContainerRepositoryException(
        'Database error while creating container',
        e,
      );
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

      // Fetch the updated container
      final updated = await getById(container.id);
      if (updated == null) {
        throw ContainerRepositoryException(
          'Failed to retrieve updated container with id: ${container.id}',
        );
      }

      return updated;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      throw ContainerRepositoryException(
        'Database error while updating container',
        e,
      );
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

      final firstRow = result.first;
      return firstRow['count'] as int;
    } catch (e, stackTrace) {
      throw ContainerRepositoryException(
        'Failed to count containers',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  /// Validates a container before creation.
  void _validateForCreate(Container container) {
    if (container.name.trim().isEmpty) {
      throw ArgumentError('Container name cannot be empty');
    }
    if (container.name.length > 255) {
      throw ArgumentError(
        'Container name cannot exceed 255 characters, got: ${container.name.length}',
      );
    }

    // Validate parent assignment: must have parentLocationId OR parentContainerId (not both, not neither)
    final hasLocationParent = container.parentLocationId != null;
    final hasContainerParent = container.parentContainerId != null;

    if (hasLocationParent && hasContainerParent) {
      throw ArgumentError(
        'Container cannot have both parentLocationId and parentContainerId',
      );
    }

    if (!hasLocationParent && !hasContainerParent) {
      throw ArgumentError(
        'Container must have either parentLocationId or parentContainerId',
      );
    }
  }

  /// Validates a container before update.
  void _validateForUpdate(Container container) {
    if (container.id <= 0) {
      throw ArgumentError('Container id must be positive, got: ${container.id}');
    }
    _validateForCreate(container);
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
