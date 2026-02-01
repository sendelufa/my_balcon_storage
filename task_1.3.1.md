# Task 1.3.1: Create LocationRepository Interface

**Task ID:** 1.3.1
**Status:** Completed
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Create a LocationRepository interface that defines CRUD operations for the Location entity following Flutter best practices and Clean Architecture principles.

## Acceptance Criteria

- [x] Interface defines CRUD operations (Create, Read, Update, Delete)
- [x] Interface follows Dart conventions and best practices
- [x] Clean separation of concerns with domain entity
- [x] Proper documentation with dartdoc comments
- [x] Exception handling defined

## Implementation Details

### Files Created

1. **`/Users/konstantin/StorageProject/app/lib/domain/entities/location.dart`**
   - Domain entity representing a storage location
   - Uses `equatable` for value equality comparison
   - Includes all fields from the database schema: id, name, description, photo_path, qr_code_id, created_at, updated_at
   - Provides factory constructor for database map conversion
   - Provides `toMap()` method for database storage
   - Provides `copyWith()` method for immutable updates

2. **`/Users/konstantin/StorageProject/app/lib/domain/repositories/location_repository.dart`**
   - Abstract repository interface defining the contract for location data operations
   - Methods defined:
     - `getAll()` - Retrieve all locations
     - `getById(int id)` - Retrieve a location by ID
     - `getByQrCodeId(String qrCodeId)` - Retrieve a location by QR code (for Phase 2)
     - `search(String query)` - Search locations by name/description
     - `create(Location location)` - Create a new location
     - `update(Location location)` - Update an existing location
     - `delete(int id)` - Delete a location
     - `count()` - Count total locations
   - Includes `RepositoryException` base class for error handling

## Design Decisions

1. **Clean Architecture**: The repository interface is placed in the domain layer, independent of any data source implementation
2. **Equatable**: Used for value equality comparisons, making state management and testing easier
3. **Immutable Entity**: The `Location` class uses `const` constructor and `copyWith()` for updates
4. **Null Safety**: Fully null-safe implementation with proper nullable fields
5. **QR Code Support**: Included `qrCodeId` field in preparation for Phase 2 QR code functionality

## Next Steps

Task 1.3.2 will implement this interface with SQLite using the existing `DatabaseHelper`.

## Testing Considerations

When implementing tests in task 1.3.5:
- Mock this interface for testing UI layers
- Test all CRUD operations
- Test error handling with RepositoryException
- Test search functionality with various query patterns
