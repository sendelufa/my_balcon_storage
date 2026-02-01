import '../entities/container.dart';

/// Repository interface for [Container] data operations.
///
/// This abstract class defines the contract for container data access.
/// Implementations can use SQLite, REST API, or any other data source.
///
/// Following the Repository pattern from Clean Architecture,
/// this interface is defined in the domain layer and depends only
/// on domain entities.
abstract class ContainerRepository {
  /// Retrieves all containers from the data source.
  ///
  /// The [orderBy] parameter specifies the sort order (default: 'name ASC').
  /// Returns a list of all [Container] entities.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<List<Container>> getAll({String orderBy = 'name ASC'});

  /// Retrieves a container by its unique identifier.
  ///
  /// The [id] parameter is the unique identifier of the container.
  /// Returns the [Container] if found, or `null` if no container exists with the given id.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<Container?> getById(int id);

  /// Retrieves all containers belonging to a specific location.
  ///
  /// The [locationId] parameter is the unique identifier of the parent location.
  /// Returns a list of [Container] entities that have the specified parent location.
  /// Returns an empty list if no containers exist for the given location.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<List<Container>> getByLocationId(int locationId);

  /// Retrieves all containers nested within a specific parent container.
  ///
  /// The [containerId] parameter is the unique identifier of the parent container.
  /// Returns a list of [Container] entities that have the specified parent container.
  /// Returns an empty list if no child containers exist for the given container.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<List<Container>> getByParentContainerId(int containerId);

  /// Searches for containers matching the given query.
  ///
  /// The [query] parameter is a search string that will be matched
  /// against container names and descriptions.
  /// Returns a list of [Container] entities matching the search criteria.
  /// Returns an empty list if no matches are found.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<List<Container>> search(String query);

  /// Creates a new container in the data source.
  ///
  /// The [container] parameter is the [Container] entity to create.
  /// The id field should be null or ignored during creation.
  /// Returns the created [Container] with its assigned id.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<Container> create(Container container);

  /// Updates an existing container in the data source.
  ///
  /// The [container] parameter is the [Container] entity with updated values.
  /// The id must match an existing container.
  /// Returns the updated [Container].
  /// Throws a [ContainerRepositoryException] if the operation fails or the container doesn't exist.
  Future<Container> update(Container container);

  /// Deletes a container from the data source.
  ///
  /// The [id] parameter is the unique identifier of the container to delete.
  /// Returns `true` if the container was successfully deleted.
  /// Returns `false` if no container exists with the given id.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<bool> delete(int id);

  /// Counts the total number of containers.
  ///
  /// Returns the count of all containers in the data source.
  /// Throws a [ContainerRepositoryException] if the operation fails.
  Future<int> count();
}

/// Exception for container repository operations.
///
/// Thrown when any container repository operation fails.
class ContainerRepositoryException implements Exception {
  /// A message describing the error.
  final String message;

  /// The underlying error, if any.
  final Object? cause;

  const ContainerRepositoryException(this.message, [this.cause]);

  @override
  String toString() => 'ContainerRepositoryException: $message${cause != null ? '\nCaused by: $cause' : ''}';
}
