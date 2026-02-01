import 'package:equatable/equatable.dart';

/// Item entity representing a stored item.
///
/// This is a domain entity that represents an item
/// stored in a location (e.g., tools, decorations, clothes).
class Item extends Equatable {
  /// Unique identifier for the item.
  final int id;

  /// Name of the item (e.g., "Hammer", "Winter Coat").
  final String name;

  /// Optional description providing more details about the item.
  final String? description;

  /// Optional file path to the item's photo.
  final String? photoPath;

  /// The ID of the location where this item is stored.
  final int locationId;

  /// Timestamp when the item was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when the item was last updated (milliseconds since epoch).
  final int updatedAt;

  const Item({
    required this.id,
    required this.name,
    required this.locationId,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.photoPath,
  });

  /// Creates an [Item] from a map (typically from database row).
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      locationId: map['location_id'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Converts the [Item] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'location_id': locationId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Creates a copy of this [Item] with some fields replaced.
  Item copyWith({
    int? id,
    String? name,
    String? description,
    String? photoPath,
    int? locationId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      locationId: locationId ?? this.locationId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        photoPath,
        locationId,
        createdAt,
        updatedAt,
      ];
}
