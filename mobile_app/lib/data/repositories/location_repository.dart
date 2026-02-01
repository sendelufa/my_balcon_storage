import 'package:storage_app/core/database/database_interface.dart';
import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/core/platform/platform_provider.dart';

/// Location repository for database operations
/// Uses platform-agnostic DatabaseInterface
class LocationRepository {
  final DatabaseInterface _databaseInterface;

  LocationRepository({DatabaseInterface? databaseInterface})
      : _databaseInterface = databaseInterface ?? PlatformProvider.getDatabase();

  /// Get all locations with item counts
  Future<List<Location>> getAllLocations() async {
    final results = await _databaseInterface.getLocationWithItemCount();
    return results.map((map) => Location.fromMap(map)).toList();
  }

  /// Get a location by ID
  Future<Location?> getLocationById(String id) async {
    final result = await _databaseInterface.getLocationById(id);
    if (result == null) return null;

    // The result already includes item_count from getLocationWithItemCount
    // But for single location query, we need to get it from the map
    final location = Location.fromMap(result);
    return location;
  }

  /// Create a new location
  Future<Location> createLocation(Location location) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final locationMap = location.toMap();
    locationMap['created_at'] = now;
    locationMap['updated_at'] = now;

    await _databaseInterface.insertLocation(locationMap);
    return location;
  }

  /// Update an existing location
  Future<bool> updateLocation(Location location) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final values = location.toMap();
    values['updated_at'] = now;

    // Don't update created_at or id
    values.remove('created_at');
    values.remove('id');

    final rowsAffected = await _databaseInterface.updateLocation(location.id, values);
    return rowsAffected > 0;
  }

  /// Delete a location
  Future<bool> deleteLocation(String id) async {
    // Note: Photo deletion should be handled by the service layer
    // The repository only handles database operations
    final rowsAffected = await _databaseInterface.deleteLocation(id);
    return rowsAffected > 0;
  }

  /// Update location photo
  Future<bool> updateLocationPhoto(String id, String? photoPath) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowsAffected = await _databaseInterface.updateLocation(
      id,
      {
        'photo_path': photoPath,
        'updated_at': now,
      },
    );
    return rowsAffected > 0;
  }
}
