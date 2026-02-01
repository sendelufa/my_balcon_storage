/// Item entity representing a stored item
class Item {
  final String id;
  final String name;
  final String? description;
  final String? photoPath;
  final String locationId;
  final String? locationName; // For display purposes
  final int createdAt;
  final int updatedAt;
  final int sortOrder;

  const Item({
    required this.id,
    required this.name,
    this.description,
    this.photoPath,
    required this.locationId,
    this.locationName,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
  });

  /// Create from database map
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      locationId: map['location_id'] as String,
      locationName: map['location_name'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'location_id': locationId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sort_order': sortOrder,
    };
  }

  /// Create a copy with updated fields
  Item copyWith({
    String? id,
    String? name,
    String? description,
    String? photoPath,
    String? locationId,
    String? locationName,
    int? createdAt,
    int? updatedAt,
    int? sortOrder,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  /// Create a new Item with updated timestamp
  Item withUpdatedAt() {
    return copyWith(updatedAt: DateTime.now().millisecondsSinceEpoch);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Item{id: $id, name: $name, locationId: $locationId}';
  }
}
