import 'package:storage_app/core/models/location.dart';
import 'package:storage_app/core/models/item.dart';

/// Search result types
enum SearchResultType { location, item }

/// Search result wrapper
class SearchResult {
  final SearchResultType type;
  final String id;
  final String title;
  final String? subtitle;
  final String? photoPath;
  final String? locationId; // For items

  const SearchResult({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.photoPath,
    this.locationId,
  });

  /// Create from a location
  factory SearchResult.fromLocation(Location location) {
    return SearchResult(
      type: SearchResultType.location,
      id: location.id,
      title: location.name,
      subtitle: location.description,
      photoPath: location.photoPath,
    );
  }

  /// Create from an item
  factory SearchResult.fromItem(Item item) {
    return SearchResult(
      type: SearchResultType.item,
      id: item.id,
      title: item.name,
      subtitle: item.description,
      photoPath: item.photoPath,
      locationId: item.locationId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => type.hashCode ^ id.hashCode;

  @override
  String toString() {
    return 'SearchResult{type: $type, id: $id, title: $title}';
  }
}
