import 'package:equatable/equatable.dart';

/// Location entity representing a storage location.
///
/// This is a domain entity that represents a storage location
/// where items can be stored (e.g., Garage, Basement, Closet).
class Location extends Equatable {
  /// Unique identifier for the location.
  final int id;

  /// Name of the location (e.g., "Garage", "Basement").
  final String name;

  /// Optional description providing more details about the location.
  final String? description;

  /// Optional file path to the location's photo.
  final String? photoPath;

  /// Optional unique QR code identifier for scanning.
  final String? qrCodeId;

  /// Timestamp when the location was created (milliseconds since epoch).
  final int createdAt;

  /// Timestamp when the location was last updated (milliseconds since epoch).
  final int updatedAt;

  const Location({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.photoPath,
    this.qrCodeId,
  });

  /// Creates a [Location] from a map (typically from database row).
  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      photoPath: map['photo_path'] as String?,
      qrCodeId: map['qr_code_id'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Converts the [Location] to a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'photo_path': photoPath,
      'qr_code_id': qrCodeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Creates a copy of this [Location] with some fields replaced.
  Location copyWith({
    int? id,
    String? name,
    String? description,
    String? photoPath,
    String? qrCodeId,
    int? createdAt,
    int? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoPath: photoPath ?? this.photoPath,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, photoPath, qrCodeId, createdAt, updatedAt];
}
