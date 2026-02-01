/// Abstract database interface for platform-agnostic database operations
abstract class DatabaseInterface {
  // Table names
  static const String tableLocations = 'locations';
  static const String tableItems = 'items';
  static const String tableLocationsFts = 'locations_fts';
  static const String tableItemsFts = 'items_fts';

  // Column names
  static const String colId = 'id';
  static const String colName = 'name';
  static const String colDescription = 'description';
  static const String colPhotoPath = 'photo_path';
  static const String colLocationId = 'location_id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colSortOrder = 'sort_order';

  // ==================== Location Operations ====================

  /// Insert a new location
  Future<Map<String, dynamic>> insertLocation(Map<String, dynamic> location);

  /// Update an existing location
  Future<int> updateLocation(String id, Map<String, dynamic> values);

  /// Delete a location
  Future<int> deleteLocation(String id);

  /// Get a location by ID
  Future<Map<String, dynamic>?> getLocationById(String id);

  /// Get all locations
  Future<List<Map<String, dynamic>>> getAllLocations();

  /// Get locations with item count
  Future<List<Map<String, dynamic>>> getLocationWithItemCount();

  // ==================== Item Operations ====================

  /// Insert a new item
  Future<Map<String, dynamic>> insertItem(Map<String, dynamic> item);

  /// Update an existing item
  Future<int> updateItem(String id, Map<String, dynamic> values);

  /// Delete an item
  Future<int> deleteItem(String id);

  /// Get an item by ID
  Future<Map<String, dynamic>?> getItemById(String id);

  /// Get all items for a location
  Future<List<Map<String, dynamic>>> getItemsByLocation(String locationId);

  /// Get all items
  Future<List<Map<String, dynamic>>> getAllItems();

  // ==================== Search Operations ====================

  /// Check if FTS5 is available on this device
  Future<bool> isFts5Available();

  /// Search locations and items
  Future<Map<String, List<Map<String, dynamic>>>> search(String query);

  /// Fallback search using LIKE
  Future<Map<String, List<Map<String, dynamic>>>> searchLike(String query);

  // ==================== Utility Operations ====================

  /// Clear all data
  Future<void> clearAllData();

  /// Close the database
  Future<void> close();
}
