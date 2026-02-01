import 'package:equatable/equatable.dart';

/// Enum representing the type of storage container.
enum ContainerType {
  /// A standard box container.
  box,

  /// A shelf for storage.
  shelf,

  /// A bag for carrying/storing items.
  bag,

  /// A closet space.
  closet,

  /// A drawer storage.
  drawer,

  /// A cabinet container.
  cabinet,

  /// Other type of container not covered by specific types.
  other,
}

/// Extension on [ContainerType] to provide string conversion utilities.
extension ContainerTypeExtension on ContainerType {
  /// Converts the enum to its database string representation.
  String toDatabaseString() {
    switch (this) {
      case ContainerType.box:
        return 'box';
      case ContainerType.shelf:
        return 'shelf';
      case ContainerType.bag:
        return 'bag';
      case ContainerType.closet:
        return 'closet';
      case ContainerType.drawer:
        return 'drawer';
      case ContainerType.cabinet:
        return 'cabinet';
      case ContainerType.other:
        return 'other';
    }
  }
}

/// Container entity representing a storage container.
///
/// This is a domain entity that represents a storage container
/// where items can be stored (e.g., Box, Shelf, Bag).
/// Containers can be nested within locations or other containers.
class Container extends Equatable {
  /// Unique identifier for the container.
  final int id;

  /// Name of the container (e.g., "Summer Clothes Box", "Tool Shelf").
  final String name;

  /// Type of the container.
  final ContainerType type;

  /// Optional description providing more details about the container.
  final String? description;

  /// Optional file path to the container's photo.
  final String? photoPath;

  /// Optional ID of the parent location (null if at root level).
  final int? parentLocationId;

  /// Optional ID of the parent container (null if not nested).
  final int? parentContainerId;

  /// Timestamp when the container was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when the container was last updated (milliseconds since epoch).
  final int updatedAt;

  const Container({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.photoPath,
    this.parentLocationId,
    this.parentContainerId,
  });

  /// Parses a string to a [ContainerType].
  ///
  /// Defaults to [ContainerType.other] if the string doesn't match any type.
  static ContainerType _parseContainerType(String? typeString) {
    if (typeString == null) return ContainerType.other;

    switch (typeString.toLowerCase()) {
      case 'box':
        return ContainerType.box;
      case 'shelf':
        return ContainerType.shelf;
      case 'bag':
        return ContainerType.bag;
      case 'closet':
        return ContainerType.closet;
      case 'drawer':
        return ContainerType.drawer;
      case 'cabinet':
        return ContainerType.cabinet;
      default:
        return ContainerType.other;
    }
  }

  /// Creates a [Container] from a map (typically from database row).
  factory Container.fromMap(Map<String, dynamic> map) {
    return Container(
      id: map['id'] as int,
      name: map['name'] as String,
      type: _parseContainerType(map['type'] as String?),
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      parentLocationId: map['parent_location_id'] as int?,
      parentContainerId: map['parent_container_id'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Converts the [Container] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toDatabaseString(),
      'description': description,
      'photo_path': photoPath,
      'parent_location_id': parentLocationId,
      'parent_container_id': parentContainerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Creates a copy of this [Container] with some fields replaced.
  Container copyWith({
    int? id,
    String? name,
    ContainerType? type,
    String? description,
    String? photoPath,
    int? parentLocationId,
    int? parentContainerId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Container(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      parentLocationId: parentLocationId ?? this.parentLocationId,
      parentContainerId: parentContainerId ?? this.parentContainerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns a two-letter abbreviation for the container type.
  ///
  /// Used for display purposes where space is limited (e.g., badges, icons).
  String get typeAbbreviation {
    switch (type) {
      case ContainerType.box:
        return 'Bo';
      case ContainerType.shelf:
        return 'Sh';
      case ContainerType.bag:
        return 'Ba';
      case ContainerType.closet:
        return 'Cl';
      case ContainerType.drawer:
        return 'Dr';
      case ContainerType.cabinet:
        return 'Ca';
      case ContainerType.other:
        return 'Ot';
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        description,
        photoPath,
        parentLocationId,
        parentContainerId,
        createdAt,
        updatedAt,
      ];
}
