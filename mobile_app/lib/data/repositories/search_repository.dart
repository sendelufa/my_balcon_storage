import 'package:storage_app/core/database/database_interface.dart';
import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/core/models/item.dart';
import 'package:storage_app/core/models/search_result.dart';
import 'package:storage_app/core/platform/platform_provider.dart';

/// Search repository for database search operations
/// Uses platform-agnostic DatabaseInterface
class SearchRepository {
  final DatabaseInterface _databaseInterface;

  SearchRepository({DatabaseInterface? databaseInterface})
      : _databaseInterface = databaseInterface ?? PlatformProvider.getDatabase();

  /// Search for locations and items
  Future<List<SearchResult>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final results = await _databaseInterface.search(query);
      final searchResults = <SearchResult>[];

      // Convert location results
      final locationMaps = results['locations'] as List<Map<String, dynamic>>;
      for (final map in locationMaps) {
        final location = Location.fromMap(map);
        searchResults.add(SearchResult.fromLocation(location));
      }

      // Convert item results
      final itemMaps = results['items'] as List<Map<String, dynamic>>;
      for (final map in itemMaps) {
        final item = Item.fromMap(map);
        searchResults.add(SearchResult.fromItem(item));
      }

      return searchResults;
    } catch (e) {
      // Fallback to LIKE search if FTS fails
      final results = await _databaseInterface.searchLike(query);
      final searchResults = <SearchResult>[];

      final locationMaps = results['locations'] as List<Map<String, dynamic>>;
      for (final map in locationMaps) {
        final location = Location.fromMap(map);
        searchResults.add(SearchResult.fromLocation(location));
      }

      final itemMaps = results['items'] as List<Map<String, dynamic>>;
      for (final map in itemMaps) {
        final item = Item.fromMap(map);
        searchResults.add(SearchResult.fromItem(item));
      }

      return searchResults;
    }
  }

  /// Search only locations
  Future<List<Location>> searchLocations(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final results = await _databaseInterface.search(query);
    final locationMaps = results['locations'] as List<Map<String, dynamic>>;
    return locationMaps.map((map) => Location.fromMap(map)).toList();
  }

  /// Search only items
  Future<List<Item>> searchItems(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    final results = await _databaseInterface.search(query);
    final itemMaps = results['items'] as List<Map<String, dynamic>>;
    return itemMaps.map((map) => Item.fromMap(map)).toList();
  }
}
