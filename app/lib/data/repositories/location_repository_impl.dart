import 'package:sqflite/sqflite.dart';

import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../../database/database_helper.dart';

/// SQLite implementation of [LocationRepository].
///
/// This repository provides CRUD operations for locations using
/// the local SQLite database. All operations are asynchronous and
/// throw [RepositoryException] on failure.
///
/// Example usage:
/// ```dart
/// final repository = LocationRepositoryImpl();
/// final locations = await repository.getAll();
/// final garage = await repository.getById(1);
/// final created = await repository.create(Location(...));
/// ```
class LocationRepositoryImpl implements LocationRepository {
  /// The database helper instance.
  final DatabaseHelper _databaseHelper;

  /// Table name for locations.
  static const String _tableName = 'locations';

  /// Creates a new [LocationRepositoryImpl] instance.
  ///
  /// If [databaseHelper] is not provided, uses the default singleton instance.
  LocationRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Location>> getAll() async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        orderBy: 'name ASC',
      );

      return maps.map((map) => Location.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve all locations',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Location?> getById(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Location id must be positive, got: $id');
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

      return Location.fromMap(maps.first);
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve location with id: $id',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Location?> getByQrCodeId(String qrCodeId) async {
    try {
      if (qrCodeId.isEmpty) {
        throw ArgumentError('QR code id cannot be empty');
      }

      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> maps = await db.query(
        _tableName,
        where: 'qr_code_id = ?',
        whereArgs: [qrCodeId],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return Location.fromMap(maps.first);
    } on ArgumentError {
      rethrow;
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to retrieve location with QR code id: $qrCodeId',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<List<Location>> search(String query) async {
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

      return maps.map((map) => Location.fromMap(map)).toList();
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to search locations with query: "$query"',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Location> create(Location location) async {
    try {
      _validateLocationForCreate(location);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      final map = location.toMap();
      map.remove('id'); // Remove id for auto-increment
      map['created_at'] = now;
      map['updated_at'] = now;

      final id = await db.insert(
        _tableName,
        map,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      // Fetch the newly created location to get all fields
      final created = await getById(id);
      if (created == null) {
        throw RepositoryException(
          'Failed to retrieve created location with id: $id',
        );
      }

      return created;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError('qr_code_id')) {
        throw RepositoryException(
          'A location with QR code id "${location.qrCodeId}" already exists',
          e,
        );
      }
      throw RepositoryException(
        'Database error while creating location',
        e,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to create location: ${location.name}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<Location> update(Location location) async {
    try {
      _validateLocationForUpdate(location);

      final db = await _databaseHelper.database;
      final now = _databaseHelper.currentTime;

      final map = location.toMap();
      map['updated_at'] = now;

      final rowsAffected = await db.update(
        _tableName,
        map,
        where: 'id = ?',
        whereArgs: [location.id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );

      if (rowsAffected == 0) {
        throw RepositoryException(
          'Location with id ${location.id} not found',
        );
      }

      // Fetch the updated location
      final updated = await getById(location.id);
      if (updated == null) {
        throw RepositoryException(
          'Failed to retrieve updated location with id: ${location.id}',
        );
      }

      return updated;
    } on ArgumentError {
      rethrow;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError('qr_code_id')) {
        throw RepositoryException(
          'A location with QR code id "${location.qrCodeId}" already exists',
          e,
        );
      }
      throw RepositoryException(
        'Database error while updating location',
        e,
      );
    } catch (e, stackTrace) {
      throw RepositoryException(
        'Failed to update location with id: ${location.id}',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      if (id <= 0) {
        throw ArgumentError('Location id must be positive, got: $id');
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
        'Failed to delete location with id: $id',
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
        'Failed to count locations',
        _createExceptionDetails(e, stackTrace),
      );
    }
  }

  /// Validates a location before creation.
  void _validateLocationForCreate(Location location) {
    if (location.name.trim().isEmpty) {
      throw ArgumentError('Location name cannot be empty');
    }
    if (location.name.length > 255) {
      throw ArgumentError(
        'Location name cannot exceed 255 characters, got: ${location.name.length}',
      );
    }
    if (location.description != null && location.description!.length > 1000) {
      throw ArgumentError(
        'Location description cannot exceed 1000 characters, got: ${location.description!.length}',
      );
    }
  }

  /// Validates a location before update.
  void _validateLocationForUpdate(Location location) {
    if (location.id <= 0) {
      throw ArgumentError('Location id must be positive, got: ${location.id}');
    }
    _validateLocationForCreate(location);
  }

  /// Creates detailed exception information for error reporting.
  static Object _createExceptionDetails(Object error, StackTrace stackTrace) {
    return _ExceptionDetails(error, stackTrace);
  }
}

/// Extension to check for specific database constraint errors.
extension DatabaseExceptionExtension on DatabaseException {
  /// Checks if this exception is a unique constraint error for the given column.
  bool isUniqueConstraintError(String columnName) {
    final message = toString().toLowerCase();
    return message.contains('unique') &&
        (message.contains(columnName.toLowerCase()) ||
            message.contains('constraint'));
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
