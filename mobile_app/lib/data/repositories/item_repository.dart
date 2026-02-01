import 'package:storage_app/core/database/database_interface.dart';
import 'package:storage_app/core/models/item.dart';
import 'package:storage_app/core/platform/platform_provider.dart';

/// Item repository for database operations
/// Uses platform-agnostic DatabaseInterface
class ItemRepository {
  final DatabaseInterface _databaseInterface;

  ItemRepository({DatabaseInterface? databaseInterface})
      : _databaseInterface = databaseInterface ?? PlatformProvider.getDatabase();

  /// Get all items for a location
  Future<List<Item>> getItemsByLocation(String locationId) async {
    final results = await _databaseInterface.getItemsByLocation(locationId);
    return results.map((map) => Item.fromMap(map)).toList();
  }

  /// Get all items
  Future<List<Item>> getAllItems() async {
    final results = await _databaseInterface.getAllItems();
    return results.map((map) => Item.fromMap(map)).toList();
  }

  /// Get an item by ID
  Future<Item?> getItemById(String id) async {
    final result = await _databaseInterface.getItemById(id);
    if (result == null) return null;
    return Item.fromMap(result);
  }

  /// Create a new item
  Future<Item> createItem(Item item) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final itemMap = item.toMap();
    itemMap['created_at'] = now;
    itemMap['updated_at'] = now;

    await _databaseInterface.insertItem(itemMap);
    return item;
  }

  /// Update an existing item
  Future<bool> updateItem(Item item) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final values = item.toMap();
    values['updated_at'] = now;

    // Don't update created_at or id
    values.remove('created_at');
    values.remove('id');

    final rowsAffected = await _databaseInterface.updateItem(item.id, values);
    return rowsAffected > 0;
  }

  /// Delete an item
  Future<bool> deleteItem(String id) async {
    // Note: Photo deletion should be handled by the service layer
    // The repository only handles database operations
    final rowsAffected = await _databaseInterface.deleteItem(id);
    return rowsAffected > 0;
  }

  /// Update item photo
  Future<bool> updateItemPhoto(String id, String? photoPath) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowsAffected = await _databaseInterface.updateItem(
      id,
      {
        'photo_path': photoPath,
        'updated_at': now,
      },
    );
    return rowsAffected > 0;
  }

  /// Move item to a different location
  Future<bool> moveItem(String itemId, String newLocationId) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final rowsAffected = await _databaseInterface.updateItem(
      itemId,
      {
        'location_id': newLocationId,
        'updated_at': now,
      },
    );
    return rowsAffected > 0;
  }
}
