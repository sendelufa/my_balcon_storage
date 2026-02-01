import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage_app/database/database_helper.dart';

/// Test utilities for database testing.
class DatabaseTestHelpers {
  /// Initialize FFI for desktop testing.
  static void initFfi() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  /// Create a test location with the given name.
  static Future<int> createTestLocation(
    Database db, {
    required String name,
    String? description,
    String? photoPath,
    String? qrCodeId,
  }) async {
    final dbHelper = DatabaseHelper.instance;
    final timestamp = dbHelper.currentTime;

    return await db.insert('locations', {
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'qr_code_id': qrCodeId,
      'created_at': timestamp,
      'updated_at': timestamp,
    });
  }

  /// Create a test item with the given name and location.
  static Future<int> createTestItem(
    Database db, {
    required String name,
    required int locationId,
    String? description,
    String? photoPath,
  }) async {
    final dbHelper = DatabaseHelper.instance;
    final timestamp = dbHelper.currentTime;

    return await db.insert('items', {
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'location_id': locationId,
      'created_at': timestamp,
      'updated_at': timestamp,
    });
  }

  /// Clear all tables for a clean test state.
  static Future<void> clearAllTables(Database db) async {
    await db.delete('items');
    await db.delete('locations');
  }

  /// Count rows in a table.
  static Future<int> countRows(Database db, String table) async {
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }
}

/// Mock data generators for testing.
class MockData {
  /// Generate a random location name.
  static String locationName() => 'Location_${DateTime.now().millisecondsSinceEpoch}';

  /// Generate a random item name.
  static String itemName() => 'Item_${DateTime.now().millisecondsSinceEpoch}';

  /// Generate a random QR code ID.
  static String qrCodeId() => 'QR_${DateTime.now().millisecondsSinceEpoch}';

  /// Generate a random description.
  static String description() => 'Description_${DateTime.now().millisecondsSinceEpoch}';

  /// Generate a random photo path.
  static String photoPath() => '/photos/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
}
