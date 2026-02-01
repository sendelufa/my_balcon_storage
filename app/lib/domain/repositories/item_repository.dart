import '../entities/item.dart';

/// Repository interface for [Item] data operations.
///
/// This abstract class defines the contract for item data access.
/// Implementations can use SQLite, REST API, or any other data source.
///
/// Following the Repository pattern from Clean Architecture,
/// this interface is defined in the domain layer and depends only
/// on domain entities.
abstract class ItemRepository {
  /// Retrieves all items from the data source.
  ///
  /// Returns a list of all [Item] entities.
  /// Throws a [RepositoryException] if the operation fails.
  Future<List<Item>> getAll();

  /// Retrieves an item by its unique identifier.
  ///
  /// The [id] parameter is the unique identifier of the item.
  /// Returns the [Item] if found, or `null` if no item exists with the given id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<Item?> getById(int id);

  /// Retrieves all items belonging to a specific location.
  ///
  /// The [locationId] parameter is the unique identifier of the location.
  /// Returns a list of [Item] entities associated with the location.
  /// Returns an empty list if no items exist for the given location.
  /// Throws a [RepositoryException] if the operation fails.
  Future<List<Item>> getByLocationId(int locationId);

  /// Searches for items matching the given query.
  ///
  /// The [query] parameter is a search string that will be matched
  /// against item names and descriptions.
  /// Returns a list of [Item] entities matching the search criteria.
  /// Returns an empty list if no matches are found.
  /// Throws a [RepositoryException] if the operation fails.
  Future<List<Item>> search(String query);

  /// Creates a new item in the data source.
  ///
  /// The [item] parameter is the [Item] entity to create.
  /// The id field should be null or ignored during creation.
  /// Returns the created [Item] with its assigned id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<Item> create(Item item);

  /// Updates an existing item in the data source.
  ///
  /// The [item] parameter is the [Item] entity with updated values.
  /// The id must match an existing item.
  /// Returns the updated [Item].
  /// Throws a [RepositoryException] if the operation fails or the item doesn't exist.
  Future<Item> update(Item item);

  /// Deletes an item from the data source.
  ///
  /// The [id] parameter is the unique identifier of the item to delete.
  /// Returns `true` if the item was successfully deleted.
  /// Returns `false` if no item exists with the given id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<bool> delete(int id);

  /// Counts the total number of items.
  ///
  /// Returns the count of all items in the data source.
  /// Throws a [RepositoryException] if the operation fails.
  Future<int> count();

  /// Counts the number of items in a specific location.
  ///
  /// The [locationId] parameter is the unique identifier of the location.
  /// Returns the count of items associated with the location.
  /// Throws a [RepositoryException] if the operation fails.
  Future<int> countByLocationId(int locationId);
}

/// Base exception for repository operations.
///
/// All repository-specific exceptions should extend this class.
/// This is shared across all repository interfaces.
class RepositoryException implements Exception {
  /// A message describing the error.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() =>
      'RepositoryException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}
