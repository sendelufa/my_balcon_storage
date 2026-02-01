/// Location entity representing a storage location
class Location {
  final String id;
  final String name;
  final String? description;
  final String? photoPath;
  final int createdAt;
  final int updatedAt;
  final int sortOrder;
  final int itemCount;

  const Location({
    required this.id,
    required this.name,
    this.description,
    this.photoPath,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
    this.itemCount = 0,
  });

  /// Create from database map
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
      itemCount: map['item_count'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sort_order': sortOrder,
    };
  }

  /// Create a copy with updated fields
  Location copyWith({
    String? id,
    String? name,
    String? description,
    String? photoPath,
    int? createdAt,
    int? updatedAt,
    int? sortOrder,
    int? itemCount,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      itemCount: itemCount ?? this.itemCount,
    );
  }

  /// Create a new Location with updated timestamp
  Location withUpdatedAt() {
    return copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Location{id: $id, name: $name, itemCount: $itemCount}';
  }
}
