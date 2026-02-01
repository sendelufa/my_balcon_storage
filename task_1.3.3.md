# Task 1.3.3: Create ItemRepository Interface

**Task ID:** 1.3.3
**Status:** ✅ Completed
**Date:** 2025-02-01
**Estimated Hours:** 2
**Actual Hours:** 2

## Description

Create an ItemRepository interface that defines CRUD operations for the Item entity following Flutter best practices and Clean Architecture principles.

## Acceptance Criteria

- [x] Interface defines CRUD operations (Create, Read, Update, Delete)
- [x] Interface defines getByLocationId for filtering items by location
- [x] Interface defines search method
- [x] Interface defines count methods
- [x] Interface follows Dart conventions and best practices
- [x] Clean separation of concerns with domain entity
- [x] Proper documentation with dartdoc comments
- [x] Exception handling defined

## Implementation Details

### Files Created

1. **`/Users/konstantin/StorageProject/app/lib/domain/entities/item.dart`**
   - Domain entity representing a stored item
   - Uses `equatable` for value equality comparison
   - Fields: id, name, description, photoPath, locationId, createdAt, updatedAt
   - Factory constructor `fromMap()` for database map conversion
   - `toMap()` method for database storage
   - `copyWith()` method for immutable updates

2. **`/Users/konstantin/StorageProject/app/lib/domain/repositories/item_repository.dart`**
   - Abstract repository interface defining the contract for item data operations
   - Methods defined:
     - `getAll()` - Retrieve all items
     - `getById(int id)` - Retrieve an item by ID
     - `getByLocationId(int locationId)` - Retrieve items for a specific location
     - `search(String query)` - Search items by name/description
     - `create(Item item)` - Create a new item
     - `update(Item item)` - Update an existing item
     - `delete(int id)` - Delete an item
     - `count()` - Count total items
     - `countByLocationId(int locationId)` - Count items in a location
   - Uses `RepositoryException` from location_repository for error handling

## Design Decisions

1. **Clean Architecture**: Repository interface in domain layer, independent of data source
2. **Equatable**: Value equality for easier state management and testing
3. **Immutable Entity**: `const` constructor with `copyWith()` for updates
4. **Null Safety**: Fully null-safe with proper nullable fields (description, photoPath)
5. **Location Relationship**: `locationId` field establishes foreign key relationship
6. **Shared Exception Types**: Reuses `RepositoryException` from location_repository

## Next Steps

Task 1.3.4 will implement this interface with SQLite using the existing `DatabaseHelper`.

## Testing Considerations

When implementing tests in task 1.3.5:
- Mock this interface for testing UI layers
- Test all CRUD operations
- Test location filtering (getByLocationId, countByLocationId)
- Test error handling with RepositoryException
- Test search functionality with various query patterns
- Test location validation (item must belong to valid location)
