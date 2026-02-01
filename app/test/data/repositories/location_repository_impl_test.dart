import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:storage_app/data/repositories/location_repository_impl.dart';
import 'package:storage_app/database/database_helper.dart';
import 'package:storage_app/domain/entities/location.dart';
import 'package:storage_app/domain/repositories/location_repository.dart';

import 'location_repository_impl_test.mocks.dart';

/// Generates mocks for DatabaseHelper and Database.
///
/// Run: dart run build_runner build --delete-conflicting-outputs
@GenerateMocks([DatabaseHelper, Database])
void main() {
  group('LocationRepositoryImpl', () {
    late MockDatabaseHelper mockDatabaseHelper;
    late LocationRepositoryImpl repository;
    late MockDatabase mockDatabase;

    setUp(() {
      mockDatabaseHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
      repository = LocationRepositoryImpl(databaseHelper: mockDatabaseHelper);
    });

    // Test data generators
    Location createTestLocation({
      int id = 1,
      String name = 'Test Location',
      String? description,
      String? photoPath,
      String? qrCodeId,
      int? createdAt,
      int? updatedAt,
    }) {
      return Location(
        id: id,
        name: name,
        description: description,
        photoPath: photoPath,
        qrCodeId: qrCodeId,
        createdAt: createdAt ?? 1000000,
        updatedAt: updatedAt ?? 1000000,
      );
    }

    Map<String, dynamic> createTestLocationMap({
      int id = 1,
      String name = 'Test Location',
      String? description,
      String? photoPath,
      String? qrCodeId,
      int? createdAt,
      int? updatedAt,
    }) {
      return {
        'id': id,
        'name': name,
        'description': description,
        'photo_path': photoPath,
        'qr_code_id': qrCodeId,
        'created_at': createdAt ?? 1000000,
        'updated_at': updatedAt ?? 1000000,
      };
    }

    group('getAll', () {
      test('returns empty list when no locations exist', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => []);

        final result = await repository.getAll();

        expect(result, isEmpty);
        verify(mockDatabaseHelper.database).called(1);
        verify(mockDatabase.query(
          'locations',
          orderBy: 'name ASC',
        )).called(1);
      });

      test('returns all locations sorted by name', () async {
        final locations = [
          createTestLocationMap(id: 1, name: 'Attic'),
          createTestLocationMap(id: 2, name: 'Basement'),
          createTestLocationMap(id: 3, name: 'Garage'),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => locations);

        final result = await repository.getAll();

        expect(result.length, 3);
        expect(result[0].name, 'Attic');
        expect(result[1].name, 'Basement');
        expect(result[2].name, 'Garage');
      });

      test('returns locations with all fields mapped correctly', () async {
        final locations = [
          createTestLocationMap(
            id: 1,
            name: 'Garage',
            description: 'Main storage',
            photoPath: '/photos/garage.jpg',
            qrCodeId: 'GARAGE001',
            createdAt: 1000000,
            updatedAt: 2000000,
          ),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          orderBy: 'name ASC',
        )).thenAnswer((_) async => locations);

        final result = await repository.getAll();

        expect(result.length, 1);
        final location = result[0];
        expect(location.id, 1);
        expect(location.name, 'Garage');
        expect(location.description, 'Main storage');
        expect(location.photoPath, '/photos/garage.jpg');
        expect(location.qrCodeId, 'GARAGE001');
        expect(location.createdAt, 1000000);
        expect(location.updatedAt, 2000000);
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          orderBy: 'name ASC',
        )).thenThrow(Exception('Database connection failed'));

        expect(
          () => repository.getAll(),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve all locations'))),
        );
      });
    });

    group('getById', () {
      test('returns location when found', () async {
        final locationMap = createTestLocationMap(
          id: 1,
          name: 'Garage',
          description: 'Main storage',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        final result = await repository.getById(1);

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.name, 'Garage');
        expect(result.description, 'Main storage');
      });

      test('returns null when location not found', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
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
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.getById(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve location with id'))),
        );
      });
    });

    group('getByQrCodeId', () {
      test('returns location when QR code found', () async {
        final locationMap = createTestLocationMap(
          id: 1,
          name: 'Garage',
          qrCodeId: 'GARAGE001',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'qr_code_id = ?',
          whereArgs: ['GARAGE001'],
          limit: 1,
        )).thenAnswer((_) async => [locationMap]);

        final result = await repository.getByQrCodeId('GARAGE001');

        expect(result, isNotNull);
        expect(result!.id, 1);
        expect(result.name, 'Garage');
        expect(result.qrCodeId, 'GARAGE001');
      });

      test('returns null when QR code not found', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'qr_code_id = ?',
          whereArgs: ['NONEXISTENT'],
          limit: 1,
        )).thenAnswer((_) async => []);

        final result = await repository.getByQrCodeId('NONEXISTENT');

        expect(result, isNull);
      });

      test('throws ArgumentError for empty QR code id', () async {
        expect(
          () => repository.getByQrCodeId(''),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'qr_code_id = ?',
          whereArgs: ['GARAGE001'],
          limit: 1,
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.getByQrCodeId('GARAGE001'),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to retrieve location with QR code id'))),
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

      test('returns matching locations by name', () async {
        final locations = [
          createTestLocationMap(id: 1, name: 'Big Garage'),
          createTestLocationMap(id: 2, name: 'Small Garage'),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%garage%', '%garage%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => locations);

        final result = await repository.search('garage');

        expect(result.length, 2);
        expect(result[0].name, 'Big Garage');
        expect(result[1].name, 'Small Garage');
      });

      test('returns matching locations by description', () async {
        final locations = [
          createTestLocationMap(
            id: 1,
            name: 'Storage A',
            description: 'Contains gardening tools',
          ),
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%garden%', '%garden%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => locations);

        final result = await repository.search('garden');

        expect(result.length, 1);
        expect(result[0].description, contains('gardening'));
      });

      test('trims query before searching', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%garage%', '%garage%'],
          orderBy: 'name ASC',
        )).thenAnswer((_) async => []);

        await repository.search('  garage  ');

        verify(mockDatabase.query(
          'locations',
          where: 'name LIKE ? OR description LIKE ?',
          whereArgs: ['%garage%', '%garage%'],
          orderBy: 'name ASC',
        )).called(1);
      });

      test('throws RepositoryException when database query fails', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          'locations',
          where: anyNamed('where'),
          whereArgs: anyNamed('whereArgs'),
          orderBy: anyNamed('orderBy'),
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.search('garage'),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to search locations'))),
        );
      });
    });

    group('create', () {
      test('creates location and returns it with assigned id', () async {
        final newLocation = createTestLocation(
          id: 0,
          name: 'Garage',
          description: 'Main storage',
        );

        final createdLocationMap = createTestLocationMap(
          id: 1,
          name: 'Garage',
          description: 'Main storage',
          createdAt: 1000000,
          updatedAt: 1000000,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdLocationMap]);

        final result = await repository.create(newLocation);

        expect(result.id, 1);
        expect(result.name, 'Garage');
        expect(result.description, 'Main storage');
        verify(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).called(1);
      });

      test('creates location without optional fields', () async {
        final newLocation = createTestLocation(
          id: 0,
          name: 'Simple Location',
        );

        final createdLocationMap = createTestLocationMap(
          id: 1,
          name: 'Simple Location',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdLocationMap]);

        final result = await repository.create(newLocation);

        expect(result.name, 'Simple Location');
      });

      test('throws ArgumentError for empty name', () async {
        final location = createTestLocation(name: '');

        expect(
          () => repository.create(location),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for whitespace-only name', () async {
        final location = createTestLocation(name: '   ');

        expect(
          () => repository.create(location),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for name exceeding 255 characters', () async {
        final location = createTestLocation(
          name: 'A' * 256,
        );

        expect(
          () => repository.create(location),
          throwsArgumentError,
        );
      });

      test('accepts name with exactly 255 characters', () async {
        final location = createTestLocation(
          id: 0,
          name: 'A' * 255,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Would be valid but db fails'));

        try {
          await repository.create(location);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isNot(isA<ArgumentError>()));
        }
      });

      test('throws ArgumentError for description exceeding 1000 characters', () async {
        final location = createTestLocation(
          id: 0,
          name: 'Valid Name',
          description: 'A' * 1001,
        );

        expect(
          () => repository.create(location),
          throwsArgumentError,
        );
      });

      test('accepts description with exactly 1000 characters', () async {
        final location = createTestLocation(
          id: 0,
          name: 'Valid Name',
          description: 'A' * 1000,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Would be valid but db fails'));

        try {
          await repository.create(location);
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isNot(isA<ArgumentError>()));
        }
      });

      test('throws RepositoryException on unique constraint violation for QR code', () async {
        final location = createTestLocation(
          id: 0,
          name: 'New Location',
          qrCodeId: 'DUPLICATE_QR',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(_TestDatabaseException('UNIQUE constraint failed: locations.qr_code_id'));

        expect(
          () => repository.create(location),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException when fetching created location fails', () async {
        final newLocation = createTestLocation(
          id: 0,
          name: 'Garage',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.create(newLocation),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on general database error', () async {
        final location = createTestLocation(
          id: 0,
          name: 'Garage',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Connection failed'));

        expect(
          () => repository.create(location),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to create location'))),
        );
      });
    });

    group('update', () {
      test('updates location and returns updated data', () async {
        final updatedLocation = createTestLocation(
          id: 1,
          name: 'Updated Garage',
          description: 'Updated description',
        );

        final updatedLocationMap = createTestLocationMap(
          id: 1,
          name: 'Updated Garage',
          description: 'Updated description',
          updatedAt: 2000000,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [updatedLocationMap]);

        final result = await repository.update(updatedLocation);

        expect(result.id, 1);
        expect(result.name, 'Updated Garage');
        expect(result.description, 'Updated description');
        expect(result.updatedAt, 2000000);
      });

      test('throws ArgumentError for location with non-positive id', () async {
        final location = createTestLocation(id: 0, name: 'Test');

        expect(
          () => repository.update(location),
          throwsArgumentError,
        );

        final location2 = createTestLocation(id: -1, name: 'Test');

        expect(
          () => repository.update(location2),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for empty name', () async {
        final location = createTestLocation(id: 1, name: '');

        expect(
          () => repository.update(location),
          throwsArgumentError,
        );
      });

      test('throws ArgumentError for name exceeding 255 characters', () async {
        final location = createTestLocation(
          id: 1,
          name: 'A' * 256,
        );

        expect(
          () => repository.update(location),
          throwsArgumentError,
        );
      });

      test('throws RepositoryException when location not found', () async {
        final location = createTestLocation(
          id: 999,
          name: 'Non-existent',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [999],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 0);

        expect(
          () => repository.update(location),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on unique constraint violation for QR code', () async {
        final location = createTestLocation(
          id: 1,
          name: 'Updated Name',
          qrCodeId: 'DUPLICATE_QR',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(_TestDatabaseException('UNIQUE constraint failed: locations.qr_code_id'));

        expect(
          () => repository.update(location),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException when fetching updated location fails', () async {
        final location = createTestLocation(
          id: 1,
          name: 'Updated',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => []);

        expect(
          () => repository.update(location),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('throws RepositoryException on general database error', () async {
        final location = createTestLocation(
          id: 1,
          name: 'Updated',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.update(location),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to update location'))),
        );
      });
    });

    group('delete', () {
      test('deletes existing location and returns true', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        final result = await repository.delete(1);

        expect(result, isTrue);
      });

      test('returns false when location not found', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete(
          'locations',
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
          'locations',
          where: 'id = ?',
          whereArgs: [1],
        )).thenThrow(Exception('Database error'));

        expect(
          () => repository.delete(1),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to delete location'))),
        );
      });
    });

    group('count', () {
      test('returns zero when table is empty', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM locations'))
            .thenAnswer((_) async => [{'count': 0}]);

        final result = await repository.count();

        expect(result, 0);
      });

      test('returns correct count of locations', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM locations'))
            .thenAnswer((_) async => [{'count': 5}]);

        final result = await repository.count();

        expect(result, 5);
      });

      test('returns zero when raw query returns null', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM locations'))
            .thenAnswer((_) async => []);

        final result = await repository.count();

        expect(result, 0);
      });

      test('throws RepositoryException on database error', () async {
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery('SELECT COUNT(*) as count FROM locations'))
            .thenThrow(Exception('Database error'));

        expect(
          () => repository.count(),
          throwsA(isA<RepositoryException>()
              .having((e) => e.message, 'message', contains('Failed to count locations'))),
        );
      });
    });

    group('integration scenarios', () {
      test('handles create then read cycle', () async {
        final newLocation = createTestLocation(id: 0, name: 'New Location');

        final createdMap = createTestLocationMap(
          id: 1,
          name: 'New Location',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);
        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);
        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdMap]);

        final created = await repository.create(newLocation);
        expect(created.id, 1);

        final found = await repository.getById(1);
        expect(found, isNotNull);
        expect(found!.name, 'New Location');
      });

      test('handles create, update, delete cycle', () async {
        final newLocation = createTestLocation(id: 0, name: 'Original Name');

        final createdMap = createTestLocationMap(
          id: 1,
          name: 'Original Name',
        );

        final updatedMap = createTestLocationMap(
          id: 1,
          name: 'Updated Name',
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabaseHelper.currentTime).thenReturn(1000000);

        when(mockDatabase.insert(
          'locations',
          any,
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [createdMap]);

        final created = await repository.create(newLocation);
        expect(created.name, 'Original Name');

        when(mockDatabaseHelper.currentTime).thenReturn(2000000);
        when(mockDatabase.update(
          'locations',
          any,
          where: 'id = ?',
          whereArgs: [1],
          conflictAlgorithm: ConflictAlgorithm.abort,
        )).thenAnswer((_) async => 1);

        when(mockDatabase.query(
          'locations',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        )).thenAnswer((_) async => [updatedMap]);

        final updated = await repository.update(created.copyWith(name: 'Updated Name'));
        expect(updated.name, 'Updated Name');

        when(mockDatabase.delete(
          'locations',
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
  _TestDatabaseException(super.message);

  @override
  int? getResultCode() => null;

  @override
  Object? get result => null;
}
