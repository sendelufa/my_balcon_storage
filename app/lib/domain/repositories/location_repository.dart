import '../entities/location.dart';

/// Repository interface for [Location] data operations.
///
/// This abstract class defines the contract for location data access.
/// Implementations can use SQLite, REST API, or any other data source.
///
/// Following the Repository pattern from Clean Architecture,
/// this interface is defined in the domain layer and depends only
/// on domain entities.
abstract class LocationRepository {
  /// Retrieves all locations from the data source.
  ///
  /// Returns a list of all [Location] entities.
  /// Throws a [RepositoryException] if the operation fails.
  Future<List<Location>> getAll();

  /// Retrieves a location by its unique identifier.
  ///
  /// The [id] parameter is the unique identifier of the location.
  /// Returns the [Location] if found, or `null` if no location exists with the given id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<Location?> getById(int id);

  /// Retrieves a location by its QR code identifier.
  ///
  /// The [qrCodeId] parameter is the unique QR code identifier.
  /// Returns the [Location] if found, or `null` if no location exists with the given QR code.
  /// Throws a [RepositoryException] if the operation fails.
  Future<Location?> getByQrCodeId(String qrCodeId);

  /// Searches for locations matching the given query.
  ///
  /// The [query] parameter is a search string that will be matched
  /// against location names and descriptions.
  /// Returns a list of [Location] entities matching the search criteria.
  /// Returns an empty list if no matches are found.
  /// Throws a [RepositoryException] if the operation fails.
  Future<List<Location>> search(String query);

  /// Creates a new location in the data source.
  ///
  /// The [location] parameter is the [Location] entity to create.
  /// The id field should be null or ignored during creation.
  /// Returns the created [Location] with its assigned id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<Location> create(Location location);

  /// Updates an existing location in the data source.
  ///
  /// The [location] parameter is the [Location] entity with updated values.
  /// The id must match an existing location.
  /// Returns the updated [Location].
  /// Throws a [RepositoryException] if the operation fails or the location doesn't exist.
  Future<Location> update(Location location);

  /// Deletes a location from the data source.
  ///
  /// The [id] parameter is the unique identifier of the location to delete.
  /// Returns `true` if the location was successfully deleted.
  /// Returns `false` if no location exists with the given id.
  /// Throws a [RepositoryException] if the operation fails.
  Future<bool> delete(int id);

  /// Counts the total number of locations.
  ///
  /// Returns the count of all locations in the data source.
  /// Throws a [RepositoryException] if the operation fails.
  Future<int> count();
}

/// Base exception for repository operations.
///
/// All repository-specific exceptions should extend this class.
class RepositoryException implements Exception {
  /// A message describing the error.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  const RepositoryException(this.message, [this.cause]);

  @override
  String toString() => 'RepositoryException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}
