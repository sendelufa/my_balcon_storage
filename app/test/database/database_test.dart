import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:storage_app/database/database_helper.dart';

void main() {
  // Setup FFI for desktop testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper', () {
    late DatabaseHelper dbHelper;

    setUp(() {
      dbHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      // Clear all data and close database after each test
      final db = await dbHelper.database;
      await db.delete('items');
      await db.delete('locations');
      await dbHelper.close();
    });

    test('database creates successfully', () async {
      final db = await dbHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('locations table has correct schema', () async {
      final db = await dbHelper.database;

      // Query sqlite_master for table schema
      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='locations'",
      );

      expect(result.isNotEmpty, isTrue);
      final sql = result.first['sql'] as String;

      // Verify key columns exist
      expect(sql, contains('id INTEGER PRIMARY KEY AUTOINCREMENT'));
      expect(sql, contains('name TEXT NOT NULL'));
      expect(sql, contains('description TEXT'));
      expect(sql, contains('photo_path TEXT'));
      expect(sql, contains('qr_code_id TEXT UNIQUE'));
      expect(sql, contains('created_at INTEGER NOT NULL'));
      expect(sql, contains('updated_at INTEGER NOT NULL'));
    });

    test('items table has correct schema', () async {
      final db = await dbHelper.database;

      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='items'",
      );

      expect(result.isNotEmpty, isTrue);
      final sql = result.first['sql'] as String;

      // Verify key columns exist
      expect(sql, contains('id INTEGER PRIMARY KEY AUTOINCREMENT'));
      expect(sql, contains('name TEXT NOT NULL'));
      expect(sql, contains('description TEXT'));
      expect(sql, contains('photo_path TEXT'));
      expect(sql, contains('location_id INTEGER NOT NULL'));
      expect(sql, contains('created_at INTEGER NOT NULL'));
      expect(sql, contains('updated_at INTEGER NOT NULL'));
      expect(sql, contains('FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE'));
    });

    test('all indexes are created', () async {
      final db = await dbHelper.database;

      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      );

      final indexNames = result.map((row) => row['name'] as String).toList();

      expect(indexNames, contains('idx_locations_name'));
      expect(indexNames, contains('idx_locations_qr_code'));
      expect(indexNames, contains('idx_items_name'));
      expect(indexNames, contains('idx_items_location_id'));
    });

    test('foreign key cascade delete works', () async {
      final db = await dbHelper.database;

      // Insert a location
      final timestamp = dbHelper.currentTime;
      final locationResult = await db.insert('locations', {
        'name': 'Test Location',
        'description': 'Test description',
        'photo_path': null,
        'qr_code_id': 'QR123',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      expect(locationResult, greaterThan(0));

      // Insert items for this location
      await db.insert('items', {
        'name': 'Item 1',
        'description': 'Test item',
        'photo_path': null,
        'location_id': locationResult,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      await db.insert('items', {
        'name': 'Item 2',
        'description': 'Another test item',
        'photo_path': null,
        'location_id': locationResult,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Verify items exist
      final itemsBefore = await db.query(
        'items',
        where: 'location_id = ?',
        whereArgs: [locationResult],
      );
      expect(itemsBefore.length, 2);

      // Delete the location
      await db.delete('locations', where: 'id = ?', whereArgs: [locationResult]);

      // Verify items are cascade deleted
      final itemsAfter = await db.query(
        'items',
        where: 'location_id = ?',
        whereArgs: [locationResult],
      );
      expect(itemsAfter.length, 0);
    });

    test('database close works properly', () async {
      final db = await dbHelper.database;

      // Verify database is open
      expect(db.isOpen, isTrue);

      // Close the database
      await dbHelper.close();

      // Get a fresh database instance
      final db2 = await dbHelper.database;

      // Should be a new connection
      expect(db2.isOpen, isTrue);
    });

    test('CRUD operations work for locations', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // CREATE
      final id = await db.insert('locations', {
        'name': 'Garage',
        'description': 'My garage storage',
        'photo_path': '/photos/garage.jpg',
        'qr_code_id': 'GARAGE001',
        'created_at': timestamp,
        'updated_at': timestamp,
      });
      expect(id, greaterThan(0));

      // READ
      final locations = await db.query('locations', where: 'id = ?', whereArgs: [id]);
      expect(locations.length, 1);
      expect(locations.first['name'], 'Garage');
      expect(locations.first['description'], 'My garage storage');

      // UPDATE
      await db.update(
        'locations',
        {'name': 'Updated Garage', 'updated_at': dbHelper.currentTime},
        where: 'id = ?',
        whereArgs: [id],
      );

      final updated = await db.query('locations', where: 'id = ?', whereArgs: [id]);
      expect(updated.first['name'], 'Updated Garage');

      // DELETE
      await db.delete('locations', where: 'id = ?', whereArgs: [id]);
      final deleted = await db.query('locations', where: 'id = ?', whereArgs: [id]);
      expect(deleted, isEmpty);
    });

    test('CRUD operations work for items', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // First create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'description': 'For items test',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // CREATE item
      final itemId = await db.insert('items', {
        'name': 'Toolbox',
        'description': 'Red toolbox',
        'photo_path': '/photos/toolbox.jpg',
        'location_id': locationId,
        'created_at': timestamp,
        'updated_at': timestamp,
      });
      expect(itemId, greaterThan(0));

      // READ item
      final items = await db.query('items', where: 'id = ?', whereArgs: [itemId]);
      expect(items.length, 1);
      expect(items.first['name'], 'Toolbox');
      expect(items.first['location_id'], locationId);

      // UPDATE item
      await db.update(
        'items',
        {'name': 'Blue Toolbox', 'updated_at': dbHelper.currentTime},
        where: 'id = ?',
        whereArgs: [itemId],
      );

      final updated = await db.query('items', where: 'id = ?', whereArgs: [itemId]);
      expect(updated.first['name'], 'Blue Toolbox');

      // DELETE item
      await db.delete('items', where: 'id = ?', whereArgs: [itemId]);
      final deleted = await db.query('items', where: 'id = ?', whereArgs: [itemId]);
      expect(deleted, isEmpty);
    });

    test('qr_code_id unique constraint works', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // Insert first location with QR code
      await db.insert('locations', {
        'name': 'Location 1',
        'qr_code_id': 'QR123',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Try to insert second location with same QR code - should fail
      expect(
        () => db.insert('locations', {
          'name': 'Location 2',
          'qr_code_id': 'QR123',
          'created_at': timestamp,
          'updated_at': timestamp,
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
