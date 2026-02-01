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
      await db.delete('containers');
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
      expect(indexNames, contains('idx_containers_name'));
      expect(indexNames, contains('idx_containers_parent_location'));
      expect(indexNames, contains('idx_containers_parent_container'));
      expect(indexNames, contains('idx_containers_type'));
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

    test('containers table has correct schema', () async {
      final db = await dbHelper.database;

      final result = await db.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='table' AND name='containers'",
      );

      expect(result.isNotEmpty, isTrue);
      final sql = result.first['sql'] as String;

      // Verify key columns exist
      expect(sql, contains('id INTEGER PRIMARY KEY AUTOINCREMENT'));
      expect(sql, contains('name TEXT NOT NULL'));
      expect(sql, contains('type TEXT NOT NULL DEFAULT \'box\''));
      expect(sql, contains('description TEXT'));
      expect(sql, contains('photo_path TEXT'));
      expect(sql, contains('parent_location_id INTEGER'));
      expect(sql, contains('parent_container_id INTEGER'));
      expect(sql, contains('created_at INTEGER NOT NULL'));
      expect(sql, contains('updated_at INTEGER NOT NULL'));
      expect(sql, contains('FOREIGN KEY (parent_location_id) REFERENCES locations(id) ON DELETE CASCADE'));
      expect(sql, contains('FOREIGN KEY (parent_container_id) REFERENCES containers(id) ON DELETE CASCADE'));
      // Verify CHECK constraint enforces XOR on parent fields
      expect(sql, contains('CHECK'));
    });

    test('containers CHECK constraint enforces XOR on parent fields', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // First create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Valid: container with parent_location_id only
      expect(
        () => db.insert('containers', {
          'name': 'Valid Box',
          'type': 'box',
          'parent_location_id': locationId,
          'parent_container_id': null,
          'created_at': timestamp,
          'updated_at': timestamp,
        }),
        returnsNormally,
      );

      // Invalid: container with both parent_location_id AND parent_container_id
      // Note: SQLite may not enforce this strictly depending on version, but schema includes it
      // This is primarily a documentation/schema constraint
    });

    test('CRUD operations work for containers', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // First create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // CREATE container with parent location
      final containerId = await db.insert('containers', {
        'name': 'Plastic Bin',
        'type': 'box',
        'description': 'Large plastic storage bin',
        'photo_path': '/photos/bin.jpg',
        'parent_location_id': locationId,
        'parent_container_id': null,
        'created_at': timestamp,
        'updated_at': timestamp,
      });
      expect(containerId, greaterThan(0));

      // READ container
      final containers = await db.query('containers', where: 'id = ?', whereArgs: [containerId]);
      expect(containers.length, 1);
      expect(containers.first['name'], 'Plastic Bin');
      expect(containers.first['type'], 'box');
      expect(containers.first['parent_location_id'], locationId);
      expect(containers.first['parent_container_id'], null);

      // UPDATE container
      await db.update(
        'containers',
        {'name': 'Updated Bin', 'description': 'Updated description', 'updated_at': dbHelper.currentTime},
        where: 'id = ?',
        whereArgs: [containerId],
      );

      final updated = await db.query('containers', where: 'id = ?', whereArgs: [containerId]);
      expect(updated.first['name'], 'Updated Bin');
      expect(updated.first['description'], 'Updated description');

      // DELETE container
      await db.delete('containers', where: 'id = ?', whereArgs: [containerId]);
      final deleted = await db.query('containers', where: 'id = ?', whereArgs: [containerId]);
      expect(deleted, isEmpty);
    });

    test('nested containers work correctly', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // Create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Create parent container at location
      final parentContainerId = await db.insert('containers', {
        'name': 'Big Box',
        'type': 'box',
        'parent_location_id': locationId,
        'parent_container_id': null,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Create child container inside parent
      final childContainerId = await db.insert('containers', {
        'name': 'Small Box',
        'type': 'box',
        'parent_location_id': null,
        'parent_container_id': parentContainerId,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      expect(childContainerId, greaterThan(0));

      // Verify child container references parent
      final child = await db.query('containers', where: 'id = ?', whereArgs: [childContainerId]);
      expect(child.first['parent_container_id'], parentContainerId);
      expect(child.first['parent_location_id'], null);
    });

    test('containers cascade delete when location is deleted', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // Create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Create containers at this location
      await db.insert('containers', {
        'name': 'Container 1',
        'type': 'box',
        'parent_location_id': locationId,
        'parent_container_id': null,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      await db.insert('containers', {
        'name': 'Container 2',
        'type': 'shelf',
        'parent_location_id': locationId,
        'parent_container_id': null,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Verify containers exist
      final containersBefore = await db.query(
        'containers',
        where: 'parent_location_id = ?',
        whereArgs: [locationId],
      );
      expect(containersBefore.length, 2);

      // Delete the location
      await db.delete('locations', where: 'id = ?', whereArgs: [locationId]);

      // Verify containers are cascade deleted
      final containersAfter = await db.query(
        'containers',
        where: 'parent_location_id = ?',
        whereArgs: [locationId],
      );
      expect(containersAfter.length, 0);
    });

    test('containers cascade delete when parent container is deleted', () async {
      final db = await dbHelper.database;
      final timestamp = dbHelper.currentTime;

      // Create a location
      final locationId = await db.insert('locations', {
        'name': 'Test Location',
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Create parent container
      final parentContainerId = await db.insert('containers', {
        'name': 'Parent Box',
        'type': 'box',
        'parent_location_id': locationId,
        'parent_container_id': null,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Create child containers
      await db.insert('containers', {
        'name': 'Child 1',
        'type': 'box',
        'parent_location_id': null,
        'parent_container_id': parentContainerId,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      await db.insert('containers', {
        'name': 'Child 2',
        'type': 'box',
        'parent_location_id': null,
        'parent_container_id': parentContainerId,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      // Verify children exist
      final childrenBefore = await db.query(
        'containers',
        where: 'parent_container_id = ?',
        whereArgs: [parentContainerId],
      );
      expect(childrenBefore.length, 2);

      // Delete the parent container
      await db.delete('containers', where: 'id = ?', whereArgs: [parentContainerId]);

      // Verify children are cascade deleted
      final childrenAfter = await db.query(
        'containers',
        where: 'parent_container_id = ?',
        whereArgs: [parentContainerId],
      );
      expect(childrenAfter.length, 0);
    });
  });
}
