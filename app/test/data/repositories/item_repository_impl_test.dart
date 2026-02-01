import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage_app/data/repositories/item_repository_impl.dart';
import 'package:storage_app/database/database_helper.dart';
import 'package:storage_app/domain/entities/item.dart';
import 'package:storage_app/domain/repositories/item_repository.dart';

import 'item_repository_impl_test.mocks.dart';

/// Generates mocks for DatabaseHelper and Database.
///
/// Run: dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([DatabaseHelper, Database])
void main() {
  group('ItemRepositoryImpl', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late ItemRepositoryImpl repository;
    late MockDatabase mockDatabase;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
      repository = ItemRepositoryImpl(databaseHelper: mockDatabaseHelper);
    });

    // Test data generators
    Item createTestItem({
      int id = 1,
      String name = 'Test Item',
      String? description,
      String? photoPath,
      int locationId = 1,
      int? createdAt,
      int? updatedAt,
    }) {
      return Item(
        id: id,
        name: name,
        description: description,
        photoPath: photoPath,
        locationId: locationId,
        createdAt: createdAt ?? 1000000,
        updatedAt: updatedAt ?? 1000000,
      );
    }

    Map<String, dynamic> createTestItemMap({
      int id = 1,
      String name = 'Test Item',
      String? description,
      String? photoPath,
      int locationId = 1,
      int? createdAt,
      int? updatedAt,
    }) {
      return {
        'id': id,
        'name': name,
        'description': description,
        'photo_path': photoPath,
        'location_id': locationId,
        'created_at': createdAt ?? 1000000,
        'updated_at': updatedAt ?? 1000000,
      };
    }

    Map<String, dynamic> createTestLocationMap({
      int id = 1,
      String name = 'Test Location',
    }) {
      return {
        'id': id,
        'name': name,
        'description': null,
        'photo_path': null,
        'qr_code_id': null,
        'created_at': 1000000,
        'updated_at': 1000000,
      };
    }

    group('getAll', () {
      test('returns empty list when no items exist', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => []);

        final result = await repository.getAll();

        expect(result, isEmpty);
        verify(mockDatabaseHelper.database).called(1);
        verify(mockDatabase.query(
          'items',
          orderBy: 'name ASC',
        )).called(1);
      });

      test('returns all items sorted by name', () async {
        final items = [
          createTestItemMap(id: 1, name: 'Hammer', locationId: 1),
          createTestItemMap(id: 2, name: 'Screwdriver', locationId: 1),
          createTestItemMap(id: 3, name: 'Wrench', locationId: 1),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => items);

        final result = await repository.getAll();

        expect(result.length, 3);
        expect(result[0].name, 'Hammer');
        expect(result[1].name, 'Screwdriver');
        expect(result[2].name, 'Wrench');
      });

      test('returns items with all fields mapped correctly', () async {
        final items = [
          createTestItemMap(
            id: 1,
            name: 'Toolbox',
            description: 'Red toolbox with tools',
            photoPath: '/photos/toolbox.jpg',
            locationId: 1,
            createdAt: 1000000,
            updatedAt: 2000000,
          ),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => items);

        final result = await repository.getAll();

        expect(result.length, 1);
        final item = result[0];
        expect(item.id, 1);
        expect(item.name, 'Toolbox');
        expect(item.description, 'Red toolbox with tools');
        expect(item.photoPath, '/photos/toolbox.jpg');
        expect(item.locationId, 1);
        expect(item.createdAt, 1000000);
        expect(item.updatedAt, 2000000);
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          orderBy: 'name ASC',
        )).thenThrow(Exception('Database connection failed'));

        expect(
          () => repository.getAll(),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve all items'))),
        );
      });
    });

    group('getById', () {
      test('returns item when found', () async {
        final itemMap = createTestItemMap(
          id: 1,
          name: 'Hammer',
          description: 'Steel hammer',
          locationId: 1,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [itemMap]);

        final result = await repository.getById(1);

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.name, 'Hammer');
        expect(result.description, 'Steel hammer');
        expect(result.locationId, 1);
      });

      test('returns null when item not found', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [999],
          limit: 1,
        )).thenAnswer((_) async => []);

        final result = await repository.getById(999);

        expect(result, isNull);
      });

      test('throws ArgumentError for non-positive id', () async {
        expect(
          () => repository.getById(0),
          throwsArgumentError,
        );

        expect(
          () => repository.getById(-1),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.getById(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve item with id'))),
        );
      });
    });

    group('getByLocationId', () {
      test('returns items for given location', () async {
        final items = [
          createTestItemMap(id: 1, name: 'Hammer', locationId: 2),
          createTestItemMap(id: 2, name: 'Wrench', locationId: 2),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'location_id = ?',
          whereArgs: [2],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => items);

        final result = await repository.getByLocationId(2);

        expect(result.length, 2);
        expect(result[0].name, 'Hammer');
        expect(result[0].locationId, 2);
        expect(result[1].name, 'Wrench');
        expect(result[1].locationId, 2);
      });

      test('returns empty list when location has no items', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'location_id = ?',
          whereArgs: [999],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => []);

        final result = await repository.getByLocationId(999);

        expect(result, isEmpty);
      });

      test('throws ArgumentError for non-positive locationId', () async {
        expect(
          () => repository.getByLocationId(0),
          throwsArgumentError,
        );

        expect(
          () => repository.getByLocationId(-1),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'location_id = ?',
          whereArgs: [1],
          orderBy: 'name ASC',
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.getByLocationId(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve items for location id'))),
        );
      });
    });

    group('search', () {
      test('returns empty list for empty query', () async {
        final result = await repository.search('');

        expect(result, isEmpty);
        verifyNever(mockDatabaseHelper.database);
      });

      test('returns empty list for whitespace-only query', () async {
        final result = await repository.search('   ');

        expect(result, isEmpty);
        verifyNever(mockDatabaseHelper.database);
      });

      test('returns matching items by name', () async {
        final items = [
          createTestItemMap(id: 1, name: 'Big Hammer', locationId: 1),
          createTestItemMap(id: 2, name: 'Small Hammer', locationId: 1),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%hammer%', '%hammer%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => items);

        final result = await repository.search('hammer');

        expect(result.length, 2);
        expect(result[0].name, 'Big Hammer');
        expect(result[1].name, 'Small Hammer');
      });

      test('returns matching items by description', () async {
        final items = [
          createTestItemMap(
            id: 1,
            name: 'Tool A',
            description: 'Heavy duty hammer for construction',
            locationId: 1,
          ),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%construction%', '%construction%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => items);

        final result = await repository.search('construction');

        expect(result.length, 1);
        expect(result[0].description, contains('construction'));
      });

      test('trims query before searching', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%hammer%', '%hammer%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => []);

        await repository.search('  hammer  ');

        verify(mockDatabase.query(
          'items',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%hammer%', '%hammer%'],
          orderBy: 'name ASC',
        )).called(1);
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'items',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.search('hammer'),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to search items'))),
        );
      });
    });

    group('create', () {
      test('creates item and returns it with assigned id', () async {
        final newItem = createTestItem(
          id: 0,
          name: 'Hammer',
          description: 'Steel hammer',
          locationId: 1,
        );

        final createdItemMap = createTestItemMap(
          id: 1,
          name: 'Hammer',
          description: 'Steel hammer',
          locationId: 1,
          createdAt: 1000000,
          updatedAt: 1000000,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdItemMap]);

        final result = await repository.create(newItem);

        expect(result.id, 1);
        expect(result.name, 'Hammer');
        expect(result.description, 'Steel hammer');
        expect(result.locationId, 1);
      });

      test('creates item without optional fields', () async {
        final newItem = createTestItem(
          id: 0,
          name: 'Simple Item',
          locationId: 1,
        );

        final createdItemMap = createTestItemMap(
          id: 1,
          name: 'Simple Item',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdItemMap]);

        final result = await repository.create(newItem);

        expect(result.name, 'Simple Item');
      });

      test('throws ArgumentError for empty name', () async {
        final item = createTestItem(id: 0, name: '', locationId: 1);

        expect(
          () => repository.create(item),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for whitespace-only name', () async {
        final item = createTestItem(id: 0, name: '   ', locationId: 1);

        expect(
          () => repository.create(item),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for name exceeding 255 characters', () async {
        final item = createTestItem(
          id: 0,
          name: 'A' * 256,
          locationId: 1,
        );

        expect(
          () => repository.create(item),
          throwsArgumentError,
        );
      });

      test('accepts name with exactly 255 characters', () async {
        final item = createTestItem(
          id: 0,
          name: 'A' * 255,
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Would be valid but db fails'));

        try {
          await repository.create(item);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isNot(isA<ArgumentError>()));
        }
      });

      test('throws ArgumentError for description exceeding 1000 characters', () async {
        final item = createTestItem(
          id: 0,
          name: 'Valid Name',
          description: 'A' * 1001,
          locationId: 1,
        );

        expect(
          () => repository.create(item),
          throwsArgumentError,
        );
      });

      test('accepts description with exactly 1000 characters', () async {
        final item = createTestItem(
          id: 0,
          name: 'Valid Name',
          description: 'A' * 1000,
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Would be valid but db fails'));

        try {
          await repository.create(item);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isNot(isA<ArgumentError>()));
        }
      });

      test('throws ArgumentError for non-positive locationId', () async {
        final item = createTestItem(
          id: 0,
          name: 'Valid Name',
          locationId: 0,
        );

        expect(
          () => repository.create(item),
          throwsArgumentError,
        );

        final item2 = createTestItem(
          id: 0,
          name: 'Valid Name',
          locationId: -1,
        );

        expect(
          () => repository.create(item2),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when location does not exist', () async {
        final item = createTestItem(
          id: 0,
          name: 'Orphan Item',
          locationId: 999,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [999],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.create(item),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on database error during insert', () async {
        final item = createTestItem(
          id: 0,
          name: 'Hammer',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(_TestDatabaseException('Foreign key constraint failed'));

        expect(
          () => repository.create(item),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException when fetching created item fails', () async {
        final newItem = createTestItem(
          id: 0,
          name: 'Hammer',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.create(newItem),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on general database error', () async {
        final item = createTestItem(
          id: 0,
          name: 'Hammer',
          locationId: 1,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenThrow(Exception('Connection failed'));

        expect(
          () => repository.create(item),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to create item'))),
        );
      });
    });

    group('update', () {
      test('updates item and returns updated data', () async {
        final updatedItem = createTestItem(
          id: 1,
          name: 'Updated Hammer',
          description: 'Updated description',
          locationId: 1,
        );

        final updatedItemMap = createTestItemMap(
          id: 1,
          name: 'Updated Hammer',
          description: 'Updated description',
          locationId: 1,
          updatedAt: 2000000,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.update(
          'items',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [updatedItemMap]);

        final result = await repository.update(updatedItem);

        expect(result.id, 1);
        expect(result.name, 'Updated Hammer');
        expect(result.description, 'Updated description');
        expect(result.updatedAt, 2000000);
      });

      test('allows changing item location', () async {
        final updatedItem = createTestItem(
          id: 1,
          name: 'Hammer',
          locationId: 2,
        );

        final updatedItemMap = createTestItemMap(
          id: 1,
          name: 'Hammer',
          locationId: 2,
        );

        final locationMap = createTestLocationMap(id: 2, name: 'Basement');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [2],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.update(
          'items',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [updatedItemMap]);

        final result = await repository.update(updatedItem);

        expect(result.locationId, 2);
      });

      test('throws ArgumentError for item with non-positive id', () async {
        final item = createTestItem(id: 0, name: 'Test', locationId: 1);

        expect(
          () => repository.update(item),
          throwsArgumentError,
        );

        final item2 = createTestItem(id: -1, name: 'Test', locationId: 1);

        expect(
          () => repository.update(item2),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for empty name', () async {
        final item = createTestItem(id: 1, name: '', locationId: 1);

        expect(
          () => repository.update(item),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for name exceeding 255 characters', () async {
        final item = createTestItem(
          id: 1,
          name: 'A' * 256,
          locationId: 1,
        );

        expect(
          () => repository.update(item),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for non-positive locationId', () async {
        final item = createTestItem(
          id: 1,
          name: 'Valid Name',
          locationId: 0,
        );

        expect(
          () => repository.update(item),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when location does not exist', () async {
        final item = createTestItem(
          id: 1,
          name: 'Moving Item',
          locationId: 999,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [999],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.update(item),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException when item not found', () async {
        final item = createTestItem(
          id: 999,
          name: 'Non-existent',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.update(
          'items',
          any,
          where: 'id = ?',
          whereArgs: [999],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 0);

        expect(
          () => repository.update(item),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException when fetching updated item fails', () async {
        final item = createTestItem(
          id: 1,
          name: 'Updated',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);
        when(mockDatabase.update(
          'items',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.update(item),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on general database error', () async {
        final item = createTestItem(
          id: 1,
          name: 'Updated',
          locationId: 1,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.update(item),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to update item'))),
        );
      });
    });

    group('delete', () {
      test('deletes existing item and returns true', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(
          'items',
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        final result = await repository.delete(1);

        expect(result, isTrue);
      });

      test('returns false when item not found', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(
          'items',
          where: 'id = ?',
          whereArgs: [999],
        )).thenAnswer((_) async => 0);

        final result = await repository.delete(999);

        expect(result, isFalse);
      });

      test('throws ArgumentError for non-positive id', () async {
        expect(
          () => repository.delete(0),
          throwsArgumentError,
        );

        expect(
          () => repository.delete(-1),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException on database error', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(
          'items',
          where: 'id = ?',
          whereArgs: [1],
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.delete(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to delete item'))),
        );
      });
    });

    group('count', () {
      test('returns zero when table is empty', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM items'))
            .thenAnswer((_) async => [{'count': 0}]);

        final result = await repository.count();

        expect(result, 0);
      });

      test('returns correct count of items', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM items'))
            .thenAnswer((_) async => [{'count': 10}]);

        final result = await repository.count();

        expect(result, 10);
      });

      test('returns zero when raw query returns null', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM items'))
            .thenAnswer((_) async => []);

        final result = await repository.count();

        expect(result, 0);
      });

      test('throws RepositoryException on database error', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM items'))
            .thenThrow(Exception('Database error'));

        expect(
          () => repository.count(),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to count items'))),
        );
      });
    });

    group('countByLocationId', () {
      test('returns count of items for given location', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [1],
        )).thenAnswer((_) async => [{'count': 5}]);

        final result = await repository.countByLocationId(1);

        expect(result, 5);
      });

      test('returns zero when location has no items', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [999],
        )).thenAnswer((_) async => [{'count': 0}]);

        final result = await repository.countByLocationId(999);

        expect(result, 0);
      });

      test('throws ArgumentError for non-positive locationId', () async {
        expect(
          () => repository.countByLocationId(0),
          throwsArgumentError,
        );

        expect(
          () => repository.countByLocationId(-1),
          throwsArgumentError,
        );
      });

      test('returns zero when raw query returns null', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [1],
        )).thenAnswer((_) async => []);

        final result = await repository.countByLocationId(1);

        expect(result, 0);
      });

      test('throws RepositoryException on database error', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [1],
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.countByLocationId(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to count items for location id'))),
        );
      });
    });

    group('integration scenarios', () {
      test('handles create then read cycle', () async {
        final newItem = createTestItem(id: 0, name: 'New Item', locationId: 1);

        final createdMap = createTestItemMap(
          id: 1,
          name: 'New Item',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdMap]);

        final created = await repository.create(newItem);
        expect(created.id, 1);

        final found = await repository.getById(1);
        expect(found, isNotNull);
        expect(found!.name, 'New Item');
      });

      test('handles items in multiple locations', () async {
        final itemsInLocation1 = [
          createTestItemMap(id: 1, name: 'Hammer', locationId: 1),
          createTestItemMap(id: 2, name: 'Wrench', locationId: 1),
        ];

        final itemsInLocation2 = [
          createTestItemMap(id: 3, name: 'Screwdriver', locationId: 2),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);

        when(mockDatabase.query(
          'items',
          where: 'location_id = ?',
          whereArgs: [1],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => itemsInLocation1);

        when(mockDatabase.query(
          'items',
          where: 'location_id = ?',
          whereArgs: [2],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => itemsInLocation2);

        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [1],
        )).thenAnswer((_) async => [{'count': 2}]);

        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) as count FROM items WHERE location_id = ?',
          [2],
        )).thenAnswer((_) async => [{'count': 1}]);

        final location1Items = await repository.getByLocationId(1);
        final location2Items = await repository.getByLocationId(2);

        expect(location1Items.length, 2);
        expect(location2Items.length, 1);

        expect(await repository.countByLocationId(1), 2);
        expect(await repository.countByLocationId(2), 1);
      });

      test('handles create, update, delete cycle', () async {
        final newItem = createTestItem(id: 0, name: 'Original Item', locationId: 1);

        final createdMap = createTestItemMap(
          id: 1,
          name: 'Original Item',
          locationId: 1,
        );

        final updatedMap = createTestItemMap(
          id: 1,
          name: 'Updated Item',
          locationId: 1,
        );

        final locationMap = createTestLocationMap(id: 1, name: 'Garage');

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        when(mockDatabase.insert(
          'items',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdMap]);

        final created = await repository.create(newItem);
        expect(created.name, 'Original Item');

        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'items',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'items',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [updatedMap]);

        final updated = await repository.update(created.copyWith(name: 'Updated Item'));
        expect(updated.name, 'Updated Item');

        when(mockDatabase.delete(
          'items',
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        final deleted = await repository.delete(1);
        expect(deleted, isTrue);
      });
    });
  });
}

/// Mock Database class for testing.
/// Test-only DatabaseException subclass for simulating database errors.
class _TestDatabaseException extends DatabaseException {
  _TestDatabaseException(String message) : super(message);

  @override
  int? getResultCode() => null;

  @override
  Object? get result => null;
}
